from pathlib import Path
from itertools import combinations
import numpy as np
import pandas as pd
from joblib import Parallel, delayed
from fastami import adjusted_mutual_info_mc

base_dir = Path(__file__).parent.parent

# Load data
clusters = pd.read_csv(
    base_dir / "analysis/reportree/ridom_partitions.tsv",
    sep="\t"
)

# Encode cluster labels
cluster_arrays = []
threshold_cols = clusters.columns[1:]
for col in threshold_cols:
    labels = pd.Categorical(clusters[col]).codes
    cluster_arrays.append(labels)

# ---------------------------------------------------------------------
# Pairwise threshold comparison statistics
# ---------------------------------------------------------------------

def compute_pair(i, j):
    ami, ami_error = adjusted_mutual_info_mc(
        cluster_arrays[i],
        cluster_arrays[j],
        accuracy_goal=0.001,
        seed=1
    )

    return {
        "threshold_1": threshold_cols[i],
        "threshold_2": threshold_cols[j],
        "adj_mutual_info": ami,
        "ami_error": ami_error,
    }

pairs = list(combinations(range(len(threshold_cols)), 2))

results = Parallel(n_jobs=8,prefer="threads")(
    delayed(compute_pair)(i, j)
    for i, j in pairs
)

pd.DataFrame(results).to_csv(
    base_dir / "analysis/pairwise_ami.csv",
    index=False
)
