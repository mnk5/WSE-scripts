# -*- coding: utf-8 -*-
"""
Created on Fri Jan 19 09:00:24 2024

Reads Velocity Vectors From a RAS plan HDF file

Note that before the plan is run, you must set the output options to write velocity vectors
plan window -> Options -> Output Options… -> HDF5 Write Parameters -> check Write Velocity data

This script reads a spcecified plan's HDF file and writes a csv of the x, y, Vx, and Vy data
The csv can be read into ArcMap using the Add xy data tool. 

Pairs with Schwinn dt incipient motion script

@author: Marissa
"""
import h5py
import numpy as np
import pandas as pd
import os

#%%
# Set working directory to project
os.chdir("C:/Egnyte/Shared/Projects/22-028 Rutledge_Johnson")

# Specify model results location
hdf_path = "C:/Egnyte/Shared/Projects/22-028 Rutledge_Johnson/Hydraulics/Updated_as_built_Runs_20240115/"

# Specify output location for csv files
out_path = "GIS/Data/Model Results/Existing/Incipient Motion/"

# Create a list of plan numbers and names, with 2 DIGITS for all plan numbers
plans = 

#%%
# Function to read face points and x and y velocity components from hdf5 file
def read_hdf5_datasets(file_path, mesh_name):
    with h5py.File(file_path, 'r') as hdf5_file:
        # Construct the paths for the datasets
        dataset_path_x_velocity = f"Results/Unsteady/Output/Output Blocks/Base Output/Unsteady Time Series/2D Flow Areas/{mesh_name}/Node Velocity - Velocity X"
        dataset_path_y_velocity = f"Results/Unsteady/Output/Output Blocks/Base Output/Unsteady Time Series/2D Flow Areas/{mesh_name}/Node Velocity - Velocity Y"
        dataset_path_geometry = f"Geometry/2D Flow Areas/{mesh_name}/FacePoints Coordinate"
        
        # Read the datasets
        data_x_velocity = hdf5_file[dataset_path_x_velocity][:]
        data_y_velocity = hdf5_file[dataset_path_y_velocity][:]
        data_geometry = hdf5_file[dataset_path_geometry][:]

    return {
        'cells_center_coordinate': data_geometry, 
        'x_velocity': data_x_velocity, 
        'y_velocity': data_y_velocity
    }

#%%
# Read points for given plan, change path to plan files
plan_num = "11"
plan_name = "20yr"

#Update
filepath = f"{hdf_path}JanRoad.p{plan_num}.hdf"
mesh_name = "FlowArea"

hdf_data = read_hdf5_datasets(filepath, mesh_name)

# Get last time step of velocity (for steady state) for x and y and add to cell coordinates
x_vel = hdf_data['x_velocity'][:, -1]
y_vel = hdf_data['y_velocity'][:, -1]

points = np.transpose(hdf_data['cells_center_coordinate'])

Vel_points = np.column_stack((points, x_vel, y_vel))
Vel_points_df = pd.DataFrame(Vel_points, columns=["x", "y", "Vx", "Vy"])

# Write to CSV
output_filename = f"{out_path}VelPoints_{plan_name}.csv"
Vel_points_df.to_csv(output_filename, index=False)