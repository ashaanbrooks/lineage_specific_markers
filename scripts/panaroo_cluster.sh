#!/bin/bash

#SBATCH --time=48:00:00
#SBATCH --cpus-per-task=8
#SBATCH --ntasks-per-node=3
#SBATCH --mem=128G
#SBATCH --output=../logs/panaroo_cluster_%j.out
#SBATCH --error=../logs/panaroo_cluster_%j.err

source define_paths.sh

# Load panaroo virtualenv and required modules
module purge
source "$PANAROO_ENV"/bin/activate
module load cd-hit/4.8.1

mkdir -p "$ANALYSIS_DIR"/panaroo

panaroo -i "$ANALYSIS_DIR"/file_lists_for_panaroo/cluster_"$1".txt \
	-o "$ANALYSIS_DIR"/panaroo/cluster_"$1" \
	--clean-mode strict \
	--remove-invalid-genes \
	-t 24
