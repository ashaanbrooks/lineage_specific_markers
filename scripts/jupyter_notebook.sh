#!/bin/bash
export JUPYTER_RUNTIME_DIR=$SLURM_TMPDIR/jupyter
jupyter notebook --ip $(hostname -f) --no-browser
