#!/bin/bash
#SBATCH --output=../logs/csvtk_%j.out
#SBATCH --error=../logs/csvtk%j.err
#SBATCH --time=1:00:00
#SBATCH --mem=8G
#SBATCH --cpus-per-task=1

module purge
module load StdEnv/2020 csvtk/0.23.0
source define_paths.sh

# Remove columns corresponding to loci to remove, then keep only rows corresponding to the samples passing QC
csvtk cut -t -f $(head -1 "$ANALYSIS_DIR"/chewbbaca_ridom/results_alleles.tsv | tr '\t' '\n' | grep -vFf "$ANALYSIS_DIR"/loci_to_remove.txt | tr '\n' ',' | sed 's/,$//') "$ANALYSIS_DIR"/chewbbaca_ridom/results_alleles.tsv | \
csvtk grep -t -f 1 -P "$ANALYSIS_DIR"/samples_for_clustering.txt > "$ANALYSIS_DIR"/chewbbaca_ridom/results_alleles_filtered.tsv

