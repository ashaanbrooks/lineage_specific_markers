#!/bin/bash

#SBATCH --time=2:00:00
#SBATCH --cpus-per-task=1
#SBATCH --mem=1G

source define_paths.sh

# Download the C. difficile cgMLST v2 scheme from https://www.cgmlst.org/ncs/schema/Cdifficile/
wget -O "$DATA_DIR"/cgmlst_schema_ridom.zip https://www.cgmlst.org/ncs/schema/Cdifficile/alleles/

# Decompress
mkdir -p "$DATA_DIR"/cgmlst_schema_ridom
unzip "$DATA_DIR"/cgmlst_schema_ridom.zip -d "$DATA_DIR"/cgmlst_schema_ridom

# Downloaded May 27, 2026
