#!/bin/bash
# ------------------------------------------------------------------------------
# WRFOTRON v 1.0
# Christoph Knote (LMU Munich)
# 02/2016
# christoph.knote@lmu.de
# ------------------------------------------------------------------------------

module load nco ncl netcdf

ncksBin=$(which ncks)
ncattedBin=$(which ncatted)
nccopyBin=$(which nccopy)
nclBin=$(which ncl)

function msg {
  echo ""
  echo "---"
  echo $1
  echo "---"
  echo ""
}
