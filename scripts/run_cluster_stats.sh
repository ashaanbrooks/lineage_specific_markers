#!/bin/bash
#SBATCH --output=../logs/cluster_stats_%j.out
#SBATCH --error=../logs/cluster_stats_%j.err
#SBATCH --cpus-per-task=1
#SBATCH --mem=32G
#SBATCH --time=12:00:00

source ../.env/bin/activate

python calculate_cluster_stats.py
