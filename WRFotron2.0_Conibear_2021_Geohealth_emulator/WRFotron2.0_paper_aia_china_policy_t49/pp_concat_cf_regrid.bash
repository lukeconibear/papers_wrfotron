#!/bin/bash -l
#$ -cwd -V
#$ -l h_rt=48:00:00
#$ -pe ib 1
#$ -l h_vmem=64G
#$ -m ea
#$ -M earlacoa@leeds.ac.uk

conda activate cfpython2
module unload netcdf

python pp_concat_cf_regrid.py
