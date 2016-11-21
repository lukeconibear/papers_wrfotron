#!/bin/bash
# ------------------------------------------------------------------------------
# WRFOTRON v 1.0
# Christoph Knote (LMU Munich)
# 02/2016
# christoph.knote@lmu.de
# ------------------------------------------------------------------------------

# path to where these scripts are
chainDir=<path to these scripts>

. $chainDir/profile.bash

version=0.1

projectTag=<a name of the project>

withChemistry=<true/false>

# WPS installation directory
WPSdir=<path to WPS source code>
# WRF installation directory
WRFdir=<path to WRF source code>
# WRF meteo-only installation directory
WRFmeteodir=<path to meteo-only WRF installation>
# megan_bio_emiss installation directory
WRFMEGANdir=<path to MEGAN tools>
# mozbc installation directory
WRFMOZARTdir=<path to mozbc tools>
# wesley/exocoldens installation directory
WRFmztoolsdir=<path to wesely/exocoldens tools>
# anthro_emiss installation directory
WRFanthrodir=<path to anthro_emiss installation>

# path to GFS input data
metDir=/glade/p/rda/data/ds083.2/grib2
metInc=6

# path to geogrid input data
geogDir=/glade/u/home/wrfhelp/WPS_GEOG
# path to MEGAN input data
MEGANdir=<path to MEGAN input data>
# raw emission input - the files you read in with anthro_emiss
emissDir=<path to emissions input files>
# emission conversion script for anthro_emis - must match emissions in emissDir
emissInpFile=emis_edgarhtap_mozmos.inp
# year the emissions are valid for (for offset calculation)
emissYear=2010
# MOZART boundary condition files
MOZARTdir=<path to MOZART input files>

# where the WRF will run - /glade/scratch/something...
workDir=<path to working directory>

# where the WRF output will be stored - also maybe /glade/scratch/something...
archiveRootDir=<path to archive directory>
# where the WRF restart files will be stored - also maybe /glade/scratch/something...
restartRootDir=<path to restart-files directory>

# remove run directory after run is finished?
removeRunDir=true

nprocPre=1
nprocMain=128
nprocPost=1

mpiCommandPre=mpirun.lsf
mpiCommandMain=mpirun.lsf
submitCommand=bsub

usequeue=true
