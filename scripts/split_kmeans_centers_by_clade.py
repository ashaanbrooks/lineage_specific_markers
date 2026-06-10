import pandas as pd
import numpy as np
from pathlib import Path

repo_root = Path(__file__).parent.parent

# Load the ST assignments for each sample
st_assignments = pd.read_csv(ST_FILE, sep='\t', index_col=0)

# Load the clade assignments for each ST
clade_assignments = pd.read_csv(CLADE_FILE, sep='\t', index_col=0)

# Merge the ST and clade assignments to get clade assignments for each sample
sample_clade_assignments = st_assignments.merge(clade_assignments, left_on='st', right_index=True, how='left')

# Load IDs of k-means cluster centers
kmeans_cluster_center_ids = np.loadtxt(repo_root / 'analysis/mash/clustering/kmeans_cluster_centers.txt', dtype=str)

# Put all cluster centers that have a clade assignment of 1 or 2 into separate lists
clade_1_cluster_centers = []
clade_2_cluster_centers = []
for center_id in kmeans_cluster_center_ids:
    clade_assignment = sample_clade_assignments.loc[center_id, 'mlst_clade']
    if clade_assignment == 1:
        clade_1_cluster_centers.append(center_id)
    elif clade_assignment == 2:
        clade_2_cluster_centers.append(center_id)

# Save the filepaths of k-means cluster centers to a text file
np.savetxt(repo_root / 'analysis/mash/clustering/kmeans_cluster_centers.txt', kmeans_cluster_center_ids, fmt='%s')

# Save the clade 1 and clade 2 cluster centers to separate text files
np.savetxt(repo_root / 'analysis/mash/clustering/kmeans_clade_1_cluster_centers.txt', clade_1_cluster_centers, fmt='%s')
np.savetxt(repo_root / 'analysis/mash/clustering/kmeans_clade_2_cluster_centers.txt', clade_2_cluster_centers, fmt='%s')