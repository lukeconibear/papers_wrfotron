#!/bin/bash
# ------------------------------------------------------------------------------
# WRFOTRON v 1.0
# Christoph Knote (LMU Munich)
# 02/2016
# christoph.knote@lmu.de
# ------------------------------------------------------------------------------

# path to where these scripts are
chainDir=/home/ufaserv1_i/pmlac/wrf_new/WRFotron

. $chainDir/profile.bash

version=0.1

projectTag=wrfchem_india

withChemistry=true

# WPS installation directory
WPSdir=/home/ufaserv1_i/pmlac/wrf_new/WPS
# WRF installation directory
WRFdir=/home/ufaserv1_i/pmlac/wrf_new/WRFV3
# WRF meteo-only installation directory
WRFmeteodir=/home/ufaserv1_i/pmlac/wrf_new/WRFV3_meteo
# megan_bio_emiss installation directory
WRFMEGANdir=/home/ufaserv1_i/pmlac/wrf_new/megan_bio_emiss
# mozbc installation directory
WRFMOZARTdir=/home/ufaserv1_i/pmlac/wrf_new/mozbc
# wesley/exocoldens installation directory
WRFmztoolsdir=/home/ufaserv1_i/pmlac/wrf_new/wes-coldens
# anthro_emiss installation directory
WRFanthrodir=/home/ufaserv1_i/pmlac/wrf_new/ANTHRO
# fire_emiss installation directory
WRFfiredir=/home/ufaserv1_i/pmlac/wrf_new/FINN/src

# path to GFS input data
metDir=/nobackup/pmlac/GFS
metInc=3

# path to geogrid input data
geogDir=/nobackup/pmlac/WPS_GEOG
# path to MEGAN input data
MEGANdir=/nobackup/pmlac/emissions/MEGAN

# raw emission input - the files you read in with anthro_emiss
#emissDir=/nobackup/pmlac/emissions/EDGAR-HTAP/MOZART_MOSAIC
# Changing to sector specific EDGAR-HTAP2 emissions
emissDir=/nobackup/pmlac/EDGAR-HTAP2/MOZART

# path to FINN fire emissions (requires a / at the end)
fireDir=/nobackup/pmlac/FINN/
# FINN fire emissions input file
fireInpFile=fire_emis.mozm.inp

# emission conversion script for anthro_emis - must match emissions in emissDir
#emissInpFile=emis_edgarhtap_mozmos.inp
# Changing to sector specific EDGAR-HTAP2 emissions
emissInpFile=emis_edgarhtap2_mozmos.inp
# year the emissions are valid for (for offset calculation)
emissYear=2010
# MOZART boundary condition files
MOZARTdir=/nobackup/pmlac/MZ4

# where the WRF will run - /glade/scratch/something...
workDir=/nobackup/pmlac/wrf-chem_2014_with-finn_all-sectors/run
# where the WRF output will be stored - also maybe /glade/scratch/something...
archiveRootDir=/nobackup/pmlac/wrf-chem_2014_with-finn_all-sectors/output
# where the WRF restart files will be stored - also maybe /glade/scratch/something...
restartRootDir=/nobackup/pmlac/wrf-chem_2014_with-finn_all-sectors/restart

# remove run directory after run is finished?
removeRunDir=false

nclPpScript=${chainDir}/pp.ncl

#number of cores to run with for each stage
nprocPre=1
nprocMain=64
nprocPost=1

#mpirun for real.exe and wrf.exe
mpiCommandPre=mpirun
mpiCommandMain=mpirun
submitCommand=qsub

usequeue=true
