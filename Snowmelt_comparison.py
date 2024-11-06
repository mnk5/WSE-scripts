
# North Fork Dam Snowmelt Calibration

"""
Tool to assess long term snowmelt calibration from HEC-HMS model

- Uses package pydsstools to read DSS results files
- Re-samples to daily SWE
- Removes days where either obs OR modeled have no SWE
- Computes daily total melt
- Filters for wet days
- Filters for melting only 
- creates scatter plots and histograms of difference

M. Karpack, 8/27/2024

"""

import os
import numpy as np
import pandas as pd
from datetime import datetime, timedelta
import matplotlib.pyplot as plt
from pydsstools.heclib.dss import HecDss

# Set working directory
os.chdir("G:/Shared drives/Projects/24-027 North Fork Dam PMF Study/Hydrology/NF_PMF")

###################################
# Specify and load results

# Set path names to results    
TI_path_sets = [
    [
        "//Clackamas Lake/SWE//1Hour/RUN:Temperature Index/",
        "//Clackamas Lake/SWE-OBSERVED//1Hour/RUN:Temperature Index/",
        "//Clackamas Lake/TEMPERATURE-AIR//1Hour/RUN:Temperature Index/",
        #"//Clackamas Lake/PRECIP_INC//1Hour/PRECIP/"
    ],
    [
        "//Peavine Ridge/SWE//1Hour/RUN:Temperature Index/",
        "//Peavine Ridge/SWE-OBSERVED//1Hour/RUN:Temperature Index/",
        "//Peavine Ridge/TEMPERATURE-AIR//1Hour/RUN:Temperature Index/",
        #"//Peavine Ridge/PRECIP_INC//1Hour/PRECIP/"

    ],
]

EB_path_sets = [
    [
        "//Clackamas Lake/SWE//1Hour/RUN:Energy Budget/",
        "//Clackamas Lake/SWE-OBSERVED//1Hour/RUN:Energy Budget/",
        "//Clackamas Lake/TEMPERATURE-AIR//1Hour/RUN:Energy Budget/",
        #"//Clackamas Lake/PRECIP_INC//1Hour/MET:Energy Budget - SNOTEL Temp/"
    ],
    [
        "//Peavine Ridge/SWE//1Hour/RUN:Energy Budget/",
        "//Peavine Ridge/SWE-OBSERVED//1Hour/RUN:Energy Budget/",
        "//Peavine Ridge/TEMPERATURE-AIR//1Hour/RUN:Energy Budget/",
        #"//Peavine Ridge/PRECIP_INC//1Hour/MET:Energy Budget - SNOTEL Temp/"
    ],
]

# open temperature index data
TI_dss = HecDss.Open('Temperature_Index.dss')

ts = TI_dss.read_ts("//Peavine Ridge/PRECIP_INC//1Hour/PRECIP/")

# plt.plot(times[~ts.nodata],values[~ts.nodata],"o")
# plt.show()  
 
# Initialize a dictionary to store all data frames, list names
all_data_frames = {}
set_names = ["Clack_TI","Peavine_TI"]


# Loop through each set of pathnames
for set_index, CL_paths in enumerate(TI_path_sets):
    TI_df = pd.DataFrame()
    
    for path in CL_paths:
        ts = TI_dss.read_ts(path)
        times = np.array(ts.pytimes)
        values = ts.values
        TI_df["Time"] = times
        partF = path.split("/")[3]
        TI_df[partF] = values
    
    # Store the data frame in the dictionary with location name
    all_data_frames[set_names[set_index]] = TI_df

# open Energy Budget data
EB_dss = HecDss.Open('Energy_Budget.dss')
    
set_names = ["Clack_EB","Peavine_EB"]

# Loop through each set of pathnames
for set_index, CL_paths in enumerate(EB_path_sets):
    TI_df = pd.DataFrame()
    
    for path in CL_paths:
        ts = EB_dss.read_ts(path)
        times = np.array(ts.pytimes)
        values = ts.values
        TI_df["Time"] = times
        partF = path.split("/")[3]
        TI_df[partF] = values
    
    # Store the data frame in the dictionary with a unique key
    all_data_frames[set_names[set_index]] = TI_df 
    
    
##############################
# Data Filtering and Statistics
##############################

# Hourly data to daily data
daily_data = {}

for key, df in all_data_frames.items():
    # Ensure the index is a datetime index
    df.index = pd.to_datetime(df.index)
    
    daily_df = pd.DataFrame()
    daily_df['SWE'] = df['SWE'].resample('D').first()
    daily_df['SWE-OBSERVED'] = df['SWE-OBSERVED'].resample('D').first()
    #daily_df['PRECIP-INC'] = df['PRECIP-INC'].resample('D').sum()
    daily_df['TEMPERATURE-AIR'] = df['TEMPERATURE-AIR'].resample('D').mean()
    
    daily_data[key] = daily_df
# Compute Melt


    
# Filter for only times with snow in both modeled and observed

snow_data_frames = {key: df[(df[['SWE', 'SWE-OBSERVED']] != 0).all(axis=1)] 
                      for key, df in all_data_frames.items()}


