#!/bin/bash

#SBATCH --time=1:00:00
#SBATCH --cpus-per-task=1
#SBATCH --mem=1G
#SBATCH --output=../logs/prodigal_tf_%j.out
#SBATCH --error=../logs/prodigal_tf_%j.err

# Note that for logs to be in correct place, sbatch should be run from the scripts directory

module load prodigal/2.6.3

# Using the CD630DERM reference genome from https://www.ncbi.nlm.nih.gov/datasets/genome/GCF_000953275.1/
prodigal \
	-i "$DATA_DIR"/GCF_000953275.1_CD630DERM_genomic.fna \
	-t "$DATA_DIR"/cgmlst_schema_enterobase/CD630DERM_training_file.trn \
	-p single
