#!/bin/bash
# ------------------------------------------------------------------------------
# WRFOTRON v 1.0
# Christoph Knote (LMU Munich)
# 02/2016
# christoph.knote@lmu.de
# ------------------------------------------------------------------------------
#$ -cwd -V                          # execute from current working directory and export all current environment variables to all spawned processes
#$ -l h_rt=07:00:00                 # The wall clock time which is the amount of real time needed by the job
#$ -pe ib __nprocPre__              # Specifies a job for parallel programs using MPI, nprocPre is the number of cores to be used by the parallel job
#$ -l h_vmem=32G                    # Sets the limit of virtual memory required which is for parallel jobs per processor
#$ -l node_type=24core-128G         # sets the node type

# we assume we are called from master.bash, and hence know all variables
# e.g. startYear, startMonth, startDay...

. config.bash

# -----------------------------------------------------------------------------
# 1) WPS
# -----------------------------------------------------------------------------

msg "WPS - copying/linking files"

for aFile in util geogrid geogrid.exe ungrib ungrib.exe link_grib.csh metgrid metgrid.exe
do
  cp -fr ${WPSdir}/$aFile .
done

# -----------------------------------------------------------------------------
# 1a) ungrib - for GFS meteo
# -----------------------------------------------------------------------------
# fix for new GFS Vtable. Script will break if simulating through this date
# (do either before or after simulations)
#if [ "__startYear____startMonth____startDay____startHour__" -ge "2015011412" ]
#then
#  ln -s ${chainDir}/Vtable.GFS_new Vtable
#else
#  ln -s ungrib/Variable_Tables/Vtable.GFS Vtable
#fi

# list of met files to link
#fileList=( ${metDir}/GF__startYear____startMonth____startDay____startHour__ )
#let totTime="__fcstTime__+__spinupTime__+metInc"
#for hour in $(seq -w ${metInc} ${metInc} ${totTime})
#do
#  curYear=$(date -u --date="__startYear__-__startMonth__-__startDay__ __startHour__:00:00 ${hour} hours" "+%Y")
#  curMonth=$(date -u --date="__startYear__-__startMonth__-__startDay__ __startHour__:00:00 ${hour} hours" "+%m")
#  curDay=$(date -u --date="__startYear__-__startMonth__-__startDay__ __startHour__:00:00 ${hour} hours" "+%d")
#  curHour=$(date -u --date="__startYear__-__startMonth__-__startDay__ __startHour__:00:00 ${hour} hours" "+%H")
#  fileList=( ${fileList[@]} ${metDir}/GF${curYear}${curMonth}${curDay}${curHour} )
#done

#/bin/csh ./link_grib.csh ${fileList[@]}

# -----------------------------------------------------------------------------
# 1b) ungrib - for ECMWF meteo
# -----------------------------------------------------------------------------
# link the Vtable
#ln -s ${chainDir}/Vtable.ERA-interim.pl Vtable
ln -s ${chainDir}/Vtable.ECMWF Vtable
# link the ECMWF files to be ungribbed - both the surface and pressure levels for the date required (change)
/bin/csh ./link_grib.csh ${metDir}/ecmwf_global_pressurelevels_20160901_20170101.grib ${metDir}/ecmwf_global_surface_20160901_20170101.grib

cp namelist.wps.prep namelist.wps

msg "ungrib"
./ungrib.exe > ungrib.log

rm GRIBFILE*

msg "geogrid"
${mpiCommandPre} ./geogrid.exe

msg "metgrid"
${mpiCommandPre} ./metgrid.exe

rm FILE*

# -----------------------------------------------------------------------------
# 2) first real without chemistry
# -----------------------------------------------------------------------------

cp -r ${WRFdir}/run/* .
rm *.exe
cp -r ${WRFdir}/main/*.exe .
cp -r ${WRFmeteodir}/main/wrf.exe wrfmeteo.exe

rm namelist.input
cp namelist.wrf.prep.real_metonly namelist.input

msg "first real - without chemistry"
${mpiCommandPre} ./real.exe

mkdir first_real_out
mv rsl* first_real_out

# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
# stuff that follows is for runs with chemistry only...
if $withChemistry
then

# -----------------------------------------------------------------------------
# 3) MEGAN, Wesely, Exo_coldens
# -----------------------------------------------------------------------------

msg "MEGAN"

# MEGAN takes a long time, but does not really depend on the time of simulation.
# Hence we create one file for the whole year (that is - LAI for all months)
# and only replace start date etc ...

# assume if one is missing, all are missing!
if [ ! -f ${workDir}/wrfbiochemi_d01_${projectTag} ]
then
  echo "MEGAN input files do not not exist - recreating from scratch. Grab a coffee..."
  ln -s ${WRFMEGANdir}/megan_bio_emiss .
  ./megan_bio_emiss < megan_bio_emiss.inp > megan_bio_emiss.out
  for domain in $(seq -f "0%g" 1 ${max_dom})
  do
    meganDataFile=${workDir}/wrfbiochemi_d${domain}_${projectTag}
    mv wrfbiochemi_d${domain} ${meganDataFile}
  done
fi

julday=$(date -u --date="__inpDateTxt__" '+%-j')
for domain in $(seq -f "0%g" 1 ${max_dom})
do
  meganDataFile=${workDir}/wrfbiochemi_d${domain}_${projectTag}
  ncatted -a START_DATE,global,o,c,"__inpDate__" \
          -a SIMULATION_START_DATE,global,o,c,"__inpDate__" \
          -a JULYR,global,o,i,__inpYear__ \
          -a JULDAY,global,o,i,${julday} \
          ${meganDataFile} wrfbiochemi_d${domain}
  ncks -A -v Times wrfinput_d${domain} wrfbiochemi_d${domain}
done

msg "wesely"
ln -s ${WRFmztoolsdir}/* .
./wesely < wesely.inp > wesely.out
msg "exo_coldens"
./exo_coldens < exo_coldens.inp > exo_coldens.out

# -----------------------------------------------------------------------------
# 4.a) emissions - EDGARHTAP
# -----------------------------------------------------------------------------

msg "emissions - anthro"

# anthropogenic emissions
#ln -s ${WRFanthrodir}/anthro_emis .
#./anthro_emis < anthro_emis.inp > anthro_emis.out

# apply diurnal cycle
#ln -s ${WRFemitdir}/* .
#ncl MAIN_emission_processing.ncl > diurnal_emiss.out
#python sum_sector_emiss_wrfchemi.py >> diurnal_emiss.out

# -----------------------------------------------------------------------------
# 4.a) anthropogenic emissions - GBD
# -----------------------------------------------------------------------------

ln -s ${WRFanthrodir}/anthro_emis .

# first run for GBDMAPS
./anthro_emis < anthro_emis.inp > anthro_emis_gbdmaps.out
# rename to *_gbdmaps
mv wrfchemi_00z_d01 wrfchemi_00z_d01_gbdmaps
mv wrfchemi_12z_d01 wrfchemi_12z_d01_gbdmaps

# then run for EDGARHTAP2.2 for CO, NH3, and C2H2
./anthro_emis < ${chainDir}/emis_gbdmapsworkinggroup-edgarhtap-co-nh3-c2h2-ch4_mozmos.inp > anthro_emis_edgarhtap.out
# rename to *_edgarhtap
mv wrfchemi_00z_d01 wrfchemi_00z_d01_edgarhtap
mv wrfchemi_12z_d01 wrfchemi_12z_d01_edgarhtap

# combine files
cp wrfchemi_00z_d01_gbdmaps wrfchemi_00z_d01
cp wrfchemi_12z_d01_gbdmaps wrfchemi_12z_d01
ncks -A wrfchemi_00z_d01_edgarhtap wrfchemi_00z_d01
ncks -A wrfchemi_12z_d01_edgarhtap wrfchemi_12z_d01

# apply diurnal cycle
ln -s ${WRFemitdir}/* .
ncl MAIN_emission_processing.ncl > diurnal_emiss.out
python sum_sector_emiss_wrfchemi.py >> diurnal_emiss.out

# -----------------------------------------------------------------------------
# 4.b) Fire FINN emissions
# -----------------------------------------------------------------------------

msg "emissions - fire"

ln -s ${WRFfiredir}/fire_emis .
./fire_emis < fire_emis.inp > fire_emis.out

# -----------------------------------------------------------------------------
# 5) second real with chemistry
# -----------------------------------------------------------------------------

rm namelist.input
cp namelist.wrf.prep.real namelist.input

msg "second real - with chemistry"
${mpiCommandPre} ./real.exe

mkdir second_real_out
mv rsl* second_real_out

# -----------------------------------------------------------------------------
# 6) MOZART / IC/BC
# -----------------------------------------------------------------------------

msg "MOZART/WACCM"

ln -s $WRFMOZARTdir/mozbc .

# If daily MOZBC files use this portion (otherwise comment out)
#let totDays="((__spinupTime__+__fcstTime__)/24)+2"
#i=0
#for day in $(seq -w -2 $totDays)
#do
#  # date format stupidity
#  txty="${day} days"
#  if [ $day -lt 0 ]
#  then
#    txty="${day/-/} days ago"
#  fi
#
#  curDate=$(date -u --date="__inpYear__-__inpMonth__-__inpDay__ __inpHour__:00:00 ${txty}" "+%Y%m%d")
#
#  ln -s ${MOZARTdir}/MZ${curDate} ./moz$(printf "%04d" $i).nc
#  let i=i+1
#done

# If monthly MOZBC files use this portion (otherwise comment out)
# MOZART - pre 2018
ln -s ${MOZARTdir}/MZ2016nov2017jan ./moz0000.nc
ln -s ${MOZARTdir}/MZ2016dec ./moz0001.nc
ln -s ${MOZARTdir}/MZ2017jan ./moz0002.nc
# WACCM - post 2018
#ln -s ${MOZARTdir}/WACCM2018jan ./moz0000.nc
#ln -s ${MOZARTdir}/WACCM2018feb ./moz0001.nc
#ln -s ${MOZARTdir}/WACCM2018mar ./moz0002.nc

# first domain, always
./mozbc < mozbc_outer.inp > mozbc_bc.log

for domain in $(seq 2 ${max_dom})
do
  /bin/sed -s "s/__domain__/${domain}/" < mozbc_inner.inp > mozbc_inner_d${domain}.inp
  ./mozbc < mozbc_inner_d${domain}.inp > mozbc_inner_d${domain}.log
done

fi
# that stuff was for runs with chemistry only...
#^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
# -----------------------------------------------------------------------------
# 7) Bring over last restart file / main_restart
# -----------------------------------------------------------------------------

msg "bring over restart file from previous run"

for domain in $(seq -f "0%g" 1 ${max_dom})
do
  newRunRstFile=wrfrst_d${domain}___inpYear__-__inpMonth__-__inpDay_____inpHour__:00:00
  cp ${restartDir}/${newRunRstFile} ${newRunRstFile}
done

# -----------------------------------------------------------------------------

msg "bring over main_restart"
cp ${chainDir}/main_restart.bash .

msg "bring over postprocessing scripts to output"
cp ${chainDir}/{pp_concat_cf_regrid.py,pp_concat_cf_regrid.bash} ${archiveDir}/.

# ------------------------------------------------------------------------------

rm met_em*

msg "finished preprocessing"
