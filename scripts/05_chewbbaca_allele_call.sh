#!/bin/bash

#SBATCH --time=48:00:00
#SBATCH --cpus-per-task=8
#SBATCH --mem-per-cpu=8G
#SBATCH --output=../logs/allele_call_%j.out
#SBATCH --error=../logs/allele_call_%j.err

# Note that for logs to be in correct place, sbatch should be run from the scripts directory

module purge
module load apptainer/1.4.5

source define_paths.sh

# Using all default parameters: 0.6 BSR, 0.2 size filter, translation table 11, mode 4
# Also using Prodigal training file made from CD630 reference genome for consistent CDS prediction
apptainer exec \
	--cleanenv \
	--no-home \
	--env-file <(sed 's/^export //' define_paths.sh) \
	"$CHEWBBACA_APPTAINER" chewBBACA.py AlleleCall \
	-i "$ASSEMBLY_DIR" \
	-g "$DATA_DIR"/cgmlst_schema_ridom_adapted/ \
	-o "$ANALYSIS_DIR"/chewbbaca_ridom/ \
	--ptf "$DATA_DIR"/cgmlst_schema_ridom_adapted/CD630_training_file.trn \
	--cpu 8

