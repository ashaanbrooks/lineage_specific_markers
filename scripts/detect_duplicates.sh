#!/bin/bash
#SBATCH --time=2:00:00
#SBATCH --cpus-per-task=1
#SBATCH --mem=4G
#SBATCH --output=../logs/find_duplicates_%j.out
#SBATCH --error=../logs/find_duplicates_%j.err

source define_paths.sh

mawk '$3 == 0 && $1 != $2' \
    "$ANALYSIS_DIR"/mash/pairwise_distances.txt \
    > "$ANALYSIS_DIR"/mash/duplicates.txt

