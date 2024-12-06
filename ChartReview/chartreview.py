import os
import tkinter as tk
from tkinter import filedialog, messagebox
import pandas as pd
from datetime import datetime


class MacroApp:
    def __init__(self, root):
        self.root = root
        self.root.title("Patient Chart Review Helper (by CHJ)")
        self.root.resizable(True, True)  # Allow resizing

        self.file_path = None
        self.data = None
        self.save_file_path = None
        self.current_index = 0
        self.patient_id_column = None

        # Create frames
        self.frame1 = tk.Frame(self.root)
        self.frame2 = tk.Frame(self.root)

        # Setup frame1
        self.setup_frame1()

    def setup_frame1(self):
        self.frame1.pack(fill="both", expand=True)
        self.root.geometry("600x300")

        # Text instruction
        tk.Label(self.frame1, text="Locate .csv file with Patient ID column", font=("Helvetica", 18)).pack(pady=20)

        # File selection button
        find_button = tk.Button(self.frame1, text="Find 🔎", command=self.load_file, font=("Helvetica", 18), fg="green")
        find_button.pack(pady=10, fill="none", expand=False)

        # File path display
        self.file_label = tk.Label(self.frame1, text="", font=("Helvetica", 12), fg="green")
        self.file_label.pack(pady=10, fill="x", expand=True)

        # Start button
        self.start_button = tk.Button(self.frame1, text="Start ▶", command=self.start_review, font=("Helvetica", 18), state=tk.DISABLED)
        self.start_button.pack(pady=10, fill="none", expand=True)

    def setup_frame2(self):
        self.frame2.pack(fill="both", expand=True)
        self.root.geometry("1000x1000")

        # Text showing file being reviewed
        self.reviewing_label = tk.Label(self.frame2, text=f"Currently reviewing: {self.file_path}", font=("Helvetica", 12), fg="green")
        self.reviewing_label.pack(pady=20, fill="x", expand=False)

        # Horizontal progress bar
        self.progress_canvas = tk.Canvas(self.frame2, height=30, bg="white")
        self.progress_canvas.pack(pady=10, fill="x", padx=20)
        # Delay updating the progress bar to ensure the canvas is fully initialized
        self.root.after(100, self.update_progress_bar)  # Update after 100ms

        # Progress display
        self.progress_label = tk.Label(self.frame2, text="", font=("Helvetica", 16))
        self.progress_label.pack(pady=20, fill="x", expand=False)

        # Current patient ID display
        self.patient_id_label = tk.Label(self.frame2, text="", font=("Helvetica", 24), fg="red")
        self.patient_id_label.pack(pady=20, fill="x", expand=False)

        # Reminder textbox
        reminder_frame = tk.Frame(self.frame2)
        reminder_frame.pack(fill="both", expand=True, padx=10, pady=10)
        tk.Label(reminder_frame, text="Reminder:", font=("Helvetica", 16)).pack()
        self.reminder_text = tk.Text(reminder_frame, height=3, wrap="word")
        self.reminder_text.pack(fill="both", expand=True)

        # Copy button
        copy_button = tk.Button(self.frame2, text="↓ Copy ↓", command=self.copy_reminder_to_comment, font=("Helvetica", 16))
        copy_button.pack(pady=10)

        # Comments textbox
        comments_frame = tk.Frame(self.frame2)
        comments_frame.pack(fill="both", expand=True, padx=10, pady=10)
        tk.Label(comments_frame, text="Comment:", font=("Helvetica", 16)).pack()
        self.comments_text = tk.Text(comments_frame, height=4, wrap="word")
        self.comments_text.pack(fill="both", expand=True)

        # Navigation buttons
        nav_frame = tk.Frame(self.frame2)
        nav_frame.pack(pady=20, fill="x", expand=False)
        self.prev_button = tk.Button(nav_frame, text="← Prev", command=self.prev_patient, font=("Helvetica", 16), fg="blue")
        self.prev_button.pack(side=tk.LEFT, padx=20, fill="none", expand=True)
        self.next_button = tk.Button(nav_frame, text="Next →", command=self.next_patient, font=("Helvetica", 16), fg="blue")
        self.next_button.pack(side=tk.LEFT, padx=20, fill="none", expand=True)

        # Save button
        save_button = tk.Button(self.frame2, text="Save", command=self.save_progress, font=("Helvetica", 16))
        save_button.pack(pady=20, fill="none", expand=False)

    def load_file(self):
        try:
            filename = filedialog.askopenfilename(filetypes=[("CSV Files", "*.csv")])
            if not filename:
                return  # User canceled
            self.file_path = filename
            self.data = pd.read_csv(self.file_path, encoding='utf-8')  # Load with UTF-8 encoding
            self.data.columns = self.data.columns.str.strip()  # Strip whitespace from column names
            if 'Comments' not in self.data.columns:
                self.data['Comments'] = ""  # Ensure the Comments column exists
            self.patient_id_column = self.auto_detect_patient_id_column()
            self.current_index = 0

            # Generate the save file path
            base_name = os.path.basename(self.file_path).rsplit(".", 1)[0]
            directory = os.path.dirname(self.file_path)
            timestamp = datetime.now().strftime("%y%m%d")
            self.save_file_path = os.path.join(directory, f"{base_name}_reviewed_{timestamp}.csv")

            # Check if the save file exists
            self.check_save_file()

            self.file_label.config(text=self.file_path)
            self.start_button.config(state=tk.NORMAL)
        except Exception as e:
            messagebox.showerror("Error", f"Failed to load file: {str(e)}")

    def check_save_file(self):
        if os.path.exists(self.save_file_path):
            choice = messagebox.askyesno(
                "Save File Exists",
                "A save file already exists. Do you want to overwrite it?\n"
                "Press 'No' to continue with existing progress."
            )
            if choice:  # User chose to overwrite
                overwrite_confirm = messagebox.askyesno(
                    "Confirm Overwrite",
                    "Overwriting will delete all saved comments. Are you sure you want to proceed?"
                )
                if overwrite_confirm:
                    # Overwrite: Clear all comments and create a new save file
                    self.data['Comments'] = ""  # Clear all comments
                    self.save_to_file()
                    messagebox.showinfo("Overwrite", "All progress has been reset.")
                else:
                    # User canceled the overwrite in the second prompt
                    messagebox.showinfo("Canceled", "Overwrite canceled. Loading saved file.")
                    self.data = pd.read_csv(self.save_file_path, encoding='utf-8')
            else:
                # Continue: Load existing save file
                self.data = pd.read_csv(self.save_file_path, encoding='utf-8')

    def auto_detect_patient_id_column(self):
        possible_names = ['PatientID', 'patient_id', 'Patient Id', 'patientid']
        for name in possible_names:
            if name in self.data.columns:
                return name
        raise ValueError("No known patient ID column found.")

    def start_review(self):
        self.frame1.pack_forget()
        self.setup_frame2()
        self.show_patient()
        self.copy_patient_id_to_clipboard()

    def show_patient(self):
        if self.data is not None and 0 <= self.current_index < len(self.data):
            # Update patient ID display
            patient_id = self.data.iloc[self.current_index][self.patient_id_column]
            self.patient_id_label.config(text=f"Patient ID: {patient_id}")

            # Update progress display
            total_patients = len(self.data)
            self.progress_label.config(text=f"Patient {self.current_index + 1} of {total_patients}")

            # Show existing comments if any
            existing_comment = self.data.loc[self.current_index, 'Comments']
            if pd.isna(existing_comment) or existing_comment == "":
                self.comments_text.delete("1.0", tk.END)
            else:
                self.comments_text.delete("1.0", tk.END)
                self.comments_text.insert("1.0", existing_comment)

            # Update progress bar
            self.update_progress_bar()

    def next_patient(self):
        if self.current_index < len(self.data) - 1:
            self.save_comment()
            self.current_index += 1
            self.copy_patient_id_to_clipboard()
            self.show_patient()
        else:
            messagebox.showinfo("End", "You have reached the end of the patient list.")

    def prev_patient(self):
        if self.current_index > 0:
            self.save_comment()
            self.current_index -= 1
            self.copy_patient_id_to_clipboard()
            self.show_patient()
        else:
            messagebox.showinfo("Start", "You are already at the first patient.")

    def copy_reminder_to_comment(self):
        existing_comment = self.comments_text.get("1.0", tk.END).strip()
        if existing_comment:
            result = messagebox.askyesno(
                "Overwrite Comment?",
                "The comment box already has content. Do you want to overwrite it with the reminder?"
            )
            if not result:
                return
        reminder_content = self.reminder_text.get("1.0", tk.END).strip()
        self.comments_text.delete("1.0", tk.END)
        self.comments_text.insert("1.0", reminder_content)

    def save_comment(self):
        comment = self.comments_text.get("1.0", tk.END).strip()
        self.data.loc[self.current_index, 'Comments'] = comment
        self.save_to_file()

    def save_progress(self):
        self.save_to_file()
        messagebox.showinfo("Saved", f"Progress saved to {self.save_file_path}")
        self.update_progress_bar()  # Update the progress bar after saving

    def update_progress_bar(self):
        """Updates the progress bar on the canvas."""
        self.progress_canvas.delete("all")  # Clear the canvas
        self.progress_canvas.update_idletasks()  # Ensure canvas dimensions are updated

        if self.data is not None:
            total_patients = len(self.data)
            bar_width = self.progress_canvas.winfo_width()
            rect_width = max(10, bar_width // total_patients)  # Minimum width for rectangles
            rect_height = 30

            # Draw rectangles for progress
            for i in range(total_patients):
                x1 = i * rect_width
                x2 = x1 + rect_width

                # Highlight the current patient with blue
                if i == self.current_index:
                    color = "blue"
                else:
                    color = "green" if pd.notna(self.data.loc[i, 'Comments']) and self.data.loc[i, 'Comments'].strip() != "" else "red"

                self.progress_canvas.create_rectangle(x1, 0, x2, rect_height, fill=color, outline="black")
                self.progress_canvas.create_text((x1 + x2) // 2, rect_height // 2, text=str(i + 1), font=("Helvetica", 8), fill="white")

    def save_to_file(self):
        if self.data is not None and self.save_file_path:
            try:
                self.data.to_csv(self.save_file_path, index=False, encoding='utf-8')
            except Exception as e:
                messagebox.showerror("Error", f"Failed to save file: {str(e)}")
    
    def copy_patient_id_to_clipboard(self):
        if self.data is not None and 0 <= self.current_index < len(self.data):
            patient_id = str(self.data.iloc[self.current_index][self.patient_id_column])
            self.root.clipboard_clear()
            self.root.clipboard_append(patient_id)
            self.root.update()  # Keeps the clipboard updated

# Main window
root = tk.Tk()
app = MacroApp(root)
root.mainloop()
