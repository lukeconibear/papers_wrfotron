#!/bin/bash

# Batch script to execute multiple chained WRF/chem simulations
# with meteo spinup and carried-on meteorology from 
# previous runs.
#

# -----------------------------------------------------------------------------
# 1) input of parameters
# -----------------------------------------------------------------------------

OPTIND=1

experiment="base"
while getopts ":e:" opt
do
  case $opt in
    e) experiment=${OPTARG} ;;
  esac
done

shift $(($OPTIND - 1))

if [[ $# -lt 10 || $# -gt 11 ]]
then
  echo "Call with arguments <start year (YYYY)> <start month (MM)> <start day (DD)> <start hour (hh)> <end year (YYYY)> <end month (MM)> <end day (DD)> <end hour (hh)> <forecast time (h)> <spinup time (h)>"
  echo "Call with arguments <start year (YYYY)> <start month (MM)> <start day (DD)> <start hour (hh)> <end year (YYYY)> <end month (MM)> <end day (DD)> <end hour (hh)> <forecast time (h)> <spinup time (h)> <dependent job (PID)>"
  return 1
fi

batchStartYear=$1
batchStartMonth=$2
batchStartDay=$3
batchStartHour=$4

batchEndYear=$5
batchEndMonth=$6
batchEndDay=$7
batchEndHour=$8

fcstTime=$9
spinupTime=${10}

isDependent=false
lastjobnr=""
if [[ $# -eq 11 ]]
then
  isDependent=true
  lastjobnr=${11}
fi
  

# load configuration file
. config.bash

batchEndDate=$(date -u --date="${batchEndYear}-${batchEndMonth}-${batchEndDay} ${batchEndHour}:00:00" "+%s")
batchCurDate=$(date -u --date="${batchStartYear}-${batchStartMonth}-${batchStartDay} ${batchStartHour}:00:00" "+%s")

let nRuns="(batchEndDate-batchCurDate)/(fcstTime*3600)"

i=1
while [ $batchCurDate -lt $batchEndDate ]
do
  curYear=$(date -u --date="1970-01-01 ${batchCurDate} sec GMT" "+%Y")
  curMonth=$(date -u --date="1970-01-01 ${batchCurDate} sec GMT" "+%m")
  curDay=$(date -u --date="1970-01-01 ${batchCurDate} sec GMT" "+%d")
  curHour=$(date -u --date="1970-01-01 ${batchCurDate} sec GMT" "+%H")

  echo ""
  echo "============================================================"
  echo "Batch run for exp. ${experiment} ${curYear}-${curMonth}-${curDay} ${curHour}:00:00 +${fcstTime} -${spinupTime} (run $i of $nRuns)"
  echo "============================================================"
  echo ""

  if $usequeue
  then
    lastjobtxt=$(. master.bash -e ${experiment} ${curYear} ${curMonth} ${curDay} ${curHour} ${fcstTime} ${spinupTime} ${lastjobnr})
    echo $lastjobtxt
    lastjobnr=$(echo $lastjobtxt | grep -o "<[0-9\]\{1,10\}>" | sed -s "s/[<>]//g")
  else
    . master.bash -e ${experiment} ${curYear} ${curMonth} ${curDay} ${curHour} ${fcstTime} ${spinupTime}
  fi

  echo ""
  echo "============================================================"
  echo "============================================================"
  echo ""
  
  let batchCurDate="batchCurDate+fcstTime*3600"
  let i=i+1
done
