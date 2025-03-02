import os
import pandas as pd

# Read file content
default_directory = "G:/MG-NAE3YR9Q/HN00235226_hdd1/250126_CHJ_HN00235226_22sample"
sample_name_list = ["SCA17_01","SCA17_02","SCA17_05","SCA17_06","SCA17_07","SCA17_08","SCA17_10","SCA17_11","SCA17_12","SCA17_13","SCA17_14","SCA17_15","SCA17_16","SCA17_19","SCA17_20","SCA17_22","SCA17_23","SCA17_28","SCA17_29","SCA17_31","SCA17_33","SCA17_35"]

for sample_name in sample_name_list:
    # Read INDEL variants
    file_path = default_directory + "/" + sample_name + "/SNP_INDEL/" + sample_name + "_chr16.xlsx"
    print(file_path)

    if not os.path.exists(file_path):
        print(f"File not found: {file_path}")
        exit()
    with open(file_path, 'r') as file:
        # Read the first 5000 rows of the Excel file
        df = pd.read_excel(file_path, nrows=5000)

        # Filter rows based on locus
        df['Locus'] = df.iloc[:, 1]
        filtered_df = df[(df['Locus'] >= 670000) & (df['Locus'] <= 690000)]
        
        # Filter rows based on gene_name
        df['Gene'] = df.iloc[:, 12]
        filtered_df = filtered_df[df['Gene'].isin(['STUB1', 'LINC02867', 'JMJD8', 'WDR24'])]

        # Select specific columns
        columns_to_select = [10, 11, 12, 15, 17]
        table = filtered_df.iloc[:, columns_to_select]

        # Rename columns
        table.columns = ['variant_type', 'importance', 'gene_name', 'gene_type', 'variant_desc']

        for index, row in table.iterrows():
            print(f"gene: {row['gene_name']} ({row['gene_type']}) var: {row['variant_desc']} ({row['variant_type']}, {row['importance']})")