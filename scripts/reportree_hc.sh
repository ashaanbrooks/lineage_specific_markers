#!/bin/bash

#SBATCH --time=48:00:00
#SBATCH --cpus-per-task=8
#SBATCH --mem-per-cpu=8G
#SBATCH --output=../logs/reportree_%j.out
#SBATCH --error=../logs/reportree_%j.err

# Note that for logs to be in correct place, sbatch should be run from the scripts directory

module purge
module load apptainer/1.4.5

source define_paths.sh

apptainer exec "$REPORTREE_APPTAINER" reportree.py \
				-d_mx \
				-out \
				--analysis HC \
				--subset \
				--HC-threshold single
