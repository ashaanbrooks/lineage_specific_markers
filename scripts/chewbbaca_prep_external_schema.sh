#!/bin/bash

#SBATCH --time=2:00:00
#SBATCH --cpus-per-task=8
#SBATCH --mem=8G
#SBATCH --output=../logs/prep_external_schema_%j.out
#SBATCH --error=../logs/prep_external_schema_%j.err

# Note that for logs to be in correct place, sbatch should be run from the scripts directory


module load apptainer

# Output directory can't already exist
rm -r "$DATA_DIR"/cgmlst_schema_enterobase_adapted

# Using all default parameters: 0.6 BSR, no length and size filtering, translation table 11
apptainer exec -c "$CHEWBBACA_APPTAINER" chewBBACA.py PrepExternalSchema \
							-g "$DATA_DIR"/cgmlst_schema_enterobase \
							-o "$DATA_DIR"/cgmlst_schema_enterobase_adapted \
							--cpu 8

