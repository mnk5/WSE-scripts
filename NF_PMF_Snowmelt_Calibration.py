# North Fork Dam Snowmelt Calibration

"""
Tool to assess long term snowmelt calibration from HEC-HMS model

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
import hydroeval as he
from sklearn.metrics import mean_squared_error

# Set working directory
os.chdir("G:/Shared drives/Projects/24-027 North Fork Dam PMF Study/Hydrology/Snowmelt Calibration Results/TEST")

# Function to clean and process a single CSV file
def process_csv(file_name):
    with open("{}.csv".format(file_name), 'r') as file:
        lines = file.readlines()

    # Replace ", ,"
    lines = [line.replace(', ,', ',-901,') for line in lines]
    lines = [line.replace(', ,', ',-901,') for line in lines]

    # Open the file in write mode
    with open("{}.csv".format(file_name), 'w') as file:
        # Write the modified data back to the file
        file.writelines(lines)

    # Load csvs of results
    colnames = ['Index', 'Date', 'Time', "Cl_Obs_SWE", "PV_Obs_SWE", "Cl_Precip", "PV_Precip",
                "Cl_Temp", "PV_Temp", "Cl_SWE", "PV_SWE"]
    hourly_df = pd.read_csv("{}.csv".format(file_name), names=colnames, skiprows=52615)

    # Data cleaning
    hourly_df.replace(-901, np.nan, inplace=True)
    hourly_df.iloc[:, 3:10] = hourly_df.iloc[:, 3:10].astype(float)
    hourly_df['Time'] = hourly_df['Time'].replace(' 24:00', ' 00:00')

    # Combine date and time columns into a single date-time column
    hourly_df['date_time'] = pd.to_datetime(hourly_df['Date'] + hourly_df['Time'])
    hourly_df.set_index('date_time', inplace=True)

    # Convert to daily
    daily_df_Cl = pd.DataFrame()
    daily_df_PV = pd.DataFrame()

    daily_df_Cl['SWE'] = hourly_df['Cl_SWE'].resample('D').first()
    daily_df_PV['SWE'] = hourly_df['PV_SWE'].resample('D').first()
    daily_df_Cl['Obs_SWE'] = hourly_df['Cl_Obs_SWE'].resample('D').first()
    daily_df_PV['Obs_SWE'] = hourly_df['PV_Obs_SWE'].resample('D').first()
    daily_df_Cl['Precip'] = hourly_df['Cl_Precip'].resample('D').sum()
    daily_df_PV['Precip'] = hourly_df['PV_Precip'].resample('D').sum()
    daily_df_Cl['Temp'] = hourly_df['Cl_Temp'].resample('D').mean()
    daily_df_PV['Temp'] = hourly_df['PV_Temp'].resample('D').mean()

    return {'Clackamas': daily_df_Cl, 'Peavine': daily_df_PV}

# List of CSV files to process
csv_files = ['TI', 'EB']
all_daily_dfs = {}
all_error_stats = pd.DataFrame()

# Process each CSV file
for csv_file in csv_files:
    daily_dfs = process_csv(csv_file)
    all_daily_dfs[csv_file] = daily_dfs
    error_stats = pd.DataFrame()

    # Apply all filtering to both sites independently
    for key, daily_df in daily_dfs.items():
        # Add melt columns
        daily_df["Melt"] = daily_df['SWE'].diff()
        daily_df["Obs_Melt"] = daily_df['Obs_SWE'].diff()

        # Add melt error
        daily_df["Melt_Error"] = daily_df["Melt"] - daily_df["Obs_Melt"]

        # Remove days where Obs or modeled SWE is zero
        daily_df = daily_df[(daily_df['SWE'] != 0) & (daily_df['Obs_SWE'] > 0)]

        plt.figure()
        plt.hist(daily_df['Melt_Error'], bins=20)
        plt.title('SWE Change Error, {} {}'.format(csv_file, key))

        # Compute SWE error stats
        error_stats.at[csv_file + " " + key, "NSE"] = he.evaluator(he.nse, daily_df['SWE'], daily_df['Obs_SWE'])[0]
        error_stats.at[csv_file + " " + key, "RMSE"] = np.sqrt(mean_squared_error(daily_df['Obs_SWE'], daily_df['SWE']))
        error_stats.at[csv_file + " " + key, "Mean Diff"] = daily_df["Melt_Error"].mean()

        # Filter to only wet days
        wet_df = daily_df[(daily_df['Precip'] != 0)]

        plt.figure()
        plt.hist(wet_df['Melt_Error'], bins=20)
        plt.title('Wet SWE Change Error, {} {}'.format(csv_file, key))

        # Compute wet SWE error stats
        error_stats.at[csv_file + " " + key, "Wet NSE"] = he.evaluator(he.nse, wet_df['SWE'], wet_df['Obs_SWE'])[0]
        error_stats.at[csv_file + " " + key, "Wet RMSE"] = np.sqrt(mean_squared_error(wet_df['Obs_SWE'], wet_df['SWE']))
        error_stats.at[csv_file + " " + key, "Wet Mean Diff"] = wet_df["Melt_Error"].mean()

        # Filter to only OBSERVED wet melting days
        melt_df = wet_df[(wet_df['Obs_Melt'] < 0)]

        plt.figure()
        plt.hist(melt_df['Melt_Error'], bins=20)
        plt.title('Wet Melting Only Error, {} {}'.format(csv_file, key))

        # Compute wet melt error stats
        error_stats.at[csv_file + " " + key, "Wet Melt NSE"] = he.evaluator(he.nse, melt_df['SWE'], melt_df['Obs_SWE'])[0]
        error_stats.at[csv_file + " " + key, "Wet Melt RMSE"] = np.sqrt(mean_squared_error(melt_df['Obs_SWE'], melt_df['SWE']))
        error_stats.at[csv_file + " " + key, "Wet Melt Mean Diff"] = melt_df["Melt_Error"].mean()

        daily_dfs[key] = daily_df

    all_error_stats = pd.concat([all_error_stats, error_stats], axis=0)

# Access all results
print(all_daily_dfs)
print(all_error_stats)


# Get rid of no snow days

