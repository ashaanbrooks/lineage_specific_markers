#!/bin/bash

#SBATCH --time=4:00:00
#SBATCH --cpus-per-task=4
#SBATCH --mem-per-cpu=4G
#SBATCH --output=../logs/evaluate_schema_%j.out
#SBATCH --error=../logs/evaluate_schema_%j.err

# Note that for logs to be in correct place, sbatch should be run from the scripts directory

module purge
module load apptainer/1.4.5

source define_paths.sh

apptainer exec \
	--cleanenv \
	--no-home \
	--env-file <(sed 's/^export //' define_paths.sh) \
	"$CHEWBBACA_APPTAINER" chewBBACA.py SchemaEvaluator \
	-g "$DATA_DIR"/cgmlst_schema_enterobase_adapted/ \
        -o "$ANALYSIS_DIR"/chewbbaca/schema_evaluation/ \
	--loci-reports \
	--light \
        --cpu 4

