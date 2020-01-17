#!/bin/bash
#$ -P N8HPC_LDS_DVS_AQA             # project code
#$ -cwd -V                          # execute from current working directory and export all current environment variables to all spawned processes
#$ -l h_rt=48:00:00                 # The wall clock time which is the amount of real time needed by the job
#$ -pe ib 1                        # Specifies a job for parallel programs using MPI, nprocPre is the number of cores to be used by the parallel job

module load nco
module load ncl

ncrcat -v XLAT,XLONG,Times,P,PB,PH,PHB,PBLH,RAINC,RAINNC,W,T,T2,U,V,PSFC,ALT,SWDOWN,GSW,GLW,SWUPB,LWUPB,LH,HFX,ZNU,ZNW,pres,TH2,p_sl,pres,U10,V10,rh_2m,QVAPOR,F,QRAIN,HGT,P_TOP,LU_INDEX,AOD550_sfc,PM2_5_DRY,PM10,o3,co,so2,no2,bc_a01,bc_a02,bc_a03,bc_a04,oc_a01,oc_a02,oc_a03,oc_a04,num_a01,num_a02,num_a03,num_a04,water_a01,water_a02,water_a03,water_a04,so4_a01,so4_a02,so4_a03,so4_a04,no3_a01,no3_a02,no3_a03,no3_a04,nh4_a01,nh4_a02,nh4_a03,nh4_a04,smpa_a01,smpa_a02,smpa_a03,smpa_a04,smpbb_a01,smpbb_a02,smpbb_a03,smpbb_a04,glysoa_sfc_a01,glysoa_sfc_a02,glysoa_sfc_a03,glysoa_sfc_a04,na_a01,na_a02,na_a03,na_a04,biog1_o_a01,biog1_o_a02,biog1_o_a03,biog1_o_a04,biog1_c_a01,biog1_c_a02,biog1_c_a03,biog1_c_a04 --no_tmp_fl wrfout_d01_2014-04-* wrfout_paper2_no-bbu_2014_apr.nc

ncl 'file_in="wrfout_paper2_no-bbu_2014_mar.nc"' 'file_out="wrfout_paper2_no-bbu_2014_mar_cf.nc"' wrfout_to_cf_full.ncl
