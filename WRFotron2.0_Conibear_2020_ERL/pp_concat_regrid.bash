#!/bin/bash -l
#$ -cwd -V
#$ -l h_rt=12:00:00
#$ -pe ib 1
#$ -l h_vmem=128G
#$ -m ea
#$ -M earlacoa@leeds.ac.uk

conda activate python3

python pp_concat_regrid.py
