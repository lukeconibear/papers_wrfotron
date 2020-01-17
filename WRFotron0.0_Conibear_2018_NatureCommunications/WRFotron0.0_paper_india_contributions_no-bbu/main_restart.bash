#!/bin/bash
# ------------------------------------------------------------------------------
# WRFOTRON v 1.0
# Christoph Knote (LMU Munich)
# 02/2016
# christoph.knote@lmu.de
# ------------------------------------------------------------------------------
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
#$ -l h_rt=48:00:00                 # The wall clock time which is the amount of real time needed by the job
#$ -pe ib 32                        # Specifies a job for parallel programs using MPI, nprocPre is the number of cores to be used by the parallel job

. config.bash

# fix hyper-threading issue with Yellowstone after upgrade
unset MP_PE_AFFINITY
export MP_TASK_AFFINITY=cpu

# -----------------------------------------------------------------------------
# 2) Chemistry simulation
# -----------------------------------------------------------------------------

# update restart files with previous results for chemistry, or do cold start

# restart check logic assumes that once we have restart file for domain 1
# we continue, even though further domains might be missing a restart file.
# Logic does not account for the case that restart file for domain 1 is missing,
# but is available for another domain (--> would attempt restart run...)
restartFound=false

for domain in $(seq -f "0%g" 1 ${max_dom})
do

newRunRstFile=wrfrst_d${domain}_YYYY-MM-DD_HH:00:00
prevRunRstFile=${restartDir}/${newRunRstFile}

if [ -f ${prevRunRstFile} ]
then

msg "substituting initial data with ${prevRunRstFile}"

# listing variables in old (chemistry) and new (met-only) restart files
$ncksBin -m ${prevRunRstFile} | grep -E ': type' | cut -f 1 -d ' ' | sed 's/://' | sort > chemVarList
$ncksBin -m ${newRunRstFile} | grep -E ': type' | cut -f 1 -d ' ' | sed 's/://' | sort  > metVarList

# determining arrays only in old (chemistry) restart file
chemVarsArr=( $(awk 'FNR==NR{a[$0]++;next}!a[$0]' metVarList chemVarList) )
# converting to comma-separated string
chemVarsLst=${chemVarsArr[@]}
chemVarsTxt=${chemVarsLst// /,}

# adding chemistry variables to new restart file
$ncksBin -A -v ${chemVarsTxt} ${prevRunRstFile} ${newRunRstFile}

restartFound=true

fi

done

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
  lastRstFile=wrfrst_d${domain}_YYYY-MM-DD_HH:00:00
  cp ${lastRstFile} ${restartDir}/${lastRstFile}
done

fi
# that stuff was for runs with chemistry only...
#^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

msg "save output to archive staging area"

# move all new output to archive directory
for domain in $(seq -f "0%g" 1 ${max_dom})
do
  for hour in $(seq -w 1 __fcstTime__)
  do
    curDate=$(date -u --date="YYYY-MM-DD HH:00:00 ${hour} hours" "+%Y-%m-%d_%H")
    outFile=wrfout_d${domain}_${curDate}:00:00

    cp ${outFile} ${stagingDir}/
  done
done

msg "finished WRF/chem"

