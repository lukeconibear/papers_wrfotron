#!/bin/bash
#$ -P N8HPC_LDS_DVS_AQA             # project code
#$ -cwd -V                          # execute from current working directory and export all current environment variables to all spawned processes
#$ -l h_rt=03:00:00                 # The wall clock time which is the amount of real time needed by the job
#$ -l h_vmem=4G                     # Sets the limit of virtual memory required which is for parallel jobs per processor
#$ -pe ib 16                        # Specifies a job for parallel programs using MPI, nprocPre is the number of cores to be used by the parallel job

cd ~/wrf_new/
. find_missing_GFS.bash

