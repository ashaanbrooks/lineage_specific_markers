#!/bin/bash
#SBATCH --time=1:00:00
#SBATCH --cpus-per-task=8
#SBATCH --ntasks-per-node=2
#SBATCH --mem=4G
#SBATCH --output=../logs/mash_test_%j.out
#SBATCH --error=../logs/mash_test_%j.err

source define_paths.sh

module purge
module load mash/2.3

mkdir -p "$ANALYSIS_DIR"/mash

# Sketch step
find "$ASSEMBLY_DIR" -name "*.fa" | shuf | head -500 > "$ANALYSIS_DIR"/mash/assembly_list_test.txt

mash sketch \
        -l "$ANALYSIS_DIR"/mash/assembly_list_test.txt \
        -o "$ANALYSIS_DIR"/mash/test \
        -s 10000 \
        -p 16

# Timed distance step
time mash dist \
        -p 16 \
        "$ANALYSIS_DIR"/mash/test.msh \
        "$ANALYSIS_DIR"/mash/test.msh \
        > "$ANALYSIS_DIR"/mash/test_distances.txt
