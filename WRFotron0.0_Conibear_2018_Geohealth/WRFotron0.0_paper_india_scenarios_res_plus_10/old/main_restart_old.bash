#!/bin/bash
# ------------------------------------------------------------------------------
# WRFOTRON v 1.0
# Christoph Knote (LMU Munich)
# 02/2016
# christoph.knote@lmu.de
# ------------------------------------------------------------------------------
#
## LSF batch script to run an MPI application
#BSUB -P P19010000                  # project number (required)
#BSUB -W 12:00                      # wall clock time (in minutes)
#BSUB -n 32                        # number of MPI tasks
#BSUB -R "span[ptile=16]"           # run 64 tasks per node
#BSUB -J wrfchem_india20150108base.main            # job name
#BSUB -o wrfchem_india20150108base.main.%J.out     # output filename
#BSUB -e wrfchem_india20150108base.main.%J.err     # error filename
#BSUB -q regular                    # queue

#$ -P N8HPC_LDS_DVS_AQA             # project code
#$ -cwd -V                          # execute from current working directory and export all current environment variables to all spawned processes
#$ -l h_rt=10:00:00                 # The wall clock time which is the amount of real time needed by the job
#$ -pe ib 32              # Specifies a job for parallel programs using MPI, nprocPre is the number of cores to be used by the parallel job

# Edit namelist.input to be the date of the last restart file
# Run main_restart.bash to just carry on from where the last wrf.exe broke

. config.bash

msg "chem"

# do the chem run
${mpiCommandMain} ./wrf.exe

mkdir chem_out
mv rsl* chem_out

# -----------------------------------------------------------------------------
# 3) house keeping
# -----------------------------------------------------------------------------

msg "save restart files"

# save restart files in restart directory
for domain in $(seq -f "0%g" 1 ${max_dom})
do
  lastRstFile=wrfrst_d${domain}_2015-01-14_12:00:00
  cp ${lastRstFile} ${restartDir}/${lastRstFile}
done

fi
# that stuff was for runs with chemistry only...
#^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

msg "save output to archive staging area"

# move all new output to archive directory
for domain in $(seq -f "0%g" 1 ${max_dom})
do
  for hour in $(seq -w 1 156)
  do
    curDate=$(date -u --date="2015-01-08 00:00:00 ${hour} hours" "+%Y-%m-%d_%H")
    outFile=wrfout_d${domain}_${curDate}:00:00

    cp ${outFile} ${stagingDir}/
  done
done

msg "finished WRF/chem"
