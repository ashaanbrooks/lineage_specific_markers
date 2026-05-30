#!/bin/bash

#SBATCH --time=1:00:00
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=8G
#SBATCH --output=../logs/mask_profiles_%j.out
#SBATCH --error=../logs/mask_profiles_%j.err

# Note that for logs to be in correct place, sbatch should be run from the scripts directory

module purge
module load apptainer/1.4.5

source define_paths.sh

# Extracting cgMLST at threshold 0 just serves to convert INF- to normal numbers, and all other codes to 0
# This is just for easier downstream processing
apptainer exec \
	--cleanenv \
	--no-home \
	--env-file <(sed 's/^export //' define_paths.sh) \
	"$CHEWBBACA_APPTAINER" chewBBACA.py ExtractCgMLST \
	-i "$ANALYSIS_DIR"/chewbbaca/results_alleles.tsv \
	-o "$ANALYSIS_DIR"/chewbbaca/allele_calls_zeroes/ \
	--t 0


