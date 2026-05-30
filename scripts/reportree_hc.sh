#!/bin/bash

#SBATCH --time=24:00:00
#SBATCH --cpus-per-task=1
#SBATCH --mem=32G
#SBATCH --output=../logs/reportree_%j.out
#SBATCH --error=../logs/reportree_%j.err

# Note that for logs to be in correct place, sbatch should be run from the scripts directory

module purge
module load apptainer/1.4.5
source define_paths.sh
mkdir -p "$ANALYSIS_DIR"/reportree/

apptainer exec "$REPORTREE_APPTAINER" reportree.py \
				-d_mx "$ANALYSIS_DIR"/chewbbaca_ridom/distances_filtered.tsv \
				-out "$ANALYSIS_DIR"/reportree/ridom \
				--analysis HC \
				--HC-threshold single
