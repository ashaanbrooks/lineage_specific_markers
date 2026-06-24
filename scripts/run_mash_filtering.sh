#!/bin/bash
#SBATCH --output=../logs/filter_mash_%j.out
#SBATCH --error=../logs/filter_mash_%j.err
#SBATCH --cpus-per-task=1
#SBATCH --mem=32G
#SBATCH --time=6:00:00

source ../envs/cluster_stats/bin/activate

python filter_mash_distances.py
