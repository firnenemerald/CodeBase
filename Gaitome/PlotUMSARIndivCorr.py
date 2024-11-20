import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from scipy.stats import pearsonr

def plot_umsar_indiv_corr(umsars, score):
    """
    Plot UM-SARS individual score correlations with a single gait pattern score.

    Parameters:
    - umsars (np.ndarray or pd.DataFrame): UM-SARS data matrix (subjects x UM-SARS items, total 26 items).
    - score (np.ndarray or pd.Series): Gait pattern score (subjects,).
    
    The function creates a heatmap showing the Pearson correlation coefficients between each UM-SARS item and the gait pattern score.
    Significant correlations (p < 0.05) are annotated with their r and p-values.
    """
    # Convert inputs to NumPy arrays if they aren't already
    umsars = np.array(umsars)
    score = np.array(score).flatten()  # Ensure score is a 1D array
    
    # Validate input dimensions
    if umsars.shape[0] != score.shape[0]:
        raise ValueError("Number of subjects (rows) in 'umsars' and 'score' must be the same.")
    
    # Define UM-SARS item labels
    umsar_part1_tags = [
        "Speech", "Swallowing", "Handwriting", "Cutting food",
        "Dressing", "Hygiene", "Walking", "Falling",
        "Orthostatic symptoms", "Urinary function", "Sexual function", "Bowel function"
    ]
    
    umsar_part2_tags = [
        "Facial expression", "Speech", "Oculomotor dysfunction", "Resting tremor",
        "Action tremor", "Increased tone", "Rapid alternating", "Finger taps",
        "Leg agility", "Heel to shin", "Arising from chair", "Posture",
        "Body sway", "Gait"
    ]
    
    # Combine Part 1 and Part 2 tags
    umsar_tags = umsar_part1_tags + umsar_part2_tags  # Total 26 items
    
    # Define the single gait score label
    gait_label = ["Gait Score"]
    
    num_umsar_items = umsars.shape[1]
    num_gait_scores = 1  # Only one gait score
    
    if num_umsar_items != 26:
        raise ValueError(f"'umsars' should have 26 columns (12 Part 1 + 14 Part 2 items). Current columns: {num_umsar_items}")
    
    # Initialize correlation and p-value arrays
    r_values = np.zeros(num_umsar_items)
    p_values = np.ones(num_umsar_items)
    
    # Calculate Pearson correlation for each UM-SARS item with the gait score
    for i in range(num_umsar_items):
        r, p = pearsonr(umsars[:, i], score)
        r_values[i] = r
        p_values[i] = p
    
    # Create a mask for significant correlations (p < 0.05)
    mask = p_values < 0.05
    
    # Reshape r_values and p_values for heatmap (1 row x 26 columns)
    r_matrix = r_values.reshape(1, -1)
    p_matrix = p_values.reshape(1, -1)
    mask_matrix = mask.reshape(1, -1)
    
    # Define figure size (wider to accommodate 26 items)
    fig_width = 20  # inches
    fig_height = 3  # inches
    plt.figure(figsize=(fig_width, fig_height))
    
    # Create custom diverging colormap
    cmap = sns.diverging_palette(220, 20, as_cmap=True)
    
    # Create a heatmap with seaborn
    ax = sns.heatmap(
        r_matrix,
        annot=False,  # We'll add custom annotations later
        cmap=cmap,
        vmin=-1,      # Pearson r ranges from -1 to 1
        vmax=1,
        cbar=True,
        linewidths=0.5,
        linecolor='k',
        mask=~mask_matrix,   # Mask non-significant correlations
        square=False,
        xticklabels=umsar_tags,
        yticklabels=gait_label,
        cbar_kws={"label": "Pearson r"}
    )
    
    # Add annotations for significant correlations
    for j in range(num_umsar_items):
        if mask_matrix[0, j]:
            r_val = r_matrix[0, j]
            p_val = p_matrix[0, j]
            if p_val < 0.001:
                p_str = f"{p_val:.3e}"
            elif p_val < 0.01:
                p_str = f"{p_val:.4f}"
            else:
                p_str = f"{p_val:.2f}"
            annotation = f"{r_val:.3f}\n({p_str})"
            ax.text(j + 0.5, 0.5, annotation,
                    ha='center', va='center', fontsize=8, color='black')
    
    # Set labels and title
    ax.set_xlabel('UMSARS Items', fontsize=12)
    ax.set_ylabel('Gait Pattern Score', fontsize=12)
    plt.title('UMSARS Individual Correlations with Gait Pattern Score', fontsize=16, pad=20)
    
    # Rotate x-axis labels for better readability
    plt.xticks(rotation=45, ha='right')
    
    # Adjust y-axis label position
    plt.yticks(rotation=0)  # Keep y-label horizontal
    
    # Adjust layout to prevent clipping
    plt.tight_layout()
    
    # Display the plot
    plt.show()

# Example usage:
if __name__ == "__main__":
    # Example data (replace with your actual data)
    num_subjects = 100
    num_umsar_items = 26
    num_gait_scores = 1
    
    # Generate random data for demonstration
    np.random.seed(0)
    umsars_example = np.random.rand(num_subjects, num_umsar_items)
    score_example = np.random.rand(num_subjects)  # Single gait score
    
    plot_umsar_indiv_corr(umsars=umsars_example, score=score_example)
