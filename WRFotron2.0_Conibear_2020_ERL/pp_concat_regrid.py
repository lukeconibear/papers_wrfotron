#!/usr/bin/env python3
exec(open('/nobackup/earlacoa/python/modules_python3.py').read())

# setup
year   = '2015' 
month  = '01'
res    = 0.25
domains = ['1', '2']
variables = ['PM2_5_DRY', 'o3', 'AOD550_sfc']

# find days in month
calender = {}
months = ['01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '12']
days   = ['31', '28', '31', '30', '31', '30', '31', '31', '30', '31', '30', '31']
for index, item in enumerate(months):
    calender.update({ months[index] : days[index] })

days = calender[month]

# account for leap year
if year in ['2004','2008','2012','2016'] and month == '02':
    days = '29'
 
# loop through days
for domain in domains:
    for variable in variables:
        for day in (["%.2d" % i for i in range(1,int(days)+1)]):
            # list all wrfout files
            path = os.getcwd()
            filelist = []
            filelist.extend(glob.glob(path + '/wrfout_d0' + domain + '_'+str(year)+'-'+str(month)+'-'+str(day)+'*'))
            filelist = sorted(filelist)

            # read files and extract
            ds = salem.open_mf_wrf_dataset(filelist)
            if (variable == 'PM2_5_DRY') or (variable == 'o3'):
                wrf = ds[variable].isel(bottom_top=0)
            elif variable == 'AOD550_sfc':
                wrf = ds[variable]

            ds.close()

            # regrid
            ds_out = xr.Dataset({'lat': (['lat'], np.arange(-60, 85, 0.25)), 'lon': (['lon'], np.arange(-180, 180, 0.25)),})
            regridder = xe.Regridder(wrf, ds_out, 'bilinear', reuse_weights=True)
            wrf_regrid = regridder(wrf)
            regridder.clean_weight_file()

            # save
            wrf_regrid.to_netcdf(path + '/wrfout_d0' + domain + '_global_'+str(res)+'deg_'+str(year)+'-'+str(month)+'-'+str(day)+'_' + variable + '.nc')

