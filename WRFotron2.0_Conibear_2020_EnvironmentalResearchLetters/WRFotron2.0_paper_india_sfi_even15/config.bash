#!/bin/bash
# ------------------------------------------------------------------------------
# WRFOTRON v 1.0
# Christoph Knote (LMU Munich)
# 02/2016
# christoph.knote@lmu.de
# ------------------------------------------------------------------------------

# path to where these scripts are
chainDir=/nobackup/earlacoa/code/WRFotron2.0_paper_india_sfi_even15

function msg {
  echo ""
  echo "---"
  echo $1
  echo "---"
  echo ""
}

version=0.1

projectTag=wrfchem_india

withChemistry=true

# WPS installation directory
WPSdir=/nobackup/earlacoa/code/WPS3.7.1
# WRF installation directory
WRFdir=/nobackup/earlacoa/code/WRFChem3.7.1_bbinjectscheme
# WRF meteo-only installation directory
WRFmeteodir=/nobackup/earlacoa/code/WRFMeteo3.7.1
# megan_bio_emiss installation directory
WRFMEGANdir=/nobackup/earlacoa/code/megan
# mozbc installation directory
WRFMOZARTdir=/nobackup/earlacoa/code/mozbc
# wesley/exocoldens installation directory
WRFmztoolsdir=/nobackup/earlacoa/code/wes-coldens
# anthro_emiss installation directory
WRFanthrodir=/nobackup/earlacoa/code/anthro_emis
# fire_emiss installation directory
WRFfiredir=/nobackup/earlacoa/code/finn/src

# path to meteo input data
metDir=/nobackup/earlacoa/initial_boundary_meteo_ecmwf
metInc=6
# path to geogrid input data
geogDir=/nobackup/wrfchem/wps_geog
# path to MEGAN input data
MEGANdir=/nobackup/earlacoa/emissions/MEGAN
# raw emission input - the files you read in with anthro_emiss
emissDir=/nobackup/earlacoa/emissions/GBDMAPSWorkingGroup_OTHRsplit/mozartmosaic_even15
# emission conversion script for anthro_emis - must match emissions in emissDir
emissInpFile=emis_gbdmapsworkinggroup-othersplit_mozmos.inp
# year the emissions are valid for (for offset calculation)
emissYear=2015
# path to FINN fire emissions (requires a / at the end)
fireDir=/nobackup/earlacoa/emissions/FINN/
# FINN fire emissions input file
fireInpFile=fire_emis.mozm.inp
# MOZART boundary condition files
MOZARTdir=/nobackup/earlacoa/initial_boundary_chem_mz4
# diurnal cycle code
WRFemitdir=/nobackup/earlacoa/code/WRF_UoM_EMIT

# where the WRF will run - /glade/scratch/something...
workDir=/nobackup/earlacoa/paper_india_sfi_even15_WRFotron2/run
# where the WRF output will be stored - also maybe /glade/scratch/something...
archiveRootDir=/nobackup/earlacoa/paper_india_sfi_even15_WRFotron2/output
# where the WRF restart files will be stored - also maybe /glade/scratch/something...
restartRootDir=/nobackup/earlacoa/paper_india_sfi_even15_WRFotron2/restart

# remove run directory after run is finished?
removeRunDir=false

nclPpScript=${chainDir}/pp.ncl

#number of cores to run with for each stage
nprocPre=1
nprocMain=32
nprocPost=1

#mpirun for real.exe and wrf.exe
mpiCommandPre=mpirun
mpiCommandMain=mpirun
submitCommand=qsub

usequeue=true
