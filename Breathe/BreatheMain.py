import cv2
import numpy as np
import time
from collections import deque
import matplotlib.pyplot as plt
import sys
import threading

# Define a non-blocking (asynchronous) beep function.
def beep_async():
    if sys.platform.startswith('win'):
        import winsound
        # Use winsound.Beep; note that we are now calling this in a separate thread.
        winsound.Beep(1000, 100)  # 1000 Hz for 100 ms
    else:
        # For non-Windows platforms, simply print the bell character.
        print("\a")

def beep():
    # Launch beep_async in a separate thread so it doesn't block the main loop.
    t = threading.Thread(target=beep_async)
    t.daemon = True
    t.start()

def main():
    # ================================
    # Video Source Setup:
    # ================================
    # For recorded footage, use a file path (string).
    # For live feed, use an integer (e.g., 0).
    video_source = r"C:\Users\chanh\Downloads\Breathe\breathe_example_video.mp4"
    # video_source = 0  # Uncomment this line to use a live feed

    cap = cv2.VideoCapture(video_source)
    if not cap.isOpened():
        print("Error: Could not open video source.")
        return

    # Check if using a live feed.
    live_feed = isinstance(video_source, int)
    if not live_feed:
        total_frames = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))
        print("Total frames in video:", total_frames)

    # Get the frame rate (FPS); if unavailable, default to 30 FPS.
    fps = cap.get(cv2.CAP_PROP_FPS)
    if fps == 0:
        fps = 60.0
    print("FPS:", fps)

    # ================================
    # Rolling Buffer and Data Storage:
    # ================================
    buffer_duration = 5  # seconds for the rolling buffer
    buffer_size = int(fps * buffer_duration)
    intensity_buffer = deque(maxlen=buffer_size)
    all_intensities = []  # Save average intensity for all frames
    rr_values = []        # Save computed RR values (one per update)

    # ================================
    # ROI Selection:
    # ================================
    # Read a frame to let the user select the ROI.
    ret, first_frame = cap.read()
    if not ret:
        print("Error: Could not read first frame.")
        return
    roi = cv2.selectROI("Select ROI", first_frame, showCrosshair=True, fromCenter=False)
    cv2.destroyWindow("Select ROI")
    roi_x, roi_y, roi_w, roi_h = [int(v) for v in roi]

    # For recorded video, reset the video to the start.
    if not live_feed:
        cap.set(cv2.CAP_PROP_POS_FRAMES, 0)

    # ================================
    # Peak Detection Setup:
    # ================================
    peak_window = deque(maxlen=3)
    min_beep_interval = 0.3  # Minimum seconds between beeps
    last_beep_time = 0

    # ================================
    # Processing Loop:
    # ================================
    current_frame = 0
    last_rr_update_time = time.time()
    computed_rr = None

    while True:
        ret, frame = cap.read()
        if not ret:
            break
        current_frame += 1

        # -------- ROI Processing --------
        roi_frame = frame[roi_y:roi_y+roi_h, roi_x:roi_x+roi_w]
        gray_roi = cv2.cvtColor(roi_frame, cv2.COLOR_BGR2GRAY)
        avg_intensity = np.mean(gray_roi)

        # Save intensity for the rolling buffer and later plotting.
        intensity_buffer.append(avg_intensity)
        all_intensities.append(avg_intensity)

        # -------- Peak Detection for Audible Beat --------
        peak_window.append(avg_intensity)
        if len(peak_window) == 3:
            a, b, c = peak_window[0], peak_window[1], peak_window[2]
            # Check for a local peak.
            peak_threshold = 0.01  # Adjust this value based on your signal scale.
            if b > a and b > c and (b - a) > peak_threshold and (b - c) > peak_threshold:
                if time.time() - last_beep_time >= min_beep_interval:
                    beep()  # This call is now asynchronous.
                    last_beep_time = time.time()

        # -------- Update RR every 1 second --------
        current_time = time.time()
        if (current_time - last_rr_update_time >= 1.0) and (len(intensity_buffer) >= buffer_size // 2):
            signal = np.array(intensity_buffer, dtype=np.float32)
            signal -= np.mean(signal)
            fft_result = np.fft.rfft(signal)
            freqs = np.fft.rfftfreq(len(signal), d=1.0/fps)
            magnitudes = np.abs(fft_result)
            min_f = 1.0
            max_f = 4.0
            valid_idx = np.where((freqs >= min_f) & (freqs <= max_f))[0]
            if len(valid_idx) > 0:
                max_idx = valid_idx[np.argmax(magnitudes[valid_idx])]
                dominant_freq = freqs[max_idx]
                computed_rr = dominant_freq * 60.0  # Convert Hz to BPM.
                rr_values.append(computed_rr)
            else:
                computed_rr = None
            last_rr_update_time = current_time

        # -------- Overlay Information on Frame --------
        if live_feed:
            count_text = f"Frame: {current_frame}"
        else:
            count_text = f"Frame: {current_frame}/{total_frames}"
        cv2.putText(frame, count_text, (10, 30),
                    cv2.FONT_HERSHEY_SIMPLEX, 1, (0, 255, 255), 2)
        if computed_rr is not None:
            rr_text = f"RR: {computed_rr:.0f} BPM"
        else:
            rr_text = "RR: calculating..."
        cv2.putText(frame, rr_text, (10, 80),
                    cv2.FONT_HERSHEY_SIMPLEX, 1, (0, 0, 255), 2)
        cv2.rectangle(frame, (roi_x, roi_y), (roi_x + roi_w, roi_y + roi_h), (0, 255, 0), 2)

        cv2.imshow("Video Playback", frame)
        key = cv2.waitKey(1)
        if key == 27 or key == ord('q'):
            break

    cap.release()
    cv2.destroyAllWindows()

    # -------------------------------
    # After Loop: Plot and Report
    # -------------------------------
    if all_intensities:
        plt.figure(figsize=(10, 4))
        plt.plot(all_intensities, label="Avg Intensity")
        plt.xlabel("Frame")
        plt.ylabel("Average Intensity")
        plt.title("Average Intensity Over Time")
        plt.legend()
        plt.show()

    if rr_values:
        avg_rr = np.mean(rr_values)
        print("Average RR over run: {:.1f} BPM".format(avg_rr))
    else:
        print("No RR values computed.")

if __name__ == "__main__":
    main()
