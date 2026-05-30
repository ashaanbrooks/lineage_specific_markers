from pathlib import Path
from itertools import combinations

import numpy as np
import pandas as pd

from sklearn.metrics import (
    adjusted_rand_score,
    adjusted_mutual_info_score,
    silhouette_score,
)

from joblib import Parallel, delayed

base_dir = Path(__file__).parent.parent

# Load data
clusters = pd.read_csv(
    base_dir / "analysis/reportree/ridom_partitions.tsv",
    sep="\t"
)

distances = pd.read_csv(
    base_dir / "analysis/chewbbaca_ridom/distances_filtered.tsv",
    sep="\t",
    index_col=0
)

# Ensure sample order matches
assert list(distances.index) == list(clusters.iloc[:, 0]), (
    "Sample order mismatch between distance matrix and clustering assignments"
)

dist_matrix = distances.values

# Validate distance matrix
assert np.allclose(dist_matrix, dist_matrix.T), (
    "Distance matrix not symmetric"
)

assert np.allclose(np.diag(dist_matrix), 0), (
    "Distance matrix diagonal must be zero"
)

threshold_cols = clusters.columns[1:]

# Encode cluster labels
cluster_arrays = []

for col in threshold_cols:
    labels = pd.Categorical(clusters[col]).codes
    cluster_arrays.append(labels)

# ---------------------------------------------------------------------
# Silhouette helper
# ---------------------------------------------------------------------

def compute_silhouette_scores(dist_matrix, labels):

    unique_labels = np.unique(labels)

    # Silhouette including singletons
    if 1 < len(unique_labels) < len(labels):
        sil_all = silhouette_score(
            dist_matrix,
            labels,
            metric="precomputed"
        )
    else:
        sil_all = np.nan

    # Remove singleton clusters
    counts = pd.Series(labels).value_counts()
    mask = pd.Series(labels).map(counts) > 1

    filtered_labels = labels[mask]
    filtered_dist = dist_matrix[np.ix_(mask, mask)]

    filtered_unique = np.unique(filtered_labels)

    if 1 < len(filtered_unique) < len(filtered_labels):
        sil_non_singleton = silhouette_score(
            filtered_dist,
            filtered_labels,
            metric="precomputed"
        )
    else:
        sil_non_singleton = np.nan

    return sil_all, sil_non_singleton

# ---------------------------------------------------------------------
# Per-threshold statistics
# ---------------------------------------------------------------------

per_threshold = []

for t, vals in enumerate(cluster_arrays):

    sil_all, sil_non_singleton = compute_silhouette_scores(
        dist_matrix,
        vals
    )

    labels = clusters[threshold_cols[t]]

    per_threshold.append({
        "threshold": threshold_cols[t],

        "n_clusters": labels.str.startswith("cluster_").sum(),

        "n_singletons": labels.str.startswith("singleton_").sum(),

        "adj_rand": (
            adjusted_rand_score(
                cluster_arrays[t],
                cluster_arrays[t + 1]
            )
            if t < len(cluster_arrays) - 1
            else np.nan
        ),

        "adj_mutual_info": (
            adjusted_mutual_info_score(
                cluster_arrays[t],
                cluster_arrays[t + 1]
            )
            if t < len(cluster_arrays) - 1
            else np.nan
        ),

        "silhouette_all": sil_all,

        "silhouette_non_singleton": sil_non_singleton,
    })

pd.DataFrame(per_threshold).to_csv(
    base_dir / "analysis/cluster_stats_py.csv",
    index=False
)

# ---------------------------------------------------------------------
# Pairwise threshold comparison statistics
# ---------------------------------------------------------------------

def compute_pair(i, j):

    return {
        "threshold_1": threshold_cols[i],

        "threshold_2": threshold_cols[j],

        "adj_rand": adjusted_rand_score(
            cluster_arrays[i],
            cluster_arrays[j]
        ),

        "adj_mutual_info": adjusted_mutual_info_score(
            cluster_arrays[i],
            cluster_arrays[j]
        )
    }

pairs = list(combinations(range(len(threshold_cols)), 2))

results = Parallel(n_jobs=8)(
    delayed(compute_pair)(i, j)
    for i, j in pairs
)

pd.DataFrame(results).to_csv(
    base_dir / "analysis/pairwise_stats.csv",
    index=False
)
