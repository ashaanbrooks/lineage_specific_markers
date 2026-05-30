#!/bin/bash
#SBATCH --output=../logs/cgmlst_dists_%j.out
#SBATCH --error=../logs/cgmlst_dists_%j.err
#SBATCH --time=1:00:00
#SBATCH --mem=16G
#SBATCH --cpus-per-task=8

source define_paths.sh

# cgmlst-dists already installed and in PATH
cgmlst-dists -j 8 "$ANALYSIS_DIR"/chewbbaca_ridom/results_alleles_filtered.tsv > "$ANALYSIS_DIR"/chewbbaca_ridom/distances_filtered.tsv
