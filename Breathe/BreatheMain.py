import cv2
import numpy as np
from scipy.signal import find_peaks
import matplotlib.pyplot as plt

def calculate_respiratory_rate(video_path, roi=None):
    """
    Calculate respiratory rate from a video of a breathing mouse using optical flow.
    
    Parameters:
    video_path (str): Path to the video file
    roi (tuple): Region of interest as (x, y, width, height), if None, will prompt user to select
    
    Returns:
    float: Estimated respiratory rate in breaths per minute
    """
    # Open the video
    cap = cv2.VideoCapture(r"C:\Users\chanh\Videos\Logitech\LogiCapture\2025-03-27_15-21-06.mp4")
    if not cap.isOpened():
        print("Error opening video file")
        return None
    
    # Get video properties
    fps = cap.get(cv2.CAP_PROP_FPS)
    total_frames = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))
    
    # Select ROI if not provided
    if roi is None:
        ret, first_frame = cap.read()
        if not ret:
            print("Failed to read first frame")
            return None
        
        print("Select ROI for respiratory analysis (press Enter when done)")
        roi = cv2.selectROI("Select ROI", first_frame, False)
        cv2.destroyWindow("Select ROI")
        cap.set(cv2.CAP_PROP_POS_FRAMES, 0)  # Reset to start of video
    
    # Parameters for Lucas-Kanade optical flow
    lk_params = dict(winSize=(15, 15),
                     maxLevel=2,
                     criteria=(cv2.TERM_CRITERIA_EPS | cv2.TERM_CRITERIA_COUNT, 10, 0.03))
    
    # Create points to track within the ROI
    ret, old_frame = cap.read()
    if not ret:
        print("Failed to read frame")
        return None
    
    x, y, w, h = roi
    old_gray = cv2.cvtColor(old_frame, cv2.COLOR_BGR2GRAY)
    roi_gray = old_gray[y:y+h, x:x+w]
    
    # Create a grid of points to track in the ROI
    points = []
    step = 5  # Distance between points
    for i in range(0, h, step):
        for j in range(0, w, step):
            points.append([x + j, y + i])
    
    points = np.array(points, dtype=np.float32).reshape(-1, 1, 2)
    
    # Prepare for tracking
    motion_data = []
    frame_count = 0
    
    # We'll store the last valid frame to display the RR at the end
    last_frame = None
    
    # Process the video
    while True:
        ret, frame = cap.read()
        if not ret:
            break
        
        frame_gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
        
        # Calculate optical flow
        new_points, status, _ = cv2.calcOpticalFlowPyrLK(old_gray, frame_gray, points, None, **lk_params)
        
        # Select good points
        good_old = points[status == 1]
        good_new = new_points[status == 1]
        
        # Calculate motion magnitude (vertical component as breathing is mainly up/down)
        if len(good_old) > 0 and len(good_new) > 0:
            motion = np.mean(np.abs(good_new[:, 1] - good_old[:, 1]))
            motion_data.append(motion)
        
        # Draw the tracks for visualization
        for (new, old) in zip(good_new, good_old):
            a, b = new.ravel()
            c, d = old.ravel()
            cv2.line(frame, (int(a), int(b)), (int(c), int(d)), (0, 255, 0), 2)
            cv2.circle(frame, (int(a), int(b)), 3, (0, 0, 255), -1)
        
        # Draw ROI
        cv2.rectangle(frame, (x, y), (x + w, y + h), (255, 0, 0), 2)
        
        # Show the frame
        cv2.imshow('Respiratory Tracking', frame)
        
        # Update the previous frame and points
        old_gray = frame_gray.copy()
        points = new_points.reshape(-1, 1, 2)
        
        # Keep a copy of the current frame
        last_frame = frame.copy()
        
        frame_count += 1
        
        # Break if 'q' is pressed
        if cv2.waitKey(30) & 0xFF == ord('q'):
            break
    
    # Release resources
    cap.release()
    cv2.destroyAllWindows()
    
    if len(motion_data) < fps:
        print("Not enough frames to analyze.")
        return None
    
    # Process the motion data to find respiratory rate
    motion_data = np.array(motion_data)
    
    # Smooth the motion signal
    window_size = int(fps / 4)  # Quarter-second window
    if window_size % 2 == 0:
        window_size += 1  # Ensure odd window size
    
    # Simple moving average
    motion_smooth = np.convolve(motion_data, np.ones(window_size)/window_size, mode='valid')
    
    # Find peaks in the smoothed signal
    peaks, _ = find_peaks(motion_smooth, distance=fps/4)  # Minimum distance between peaks
    
    # Calculate respiratory rate
    if len(peaks) > 1:
        time_between_peaks = (peaks[-1] - peaks[0]) / (len(peaks) - 1) / fps  # in seconds
        breaths_per_second = 1 / time_between_peaks
        respiratory_rate = breaths_per_second * 60  # Convert to breaths per minute
    else:
        print("Not enough peaks detected to calculate respiratory rate.")
        respiratory_rate = None
    
    # Plot the results
    plt.figure(figsize=(12, 6))
    
    # Plot motion data
    plt.subplot(211)
    time_axis = np.arange(len(motion_data)) / fps
    plt.plot(time_axis, motion_data, 'b-', label='Raw Motion')
    
    # Plot smoothed data with detected peaks
    time_axis_smooth = np.arange(len(motion_smooth)) / fps
    plt.plot(time_axis_smooth, motion_smooth, 'r-', label='Smoothed Motion')
    if len(peaks) > 0:
        plt.plot(time_axis_smooth[peaks], motion_smooth[peaks], 'go', label='Detected Breaths')
    
    plt.xlabel('Time (seconds)')
    plt.ylabel('Vertical Motion')
    plt.title('Respiratory Motion Analysis')
    plt.legend()
    
    # Plot the frequency spectrum
    plt.subplot(212)
    motion_fft = np.fft.rfft(motion_smooth)
    freq = np.fft.rfftfreq(len(motion_smooth), d=1/fps)
    plt.plot(freq * 60, np.abs(motion_fft))  # Convert Hz to breaths per minute
    plt.xlabel('Frequency (breaths per minute)')
    plt.ylabel('Amplitude')
    plt.title('Frequency Spectrum')
    
    if respiratory_rate is not None:
        plt.axvline(x=respiratory_rate, color='r', linestyle='--', 
                    label=f'Respiratory Rate: {respiratory_rate:.1f} BPM')
        plt.legend()
    
    plt.tight_layout()
    plt.show()
    
    # If we have a valid RR, overlay it on the last frame and display
    if respiratory_rate is not None and last_frame is not None:
        text = f"RR: {respiratory_rate:.1f} BPM"
        cv2.putText(last_frame, text, (50, 50), 
                    cv2.FONT_HERSHEY_SIMPLEX, 1.2, (0, 255, 0), 2)
        while True:
            cv2.imshow("Final Respiratory Rate", last_frame)
            # Press 'q' again to close
            if cv2.waitKey(30) & 0xFF == ord('q'):
                break
        cv2.destroyAllWindows()
    
    return respiratory_rate

# Example usage
if __name__ == "__main__":
    video_path = input("Enter path to the video file: ")
    resp_rate = calculate_respiratory_rate(video_path)
    if resp_rate is not None:
        print(f"Estimated respiratory rate: {resp_rate:.1f} breaths per minute")
