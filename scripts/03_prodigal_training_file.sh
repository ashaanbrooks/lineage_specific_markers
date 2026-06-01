#!/bin/bash

#SBATCH --time=1:00:00
#SBATCH --cpus-per-task=1
#SBATCH --mem=1G
#SBATCH --output=../logs/prodigal_tf_%j.out
#SBATCH --error=../logs/prodigal_tf_%j.err

# Note that for logs to be in correct place, sbatch should be run from the scripts directory

module purge
module load prodigal/2.6.3
source define_paths.sh

# Using the CD630 complete sequence NC_009089.1 from https://www.ncbi.nlm.nih.gov/nuccore/NC_009089.1
prodigal \
	-i "$DATA_DIR"/NC_009089.1.fasta \
	-t "$DATA_DIR"/cgmlst_schema_ridom/CD630_training_file.trn \
	-p single
