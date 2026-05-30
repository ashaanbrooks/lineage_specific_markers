#!/bin/bash

#SBATCH --time=1:00:00
#SBATCH --cpus-per-task=1
#SBATCH --mem=1G

mkdir -p "$DATA_DIR"/cgmlst_schema_enterobase

wget -r -np -nd -A "*.fasta.gz" \
  -P "$DATA_DIR"/cgmlst_schema_enterobase \
  https://enterobase.warwick.ac.uk/schemes/clostridium.cgMLSTv1/

# Decompress
gunzip "$DATA_DIR"/cgmlst_schema_enterobase/*.fasta.gz

