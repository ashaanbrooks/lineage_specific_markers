#!/bin/bash

#SBATCH --time=00:10:00
#SBATCH --cpus-per-task=1
#SBATCH --mem=4G

time tar -xf "$1"
