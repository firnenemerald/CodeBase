import os
import re

def GetPolyQLength(genome_sequence: str) -> int:
    """
    Given a genome sequence, finds expansions composed of CAG, CAA, or CAR (at least 2 repeats long)
    and returns the largest polyQ length found. 
    If no repeats are found, returns 0.
    """
    # Regex to match at least two repeats of (CAG) or (CAA) or (CAR)
    pattern = re.compile(r'((?:CAG|CAA|CAR){3,})')
    matches = pattern.finditer(genome_sequence)
    
    # Track the largest polyQ repeat
    longest_polyQ_length = 0
    
    for match in matches:
        repeat_seq = match.group()
        # Each triplet (CAG or CAA or CAR) codes for one 'Q' in the protein
        polyQ_length = len(repeat_seq) // 3  # total number of triplets
        if polyQ_length > longest_polyQ_length:
            longest_polyQ_length = polyQ_length
    
    return longest_polyQ_length

def FormatPolyQ(genome_sequence: str) -> str:
    """
    Given a genome sequence, finds expansions composed of CAG, CAA, or CAR (at least 2 repeats long)
    and returns a formatted string representing the repeats.
    """
    pattern = re.compile(r'((?:CAG|CAA|CAR){3,})')
    matches = pattern.finditer(genome_sequence)
    
    longest_polyQ_length = 0
    for match in matches:
        repeat_seq = match.group()
        # Each triplet (CAG or CAA or CAR) codes for one 'Q' in the protein
        polyQ_length = len(repeat_seq) // 3  # total number of triplets
        if polyQ_length > longest_polyQ_length:
            longest_polyQ_length = polyQ_length
    
    formatted_string = ""
    current_triplet = ""
    count = 0
    for i in range(0, len(repeat_seq), 3):
        triplet = repeat_seq[i:i+3]
        if triplet == current_triplet:
            count += 1
        else:
            if current_triplet:
                formatted_string += f"({current_triplet}){count}"
            current_triplet = triplet
            count = 1
    if current_triplet:
        formatted_string += f"({current_triplet}){count}"
    
    return formatted_string

# Read file content
default_directory = "C:/Users/chanh/Downloads/SCA17_csq"
sample_name = "SCA17_06"
file_path = default_directory + "/" + sample_name + "_TBP_read.txt"
if not os.path.exists(file_path):
    print(f"File not found: {file_path}")
    exit()
with open(file_path, 'r') as file:
    content = file.read().strip()

# Gene of interest
gene_name = "TBP"
gene_span1 = 170561890
gene_span2 = 170562035

# Find the number of occurrences of the string "#####"
alleleCount = content.count("#####") + 1

# Process each allele
for i in range(alleleCount):
    print(f"Processing allele {i + 1}")
    allele = content.split("#####")[i].strip()
    ref_span1 = int(allele.split("chr6:")[1].split("-")[0].strip().replace(',', ''))
    ref_span2 = int(allele.split("chr6:")[1].split("-")[1].split("(")[0].strip().replace(',', ''))
    readseq = allele.split("Read sequence =")[1].strip()
    if ref_span1 < gene_span1:
        trim_length1 = gene_span1 - ref_span1
        readseq = readseq[trim_length1:]
    if gene_span2 < ref_span2:
        trim_length2 = ref_span2 - gene_span2
        readseq = readseq[:-trim_length2]
    print("Sequence: ", readseq)
    print("Formatted ", FormatPolyQ(readseq))
    print("Repeat #: ", GetPolyQLength(readseq))

