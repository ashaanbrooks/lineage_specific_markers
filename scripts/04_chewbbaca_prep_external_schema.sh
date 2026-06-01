#!/bin/bash

#SBATCH --time=2:00:00
#SBATCH --cpus-per-task=8
#SBATCH --mem=8G
#SBATCH --output=../logs/prep_external_schema_%j.out
#SBATCH --error=../logs/prep_external_schema_%j.err

# Note that for logs to be in correct place, sbatch should be run from the scripts directory

module purge
module load apptainer/1.4.5

source define_paths.sh


# Output directory can't already exist
rm -r "$DATA_DIR"/cgmlst_schema_ridom_adapted

# Using all default parameters: 0.6 BSR, no length and size filtering, translation table 11
apptainer exec -c "$CHEWBBACA_APPTAINER" chewBBACA.py PrepExternalSchema \
							-g "$DATA_DIR"/cgmlst_schema_ridom \
							-o "$DATA_DIR"/cgmlst_schema_ridom_adapted \
							--ptf "$DATA_DIR"/cgmlst_schema_ridom/CD630_training_file.trn \
							--cpu 8

