import os
import re
import matplotlib.pyplot as plt

# Define the path to the text file
default_directory = r"C:\\Users\\chanh\\Downloads\\SCA17_csq"
sample_name = r"SCA17_02"

# Construct the file path
file_path = default_directory + r"\\" + sample_name + r"_TBP_csq.txt"
save_path = default_directory + r"\\" + sample_name + r"_TBP_result.txt"

# Check if the file exists
if not os.path.exists(file_path):
    print(f"File not found: {file_path}")
    exit()

# Read the content of the file
with open(file_path, 'r') as file:
    consensus = file.read().strip()
consensus_locus, consensus_sequence = consensus.split("\t", 1)

# Get global_start from consensus_locus
global_start = int(consensus_locus.split(":")[1].split("-")[0])

# Regex to match at least two repeats of (CAG) or (CAA) or (CAR)
pattern = re.compile(r'((?:CAG|CAA|CAR){2,})')
matches = pattern.finditer(consensus_sequence)

# List for all repeats
repeats = []

# Variables to track the longest repeat
longest_repeat_seq = ""
longest_start = None
longest_end = None
longest_polyQ_length = 0

for match in matches:
    repeat_seq = match.group()
    start = match.start()
    end = match.end()
    
    # Count how many triplets in the matched region (each triplet codes for Q)
    # Since the pattern enforces triplet structure, we can do:
    polyQ_length = len(repeat_seq) // 3  # total number of triplets in matched region
    
    repeats.append((repeat_seq, start, end, polyQ_length))
    
    # Update tracking for longest repeat
    if polyQ_length > longest_polyQ_length:
        longest_polyQ_length = polyQ_length
        longest_repeat_seq = repeat_seq
        longest_start = start
        longest_end = end

# Write results to file
with open(save_path, 'w') as result_file:
    result_file.write("Locus:\n")
    result_file.write(consensus_locus + "\n\n")
    result_file.write("Consensus sequence:\n")
    result_file.write(consensus_sequence + "\n\n")
    
    # Print the sample name
    print("Sample name: " + sample_name)
    result_file.write(f"Sample name: {sample_name}\n\n")
    
    result_file.write("All repeats (2 or more occurrences) found:\n")
    print("All repeats (2 or more occurrences) found:")
    
    for repeat, start, end, polyQ_length in repeats:
        # Build a structure annotation like (CAG)2(CAA)3 ...
        structure = []
        i = 0
        while i < len(repeat):
            triplet = repeat[i:i+3]
            # We only need to group identical triplets consecutively
            if triplet in ("CAG", "CAA", "CAR"):
                count = 0
                while i < len(repeat) and repeat[i:i+3] == triplet:
                    count += 1
                    i += 3
                structure.append(f'({triplet}){count}')
            else:
                i += 1
        
        # Print and save each repeat block
        repeat_info = (f" - Repeat found at position "
                       f"{start + global_start}-{end + global_start}: "
                       f"{''.join(structure)} "
                       f"[PolyQ length = {polyQ_length}]")
        print(repeat_info)
        result_file.write(repeat_info + "\n")
    
    result_file.write("\nLongest repeat expansion:\n")
    print("\nLongest repeat expansion:")
    if longest_repeat_seq:
        # Build the structure for the longest repeat as well
        structure = []
        i = 0
        while i < len(longest_repeat_seq):
            triplet = longest_repeat_seq[i:i+3]
            if triplet in ("CAG", "CAA", "CAR"):
                count = 0
                while i < len(longest_repeat_seq) and longest_repeat_seq[i:i+3] == triplet:
                    count += 1
                    i += 3
                structure.append(f'({triplet}){count}')
            else:
                i += 1
        
        longest_info = (f" - Position: {longest_start + global_start}-{longest_end + global_start}\n"
                        f" - Structure: {''.join(structure)}\n"
                        f" - PolyQ length: {longest_polyQ_length}\n")
        print(longest_info)
        result_file.write(longest_info + "\n")
    else:
        # If no repeats found at all
        print("No repeats found.")
        result_file.write("No repeats found.\n")

# # Plot the full consensus_sequence as a line across all bases
# plt.figure(figsize=(10, 2))
# plt.plot(range(len(consensus_sequence)), [1] * len(consensus_sequence), 'k-', lw=2)
# plt.title('Full Consensus Sequence (Highlighting ≥2 Repeats)')
# plt.xlabel('Position')
# plt.yticks([])

# # Highlight the repeat regions in red
# for repeat_seq, start, end, _ in repeats:
#     plt.plot(range(start, end), [1] * (end - start), 'r-', lw=4)

# plt.show()
