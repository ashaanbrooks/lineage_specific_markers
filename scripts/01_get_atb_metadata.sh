#!/bin/bash

#SBATCH --time=1:00:00
#SBATCH --cpus-per-task=1
#SBATCH --mem=1G

#wget -O "$DATA_DIR"/atb.metadata.202505.sqlite.xz https://osf.io/download/my56u/

# Also need to decompress it
unxz "$DATA_DIR"/atb.metadata.202505.sqlite.xz
