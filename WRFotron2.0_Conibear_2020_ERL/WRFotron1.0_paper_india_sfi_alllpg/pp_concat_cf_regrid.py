#!/usr/bin/env python2
from netCDF4 import Dataset
import cf, cfplot as cfp
from wrf import getvar, ALL_TIMES
import glob
import datetime
import os
import numpy as np
from collections import OrderedDict

# define
year   = '2016' 
month  = '02'
res    = 0.25

# find days in month (as this script wouldnt work for multiple days)
if month == '01':
    days = '31'
if month == '02':
    days = '28'
if month == '03':
    days = '31'
if month == '04':
    days = '30'
if month == '05':
    days = '31'
if month == '06':
    days = '30'
if month == '07':
    days = '31'
if month == '08':
    days = '31'
if month == '09':
    days = '30'
if month == '10':
    days = '31'
if month == '11':
    days = '30'
if month == '12':
    days = '31'
# account for leap year
if year in ['2004','2008','2012','2016']:
    if month == '02':
        days = '29'
        
# loop through days
for day in (["%.2d" % i for i in range(1,int(days)+1)]):
    # list all wrfout files
    path = os.getcwd()
    filelist = []
    filelist.extend(glob.glob(path + '/wrfout_d01_'+str(year)+'-'+str(month)+'-'+str(day)+'*'))
    filelist = sorted(filelist)

    # read in using netCDF
    wrflist = []
    for afile in filelist:
        wrflist.extend([Dataset(afile)])


    # extract lat, lon, and height from wrffile
    lat = getvar(wrflist, "XLAT", meta=False)[:,0]
    lon = getvar(wrflist, "XLONG", meta=False)[0,:]
    height = getvar(wrflist, "height", meta=False)[:,0,0]

    # patch dimensions
    x = cf.DimensionCoordinate(data=cf.Data(lon, units='degrees_east'), properties={'standard_name': 'longitude'})
    x.axis = 'X'
    y = cf.DimensionCoordinate(data=cf.Data(lat, units='degrees_north'), properties={'standard_name': 'latitude'})
    y.axis = 'Y'
    z = cf.DimensionCoordinate(data=cf.Data(height, units='m'), properties={'standard_name': 'height'})
    z.axis = 'Z'
    # create list of all datetimes in cf format
    wrf_datetime_list = []
    for index,item in enumerate(wrflist):
        wrf_datetime = cf.dt(datetime.datetime.strptime(str(getvar(wrflist[index], "Times", meta=False)), '%Y-%m-%dT%H:00:00.000000000'))
        wrf_datetime_list.extend([wrf_datetime])


    # create dimension out of the datetimes
    t = cf.DimensionCoordinate(data=cf.Data(wrf_datetime_list, units='hours since ' + str(wrf_datetime.year) + '-1-1'), properties={'standard_name': 'time'})
    t.axis = 'T'

    # define all the variables that I want to extract from wrfchem
    # additional variables that I want that cause issues = pres, rh, rh_2m
    # *** the issue before was that this list was going over two lines and was breaking ***
    # *** the issue before was that this list was going over 72 characters and breaking ***
    variables = ['PSFC','PBLH','RAINC','RAINNC','U10','V10','T','T2', \
    'TH2','ALT','HGT','SWDOWN','GSW','GLW','SWUPB','LWUPB','LH','HFX',\
    'QVAPOR','QRAIN','LU_INDEX','FIRESIZE_AGTF','FIRESIZE_AGEF',\
    'FIRESIZE_AGSV','FIRESIZE_AGGR','ebu_oc','AOD550_sfc','PM2_5_DRY',\
    'PM10','o3','co','so2','no','no2','nh3','bc_a01','bc_a02','bc_a03',\
    'bc_a04','oc_a01','oc_a02','oc_a03','oc_a04','num_a01','num_a02',\
    'num_a03','num_a04','water_a01','water_a02','water_a03','water_a04',\
    'so4_a01','so4_a02','so4_a03','so4_a04','no3_a01','no3_a02','no3_a03',\
    'no3_a04','nh4_a01','nh4_a02','nh4_a03','nh4_a04','asoaX_a01',\
    'asoaX_a02','asoaX_a03','asoaX_a04','asoa1_a01','asoa1_a02',\
    'asoa1_a03','asoa1_a04','asoa2_a01','asoa2_a02','asoa2_a03',\
    'asoa2_a04','asoa3_a01','asoa3_a02','asoa3_a03','asoa3_a04',\
    'asoa4_a01','asoa4_a02','asoa4_a03','asoa4_a04','bsoaX_a01',\
    'bsoaX_a02','bsoaX_a03','bsoaX_a04','bsoa1_a01','bsoa1_a02',\
    'bsoa1_a03','bsoa1_a04','bsoa2_a01','bsoa2_a02','bsoa2_a03',\
    'bsoa2_a04','bsoa3_a01','bsoa3_a02','bsoa3_a03','bsoa3_a04',\
    'bsoa4_a01','bsoa4_a02','bsoa4_a03','bsoa4_a04','glysoa_r1_a01',\
    'glysoa_r1_a02','glysoa_r1_a03','glysoa_r1_a04','glysoa_r2_a01',\
    'glysoa_r2_a02','glysoa_r2_a03','glysoa_r2_a04','glysoa_sfc_a01',\
    'glysoa_sfc_a02','glysoa_sfc_a03','glysoa_sfc_a04','glysoa_nh4_a01',\
    'glysoa_nh4_a02','glysoa_nh4_a03','glysoa_nh4_a04','glysoa_oh_a01',\
    'glysoa_oh_a02','glysoa_oh_a03','glysoa_oh_a04','na_a01','na_a02',\
    'na_a03','na_a04','ca_a01','ca_a02','ca_a03','ca_a04','hysw_a01',\
    'hysw_a02','hysw_a03','hysw_a04','cl_a01','cl_a02','cl_a03','cl_a04',\
    'co3_a01','co3_a02','co3_a03','co3_a04','oin_a01','oin_a02','oin_a03',\
    'oin_a04']

    # for all variables
    fl = cf.FieldList()
    for index,item in enumerate(variables):
        # create dynamic variable name
        name = "variable"
        exec(name + " = str(item)")
        print(variable)
        # concatenate variable over time, and extract
        cat = getvar(wrflist, variable, timeidx=ALL_TIMES, method="cat")
        # create cf field
        field = cf.Field(data=cf.Data(cat), properties={'standard_name':variable})
        # add dimension coordinates to cube - depending if the variable has a height dimension
        if len(field.axes()) == 4:
            field.insert_dim(t, 'dim0')
            field.insert_dim(z, 'dim1')
            field.insert_dim(y, 'dim2')
            field.insert_dim(x, 'dim3')

        if len(field.axes()) == 3:
            field.insert_dim(t, 'dim0')
            field.insert_dim(y, 'dim1')
            field.insert_dim(x, 'dim2')

        if len(field.axes()) == 2:
            field.insert_dim(y, 'dim0')
            field.insert_dim(x, 'dim1')

        # append the fields to the fieldlist
        fl.append(field)


    cf.write(fl, path + '/wrfout_cf-fieldlist_all-times-levels_'+str(year)+'-'+str(month)+'-'+str(day)+'.nc', verbose=True, fmt='NETCDF4')

    # regrid
    lon_regrid = cf.DimensionCoordinate(data=cf.Data(np.arange(-180,180,res), units='degrees_east')) 
    lat_regrid = cf.DimensionCoordinate(data=cf.Data(np.arange(-60,85,res), units='degrees_north')) 
    dst_regrid = {'longitude':lon_regrid, 'latitude':lat_regrid}

    pm25_regrid = fl.select('PM2_5*')[0].subspace[:,0,:,:].regrids(dst_regrid, method='bilinear')
    o3_regrid   = fl.select('o3')[0].subspace[:,0,:,:].regrids(dst_regrid, method='bilinear')
    aod_regrid  = fl.select('AOD*')[0].subspace[:,:,:].regrids(dst_regrid, method='bilinear')

    # save
    cf.write(pm25_regrid, path + '/wrfout_cf-fieldlist_all-times-surface-global-'+str(res)+'deg_'+str(year)+'-'+str(month)+'-'+str(day)+'_pm25.nc', verbose=True, fmt='NETCDF4')
    cf.write(o3_regrid, path + '/wrfout_cf-fieldlist_all-times-surface-global-'+str(res)+'deg_'+str(year)+'-'+str(month)+'-'+str(day)+'_o3.nc', verbose=True, fmt='NETCDF4')
    cf.write(aod_regrid, path + '/wrfout_cf-fieldlist_all-times-surface-global-'+str(res)+'deg_'+str(year)+'-'+str(month)+'-'+str(day)+'_aod.nc', verbose=True, fmt='NETCDF4')

