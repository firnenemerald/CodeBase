import bamnostic

path_cram = "F:\MG-NAE3YR9Q\HN00235226_hdd1\SCA17_01\SCA17_01.cram"
path_hg38 = "F:\MG-NAE3YR9Q\HN00235226_hdd1\hg38\GCA_000001405.15_GRCh38_full_analysis_set.fna"
chromosome = 'chr6'
start_pos = 170561890
end_pos = 170562035

try:
    with bamnostic.AlignmentFile(path_cram, 'rc', reference_filename = path_hg38) as cram_file:
        print(f"Successfully opened CRAM file: {path_cram}")
        print(f"Reference sequences in CRAM: {cram_file.references}")
        print(f"Fetching reads for {chromosome}:{start_pos}-{end_pos}...")

        fetched_reads = cram_file.fetch(chromosome, start_pos, end_pos)

        count = 0
        for read in fetched_reads:
            count += 1
            print(f"\nRead Name: {read.query_name}")
            print(f"  Sequence: {read.query_sequence}")
            print(f"  Mapping Quality: {read.mapping_quality}")
            print(f"  Is Unmapped: {read.is_unmapped}")
            print(f"  Reference Start: {read.reference_start}") # 0-based
            # You can print other attributes as needed: read.cigartuples, read.is_reverse, etc.

        if count == 0:
            print(f"No reads found in the region {chromosome}:{start_pos}-{end_pos}")
        else:
            print(f"\nFound {count} reads in the specified region.")

except FileNotFoundError:
    print(f"Error: CRAM file, its index (.crai), or the reference FASTA file not found.")
    print(f"  CRAM: {path_cram}")
    print(f"  Reference FASTA: {path_hg38}")
except ValueError as ve:
    print(f"A ValueError occurred: {ve}")
    print("This can happen if the reference FASTA is missing or incorrect, or if chromosome names don't match.")
except Exception as e:
    print(f"An error occurred: {e}")
    print("Make sure your CRAM file is valid, the reference FASTA is correct, and the chromosome names match those in the CRAM header and FASTA.")