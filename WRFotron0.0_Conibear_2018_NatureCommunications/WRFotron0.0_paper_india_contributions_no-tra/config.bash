#!/bin/bash
# ------------------------------------------------------------------------------
# WRFOTRON v 1.0
# Christoph Knote (LMU Munich)
# 02/2016
# christoph.knote@lmu.de
# ------------------------------------------------------------------------------

# path to where these scripts are
chainDir=/nobackup/pmlac/code/WRFotron_paper_india_air_quality_contributions_health_sector_no-tra

. $chainDir/profile.bash

version=0.1

projectTag=wrfchem_india

withChemistry=true

# WPS installation directory
WPSdir=/nobackup/pmlac/code/WPS
# WRF installation directory
WRFdir=/nobackup/pmlac/code/WRFV3
# WRF meteo-only installation directory
WRFmeteodir=/nobackup/pmlac/code/WRFV3_meteo
# megan_bio_emiss installation directory
WRFMEGANdir=/nobackup/pmlac/code/megan
# mozbc installation directory
WRFMOZARTdir=/nobackup/pmlac/code/mozbc
# wesley/exocoldens installation directory
WRFmztoolsdir=/nobackup/pmlac/code/wes-coldens
# anthro_emiss installation directory
WRFanthrodir=/nobackup/pmlac/code/anthro_emis
# fire_emiss installation directory
WRFfiredir=/nobackup/pmlac/code/finn/src

# path to GFS input data
metDir=/nobackup/pmlac/initial_boundary_meteo
metInc=3
# path to geogrid input data
geogDir=/nobackup/wrfchem/wps_geog
# path to MEGAN input data
MEGANdir=/nobackup/pmlac/emissions/MEGAN
# raw emission input - the files you read in with anthro_emiss
emissDir=/nobackup/pmlac/emissions/EDGAR-HTAP2/MOZART
# emission conversion script for anthro_emis - must match emissions in emissDir
emissInpFile=emis_edgarhtap2_mozmos.inp
# year the emissions are valid for (for offset calculation)
emissYear=2010
# path to FINN fire emissions (requires a / at the end)
fireDir=/nobackup/pmlac/emissions/FINN/
# FINN fire emissions input file
fireInpFile=fire_emis.mozm.inp
# MOZART boundary condition files
MOZARTdir=/nobackup/pmlac/initial_boundary_chem

# where the WRF will run - /glade/scratch/something...
workDir=/nobackup/pmlac/paper_india_air_quality_contributions_health_sector_2014_no-tra/run
# where the WRF output will be stored - also maybe /glade/scratch/something...
archiveRootDir=/nobackup/pmlac/paper_india_air_quality_contributions_health_sector_2014_no-tra/output
# where the WRF restart files will be stored - also maybe /glade/scratch/something...
restartRootDir=/nobackup/pmlac/paper_india_air_quality_contributions_health_sector_2014_no-tra/restart

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
