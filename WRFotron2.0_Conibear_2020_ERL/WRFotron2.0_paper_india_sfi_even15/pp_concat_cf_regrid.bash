#!/bin/bash -l
#$ -cwd -V
#$ -l h_rt=48:00:00
#$ -pe ib 1
#$ -l node_type=24core-128G
#$ -l h_vmem=64G

conda activate cfpython2
module unload netcdf

python pp_concat_cf_regrid.py
