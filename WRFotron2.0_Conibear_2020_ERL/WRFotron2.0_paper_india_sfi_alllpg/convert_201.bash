#!/bin/bash
#$ -cwd -V                          # execute from current working directory and export all current environment variables to all spawned processes
#$ -l h_rt=48:00:00                 # The wall clock time which is the amount of real time needed by the job
#$ -pe ib 1                         # Specifies a job for parallel programs using MPI, nprocPre is the number of cores to be used by the parallel job
#$ -l node_type=24core-128G
#$ -l h_vmem=128G

ncl 'file_in="wrfout_2014_jan_chemopt201.nc"' 'file_out="wrfout_2014_jan_chemopt201_cf.nc"' wrfout_to_cf_201.ncl
