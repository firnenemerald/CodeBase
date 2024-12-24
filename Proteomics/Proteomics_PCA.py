import pandas as pd
from sklearn.decomposition import PCA
import matplotlib.pyplot as plt

# Load the data
file_path = './data/raw_QN.xlsx'
df = pd.read_excel(file_path, sheet_name='Sheet1')

# Extract relevant data
protein_ids = df.iloc[:, 0]
protein_names = df.iloc[:, 1]
data = df.iloc[:, 2:]

# Transpose the data for PCA
data_transposed = data.T

# Perform PCA
pca = PCA(n_components=2)
principal_components = pca.fit_transform(data_transposed)

# Explained variance
explained_variance = pca.explained_variance_ratio_
print(f'Explained variance by PC1: {explained_variance[0]:.2f}')
print(f'Explained variance by PC2: {explained_variance[1]:.2f}')

# Create patient names
patient_names = [f'{i//2 + 1}{"A" if i % 2 == 0 else "B"}' for i in range(data_transposed.shape[0])]

# Scatter plot of PC1 vs PC2 with different colors for A and B
plt.figure(figsize=(10, 7))
for i, (x, y) in enumerate(principal_components):
    color = 'red' if 'A' in patient_names[i] else 'blue'
    plt.scatter(x, y, color=color)
    plt.annotate(patient_names[i], (x, y))

plt.xlabel('Principal Component 1')
plt.ylabel('Principal Component 2')
plt.title('PC1 vs PC2')
plt.show()

# Composition of PC1
pc1_composition = pd.Series(pca.components_[0], index=protein_names)
top_5_proteins = pc1_composition.abs().nlargest(5)
print('Top 5 proteins contributing to PC1:')
print(top_5_proteins)