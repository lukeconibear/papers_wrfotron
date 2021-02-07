#!/bin/bash -l
#$ -cwd -V
#$ -l h_rt=24:00:00
#$ -pe ib 1
#$ -l h_vmem=148G
#$ -m ea
#$ -M earlacoa@leeds.ac.uk

conda activate python3

python pp_concat_regrid.py
