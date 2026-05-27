#!/bin/bash

#SBATCH --time=8:00:00
#SBATCH --cpus-per-task=8
#SBATCH --ntasks-per-node=2
#SBATCH --mem=32G
#SBATCH --output=../logs/mash_%j.out
#SBATCH --error=../logs/mash_%j.err

# Note that for logs to be in correct place, sbatch should be run from the scripts directory

module purge
module load mash/2.3

source define_paths.sh

mkdir -p "$ANALYSIS_DIR"/mash

# Create list of assembly paths
find "$ASSEMBLY_DIR" -name "*.fa" > "$ANALYSIS_DIR"/mash/assembly_list.txt

# Sketch all assemblies - using increased sketch size of 10,000, default k-mer length of 21
mash sketch \
        -l "$ANALYSIS_DIR"/mash/assembly_list.txt \
        -o "$ANALYSIS_DIR"/mash/all_assemblies \
        -s 10000 \
        -p 16

# Pairwise distance matrix
mash dist \
        -p 16 \
        "$ANALYSIS_DIR"/mash/all_assemblies.msh \
        "$ANALYSIS_DIR"/mash/all_assemblies.msh \
        > "$ANALYSIS_DIR"/mash/pairwise_distances.txt

