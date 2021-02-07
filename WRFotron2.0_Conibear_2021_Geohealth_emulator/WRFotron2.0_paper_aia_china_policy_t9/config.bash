#!/bin/bash
# ------------------------------------------------------------------------------
# WRFOTRON v 2.0
# ------------------------------------------------------------------------------
# code
# ------------------------------------------------------------------------------
# WRFotron
chainDir=/nobackup/earlacoa/code/WRFotron2.0_paper_aia_china_policy_t9
version=0.1
projectTag=WRFChem3.7.1
withChemistry=true
# WPS
WPSdir=/nobackup/earlacoa/code/WPS3.7.1_bbinjectscheme
# WRFChem
WRFdir=/nobackup/earlacoa/code/WRFChem3.7.1_bbinjectscheme
# WRFMeteo
WRFmeteodir=/nobackup/earlacoa/code/WRFMeteo3.7.1
# ------------------------------------------------------------------------------
# preprocessors
# ------------------------------------------------------------------------------
# MEGAN
WRFMEGANdir=/nobackup/earlacoa/code/megan
# MOZBC
WRFMOZARTdir=/nobackup/earlacoa/code/mozbc
# WESLEY/EXOCOLDENS
WRFmztoolsdir=/nobackup/earlacoa/code/wes-coldens
# ANTHRO_EMISS
WRFanthrodir=/nobackup/earlacoa/code/anthro_emis
# FIRE_EMISS
WRFfiredir=/nobackup/earlacoa/code/finn/src
# ------------------------------------------------------------------------------
# input data
# ------------------------------------------------------------------------------
# initial and boundary meteorological data
metDir=/nobackup/earlacoa/initial_boundary_meteo_ecmwf
#metDir=/nobackup/earlacoa/initial_boundary_meteo_gfs
metInc=6
# initial and boundary chemistry data (MZ4 pre 2018, WACCM post 2018)
MOZARTdir=/nobackup/earlacoa/initial_boundary_chem_mz4
#MOZARTdir=/nobackup/earlacoa/initial_boundary_chem_waccm
# geography data
geogDir=/nobackup/WRFChem/WPSGeog3
# MEGAN input data
MEGANdir=/nobackup/earlacoa/emissions/MEGAN
# anthropogenic emissions - data
#emissDir=/nobackup/earlacoa/emissions/EDGAR-HTAP2/MOZART
emissDir=/nobackup/earlacoa/emissions/EDGAR-HTAP2_MEIC2015/MOZART_t9
#emissDir=/nobackup/earlacoa/emissions/CAMS-GLOB-ANT-0.1deg-v4.1-R1.1/with_date_2016/t9
# anthropogenic emissions - input namelist
#emissInpFile=emis_gbdmapsworkinggroup_mozmos.inp
#emissInpFile=emis_gbdmapsworkinggroup-othersplit_mozmos.inp
#emissInpFile=emis_edgarhtap2_mozmos.inp
#emissInpFile=emis_edgarhtap2-without-ch4_mozmos.inp
emissInpFile=emis_edgarhtap2-meic2015_mozmos.inp
#emissInpFile=emis_cams-meic2016-v4.1-R1.1_mozmos.inp
# anthropogenic emissions - year the emissions are valid for (for offset calculation)
emissYear=2010 # date variable for CAMS from EDGARHTAPv2.2 so use offset for this
# fire emissions from FINN (requires a / at the end)
fireDir=/nobackup/earlacoa/emissions/FINN/
# FINN fire emissions input file
fireInpFile=fire_emis.mozm.inp
# diurnal cycle code
WRFemitdir=/nobackup/earlacoa/code/WRF_UoM_EMIT
# ------------------------------------------------------------------------------
# simulation directories
# ------------------------------------------------------------------------------
# run folder
workDir=/nobackup/earlacoa/paper_aia_china_policy_t9/run
# output folder
archiveRootDir=/nobackup/earlacoa/paper_aia_china_policy_t9/output
# restart folder
restartRootDir=/nobackup/earlacoa/paper_aia_china_policy_t9/restart
# remove run directory after run is finished?
removeRunDir=false
# post processing script
nclPpScript=${chainDir}/pp.ncl
# ------------------------------------------------------------------------------
# HPC settings
# ------------------------------------------------------------------------------
# number of cores to run with for each stage
nprocPre=1
nprocMain=108
nprocPost=4
# mpirun for real.exe and wrf.exe
mpiCommandPre=mpirun
mpiCommandMain=mpirun
submitCommand=qsub
usequeue=true
# ------------------------------------------------------------------------------
# misc.
# ------------------------------------------------------------------------------
function msg {
  echo ""
  echo "---"
  echo $1
  echo "---"
  echo ""
}
