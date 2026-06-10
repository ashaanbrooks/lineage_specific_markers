# Purpose: process MASH pairwise distance output, filter, and convert to .npy
import numpy as np
from pathlib import Path

repo_root = Path(__file__).parent.parent
DIST_FILE = repo_root / "analysis" / "mash" / "pairwise_distances.tsv"
KEEP_FILE = repo_root / "analysis" / "samples_for_clustering.txt"
OUTPUT_FILE = repo_root / "analysis" / "mash" / "pairwise_distances_filtered.npy"

with open(KEEP_FILE, 'r') as f:
    samples_to_keep = {line.strip() for line in f if line.strip()}

sample_indices = {s: i for i, s in enumerate(samples_to_keep)}
num_samples = len(sample_indices)

distance_matrix = np.zeros((num_samples, num_samples), dtype=np.float32)

with open(DIST_FILE, 'r') as f:
    for line in f:
        sample1, sample2, distance, *_ = line.strip().split('\t')
        if sample1 in sample_indices and sample2 in sample_indices:
            idx1 = sample_indices[sample1]
            idx2 = sample_indices[sample2]
            dist = np.float32(distance)
            distance_matrix[idx1, idx2] = dist
            distance_matrix[idx2, idx1] = dist

np.save(OUTPUT_FILE, distance_matrix)