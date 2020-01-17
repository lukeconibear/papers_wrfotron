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
#BSUB -W 03:30                      # wall clock time (in minutes)
#BSUB -n __nprocPost__              # number of MPI tasks
#BSUB -R "span[ptile=16]"           # run 64 tasks per node
#BSUB -J __POSTJOBNAME__            # job name
#BSUB -o __POSTJOBNAME__.%J.out     # output filename
#BSUB -e __POSTJOBNAME__.%J.err     # error filename
#BSUB -q geyser                     # queue

. __CONFIGDIR__config.bash

cd ${stagingDir}

msg "Postprocessing of WRF/Chem output"

mkdir -p ${archiveDir}

for hour in $(seq -w 0 __fcstTime__)
do
  dateTag=$(date -u --date="__inpYear__-__inpMonth__-__inpDay__ __inpHour__:00:00 ${hour} hours" "+%Y%m%d%H%M%S")
  curDate=$(date -u --date="__inpYear__-__inpMonth__-__inpDay__ __inpHour__:00:00 ${hour} hours" "+%Y-%m-%d_%H")

  echo "PP'ing ${dateTag}"

  for domain in $(seq -f "0%g" 1 ${max_dom})
  do
    inFile=wrfout_d${domain}_${curDate}:00:00

    if [ ! -f ${inFile} ]
    then
      echo "${inFile} missing, skipped!"
      continue
    fi

    # --------------------- per file postprocessing ----------------------------

    #. $ppBashScript $inFile $outFile $domain $dateTag
    outFile=$inFile

    # do whatever you want to do in postprocessing, just create a final NetCDF
    # file with its name in the variable "outFile".
    # This will be archived.

    # --------------------- per file postprocessing ----------------------------

    # apply compression and save to archive, use input filename
    # k3 --> NetCDF-4 format
    # d9 --> max compression level
    # s  --> shuffling (can improve compression)
    $nccopyBin -k3 -d9 -s $outFile ${archiveDir}/${inFile}

    # remove file from staging area
    rm $outFile

  done

done

# remove the run directory
if __REMOVERUNDIR__
then
  rm -rf ${runDir}
fi


msg "PP ended"




