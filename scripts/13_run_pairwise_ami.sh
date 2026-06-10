#!/bin/bash
#SBATCH --output=../logs/ami_%j.out
#SBATCH --error=../logs/ami_%j.err
#SBATCH --cpus-per-task=8
#SBATCH --mem=16G
#SBATCH --time=12:00:00

source ../envs/cluster_stats/bin/activate

python pairwise_ami.py

