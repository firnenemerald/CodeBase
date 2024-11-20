import tkinter as tk
from tkinter import filedialog
import pandas as pd
import pyperclip
from datetime import datetime

class MacroApp:
    def __init__(self, root):
        self.root = root
        self.root.title("Patient Chart Review Macro")
        
        # Frame for file selection
        frame_file = tk.Frame(self.root)
        frame_file.pack(pady=20)
        self.file_path = tk.StringVar()
        tk.Entry(frame_file, textvariable=self.file_path, width=50).pack(side=tk.LEFT)
        tk.Button(frame_file, text="Browse", command=self.load_file).pack(side=tk.LEFT)
        
        # Reminder textbox with 3 lines height (using Text widget)
        tk.Label(self.root, text="Reminder:").pack()
        self.reminder_text = tk.Text(self.root, height=3, width=60)
        self.reminder_text.pack()

        # Display patient ID with larger red font
        self.patient_id_label = tk.Label(self.root, text="", font=("Helvetica", 24), fg="red")
        self.patient_id_label.pack(pady=20)

        # Label for next patient ID
        self.next_patient_id_label = tk.Label(self.root, text="", font=("Helvetica", 12), fg="black")
        self.next_patient_id_label.pack()

        # Textbox for comments
        tk.Label(self.root, text="Comments:").pack()
        self.comments_text = tk.Text(self.root, height=4, width=60)
        self.comments_text.pack()

        # Control buttons
        tk.Button(self.root, text="Start", command=self.start_review).pack(pady=10)
        tk.Button(self.root, text="Save", command=self.save_progress).pack()

        # Key bindings
        self.root.bind('<Control-Alt-n>', self.next_patient)
        self.root.bind('<Control-Alt-s>', lambda event: self.save_progress())

        self.data = None
        self.current_index = 0
        self.patient_id_column = None

        # Add this line in __init__ to create a label for save messages
        self.save_message_label = tk.Label(self.root, text="", font=("Helvetica", 12))
        self.save_message_label.pack(pady=10)

        # Initialize index_label here
        self.index_label = tk.Label(self.root, text="", font=("Helvetica", 12))
        self.index_label.pack()

    def load_file(self):
        filename = filedialog.askopenfilename(filetypes=[("CSV Files", "*.csv")])
        self.file_path.set(filename)
        self.data = pd.read_csv(filename)
        self.data.columns = self.data.columns.str.strip()  # Strip whitespace from column names
        print("Column names:", self.data.columns)
        self.patient_id_column = self.auto_detect_patient_id_column()
        self.current_index = 0

    def auto_detect_patient_id_column(self):
        possible_names = ['PatientID', 'patient_id', 'Patient Id', 'patientid']
        for name in possible_names:
            if name in self.data.columns:
                return name
        raise ValueError("No known patient ID column found.")

    def start_review(self):
        # Create the Next button and destroy the Start button
        self.next_button = tk.Button(self.root, text="Next", command=self.next_patient)
        self.next_button.pack(pady=10)
        
        # Destroy the Start button
        self.root.children['!button'].destroy()  # Assuming the Start button is the first button created
        self.show_patient()

    def show_patient(self):
        if self.data is not None and self.current_index < len(self.data):
            patient_id = self.data.iloc[self.current_index][self.patient_id_column]
            self.patient_id_label.config(text=str(patient_id))
            pyperclip.copy(str(patient_id))

            # Display next patient ID in smaller font
            if self.current_index + 1 < len(self.data):
                next_patient_id = self.data.iloc[self.current_index + 1][self.patient_id_column]
                self.next_patient_id_label.config(text=f"Next Patient ID: ({next_patient_id})")
            else:
                self.next_patient_id_label.config(text="Next Patient ID: (N/A)")

            # Display the index of the patient being reviewed
            self.index_label.config(text=f"Patient #{self.current_index + 1} / {len(self.data)}")

        # Create or update the index label
        if not hasattr(self, 'index_label'):
            self.index_label = tk.Label(self.root, text="", font=("Helvetica", 12))
            self.index_label.pack()

        self.index_label.config(text=f"Patient #{self.current_index + 1} / {len(self.data)}")

        # Make the Next button bigger
        self.next_button.config(font=("Helvetica", 16))

    def next_patient(self, event=None):
        self.save_comment()
        self.current_index += 1
        self.show_patient()

    def save_comment(self):
        patient_id = self.data.iloc[self.current_index][self.patient_id_column]
        comment = self.comments_text.get("1.0", tk.END)
        self.data.loc[self.current_index, 'Comments'] = comment.strip()
        self.comments_text.delete("1.0", tk.END)

    def save_progress(self):
        if self.data is not None:
            filename = f'chartreview_{datetime.now().strftime("%Y%m%d")}.csv'
            self.data.to_csv(filename, index=False)
            print("Progress saved to", filename)
            self.save_message_label.config(text=f"Progress saved to {filename}")
            
            # Clear the message after 1 second (1000 milliseconds)
            self.root.after(1000, lambda: self.save_message_label.config(text=""))

# Main window
root = tk.Tk()
app = MacroApp(root)
root.mainloop()
