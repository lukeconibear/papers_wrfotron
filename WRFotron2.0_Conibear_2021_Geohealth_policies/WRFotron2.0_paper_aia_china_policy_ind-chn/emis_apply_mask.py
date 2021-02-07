#!/usr/bin/env python3
import pandas as pd
import numpy as np
import xarray as xr
import geopandas as gpd
import os
from rasterio import features
from affine import Affine
import descartes
import matplotlib.pyplot as plt
from wrf import getvar, ALL_TIMES
from netCDF4 import Dataset
import regionmask
from shapely.geometry import Polygon
import salem
import skimage
import glob
from pathlib import Path

# select simulation
#sim = 'res'
#sim = 'ind'
sim = 'ags'
#sim = 'tro'

# define functions
def transform_from_latlon(lat, lon):
    """ input 1D array of lat / lon and output an Affine transformation
    """
    lat = np.asarray(lat)
    lon = np.asarray(lon)
    trans = Affine.translation(lon[0], lat[0])
    scale = Affine.scale(lon[1] - lon[0], lat[1] - lat[0])
    return trans * scale


def rasterize(shapes, coords, latitude='latitude', longitude='longitude',
              fill=np.nan, **kwargs):
    """Rasterize a list of (geometry, fill_value) tuples onto the given
    xray coordinates. This only works for 1d latitude and longitude
    arrays.

    usage:
    -----
    1. read shapefile to geopandas.GeoDataFrame
          `states = gpd.read_file(shp_dir+shp_file)`
    2. encode the different shapefiles that capture those lat-lons as different
        numbers i.e. 0.0, 1.0 ... and otherwise np.nan
          `shapes = (zip(states.geometry, range(len(states))))`
    3. Assign this to a new coord in your original xarray.DataArray
          `ds['states'] = rasterize(shapes, ds.coords, longitude='X', latitude='Y')`

    arguments:
    ---------
    : **kwargs (dict): passed to `rasterio.rasterize` function

    attrs:
    -----
    :transform (affine.Affine): how to translate from latlon to ...?
    :raster (numpy.ndarray): use rasterio.features.rasterize fill the values
      outside the .shp file with np.nan
    :spatial_coords (dict): dictionary of {"X":xr.DataArray, "Y":xr.DataArray()}
      with "X", "Y" as keys, and xr.DataArray as values

    returns:
    -------
    :(xr.DataArray): DataArray with `values` of nan for points outside shapefile
      and coords `Y` = latitude, 'X' = longitude.


    """
    transform = transform_from_latlon(coords[latitude], coords[longitude])
    out_shape = (len(coords[latitude]), len(coords[longitude]))
    raster = features.rasterize(shapes, out_shape=out_shape,
                                fill=fill, transform=transform,
                                dtype=float, **kwargs)
    spatial_coords = {latitude: coords[latitude], longitude: coords[longitude]}
    return xr.DataArray(raster, coords=spatial_coords, dims=(latitude, longitude))


# combine shapefile - do once, if havent done already
#shp_path = Path('/nfs/a336/earlacoa/emissions/CAMS/shapefiles/')
#shapefiles = shp_path.glob("*.shp")
#gdf = pd.concat([gpd.read_file(shp) for shp in shapefiles]).pipe(gpd.GeoDataFrame)
#gdf.to_file(folder / 'prd_compiled.shp')

# open shapefiles
shp                  = gpd.read_file('/nfs/a336/earlacoa/emissions/CAMS/shapefiles/prd_compiled.shp')
shp_prd_prefectures  = gpd.read_file('/nfs/a336/earlacoa/emissions/CAMS/shapefiles/prd_prefectures.shp') # load this one too for the map showing

# create list of tuples (shapely.geometry, id) to allow for many different polygons within a .shp file
shapes = [(shape, n) for n, shape in enumerate(shp.geometry)]

# per scenario, edit species using mask
if sim == 'res':
    # residential (reduce PM emissions from rural solid fuel use for cooking around GBA).
    # oc (-100%), bc (100%), and voc (-90%) to simulate removing solid fuels
    species = ('*bc*', '*_oc_*')
    emis_files = []
    for emis_file in species:
	    emis_files.extend(glob.glob('/nfs/a336/earlacoa/emissions/CAMS/with_date_2016/' + sim + '/' + emis_file))


    for emis_file in emis_files:
	    print(emis_file)
	    # open emission inventory
	    emis = salem.xr.open_dataset(emis_file)
	    # extra sector
	    sec = emis[sim]
	    # create a new coord for the shapefile
	    sec["prd"] = rasterize(shapes, sec.coords, longitude='lon', latitude='lat')
	    # apply masked values to shapefile area
	    # to edit emissions outside of prd only - when inside prd (sec.prd>0) do nothing, otherwise multiply sec by any factor
	    #sec = sec.where(sec.prd>0, other=sec*0.9)
	    # to edit emissions inside of prd only - when outside prd (sec.prd==np.nan) do nothing, otherwise multiply sec by any factor
	    sec = sec.where(sec.prd==np.nan, other=sec*0)
	    # quick plot of jan
	    #sec = sec.salem.subset(shape=shp_prd_prefectures, margin=10) # set map to only show the prd region
	    #sec.isel(time=0).salem.quick_map()
	    #plt.show()
	    # replace sector within emission inventory
	    emis[sim] = sec
	    # save new emission file
	    print('writing updated: ', emis_file[:-3] + '_res.nc')
	    emis.to_netcdf(emis_file[:-3] + '_res.nc')
	    emis.close()


    emis_files = []
    emis_files.extend(glob.glob('/nfs/a336/earlacoa/emissions/CAMS/with_date_2016/' + sim + '/*voc*'))
    for emis_file in emis_files:
	    print(emis_file)
	    # open emission inventory
	    emis = salem.xr.open_dataset(emis_file)
	    # extra sector
	    sec = emis[sim]
	    # create a new coord for the shapefile
	    sec["prd"] = rasterize(shapes, sec.coords, longitude='lon', latitude='lat')
	    # apply masked values to shapefile area
	    # to edit emissions outside of prd only - when inside prd (sec.prd>0) do nothing, otherwise multiply sec by any factor
	    #sec = sec.where(sec.prd>0, other=sec*0.9)
	    # to edit emissions inside of prd only - when outside prd (sec.prd==np.nan) do nothing, otherwise multiply sec by any factor
	    sec = sec.where(sec.prd==np.nan, other=sec*0.1)
	    # quick plot of jan
	    #sec = sec.salem.subset(shape=shp_prd_prefectures, margin=10) # set map to only show the prd region
	    #sec.isel(time=0).salem.quick_map()
	    #plt.show()
	    # replace sector within emission inventory
	    emis[sim] = sec
	    # save new emission file
	    print('writing updated: ', emis_file[:-3] + '_' + sim + '.nc')
	    emis.to_netcdf(emis_file[:-3] + '_' + sim + '.nc')
	    emis.close()

 
if sim == 'ind':
    # reduce all industrial VOC emissions by 10%
    emis_files = []
    emis_files.extend(glob.glob('/nfs/a336/earlacoa/emissions/CAMS/with_date_2016/' + sim + '/*voc*'))
    for emis_file in emis_files:
        print(emis_file)
        # open emission inventory
        emis = salem.xr.open_dataset(emis_file)
        # extra sector
        sec = emis[sim]
        # create a new coord for the shapefile
        sec["prd"] = rasterize(shapes, sec.coords, longitude='lon', latitude='lat')
        # apply masked values to shapefile area
        # to edit emissions outside of prd only - when inside prd (sec.prd>0) do nothing, otherwise multiply sec by any factor
        #sec = sec.where(sec.prd>0, other=sec*0.9)
        # to edit emissions inside of prd only - when outside prd (sec.prd==np.nan) do nothing, otherwise multiply sec by any factor
        sec = sec.where(sec.prd==np.nan, other=sec*0.9)
        # quick plot of jan
        #sec = sec.salem.subset(shape=shp_prd_prefectures, margin=10) # set map to only show the prd region
        #sec.isel(time=0).salem.quick_map()
        #plt.show()
        # replace sector within emission inventory
        emis[sim] = sec
        # save new emission file
        print('writing updated: ', emis_file[:-3] + '_' + sim + '.nc')
        emis.to_netcdf(emis_file[:-3] + '_' + sim + '.nc')
        emis.close()


if sim == 'ags':
    # reduce ammonia emissions from agricultural soil by 30%
    emis_files = []
    emis_files.extend(glob.glob('/nfs/a336/earlacoa/emissions/CAMS/with_date_2016/' + sim + '/*nh3*'))
    for emis_file in emis_files:
        print(emis_file)
        # open emission inventory
        emis = salem.xr.open_dataset(emis_file)
        # extra sector
        sec = emis[sim]
        # create a new coord for the shapefile
        sec["prd"] = rasterize(shapes, sec.coords, longitude='lon', latitude='lat')
        # apply masked values to shapefile area
        # to edit emissions outside of prd only - when inside prd (sec.prd>0) do nothing, otherwise multiply sec by any factor
        #sec = sec.where(sec.prd>0, other=sec*0.9)
        # to edit emissions inside of prd only - when outside prd (sec.prd==np.nan) do nothing, otherwise multiply sec by any factor
        sec = sec.where(sec.prd==np.nan, other=sec*0.7)
        # quick plot of jan
        #sec = sec.salem.subset(shape=shp_prd_prefectures, margin=10) # set map to only show the prd region
        #sec.isel(time=0).salem.quick_map()
        #plt.show()
        # replace sector within emission inventory
        emis[sim] = sec
        # save new emission file
        print('writing updated: ', emis_file[:-3] + '_' + sim + '.nc')
        emis.to_netcdf(emis_file[:-3] + '_' + sim + '.nc')
        emis.close()


if sim == 'tro':
    # reduce ammonia emissions from agricultural soil by 30%
    emis_files = []
    emis_files.extend(glob.glob('/nfs/a336/earlacoa/emissions/CAMS/with_date_2016/' + sim + '/*nox*'))
    for emis_file in emis_files:
        print(emis_file)
        # open emission inventory
        emis = salem.xr.open_dataset(emis_file)
        # extra sector
        sec = emis[sim]
        # create a new coord for the shapefile
        sec["prd"] = rasterize(shapes, sec.coords, longitude='lon', latitude='lat')
        # apply masked values to shapefile area
        # to edit emissions outside of prd only - when inside prd (sec.prd>0) do nothing, otherwise multiply sec by any factor
        #sec = sec.where(sec.prd>0, other=sec*0.9)
        # to edit emissions inside of prd only - when outside prd (sec.prd==np.nan) do nothing, otherwise multiply sec by any factor
        sec = sec.where(sec.prd==np.nan, other=sec*0.05)
        # quick plot of jan
        #sec = sec.salem.subset(shape=shp_prd_prefectures, margin=10) # set map to only show the prd region
        #sec.isel(time=0).salem.quick_map()
        #plt.show()
        # replace sector within emission inventory
        emis[sim] = sec
        # save new emission file
        print('writing updated: ', emis_file[:-3] + '_' + sim + '.nc')
        emis.to_netcdf(emis_file[:-3] + '_' + sim + '.nc')
        emis.close()



