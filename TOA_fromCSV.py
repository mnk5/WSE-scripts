# -*- coding: utf-8 -*-
"""
Created on Wed Feb 19 10:19:44 2020

@author: Marissa
"""

import os
import pandas as pd

# set directory for inputs and outputs (adjust as needed)
path = "C:/Egnyte/Private/marissa/Projects/19-039 Klamath Inundation Mapping Revisions/Modeling/Excel/Modeling and Mapping Revisions/DSS_Export"
os.chdir(path)

# Make Vector of required XS values    
Keno_XS = [234.844,233.474,231.474,229.974,229.45,228.974,227.974,226.974,226.430,226.179,224.474,223.216,
           221.695,220.974,219.140,217.268,216.249,214.974,214.474,212.245,210.474,209.242,208.690,208.474,207.505,
           206.452,205.674,204.174,202.186,201.156,200.102,199.891,199.57,197.446,193.581,191.864,191.64,
           191.151,186.033,180.675,178.563,178.188,176.339,166.757,161.242,157.424,150.377,142.116,133.682,
           129.586,123.987,108.381,107.368,106.302,99.1,94.632,89.126,83.835,78.716,71.033,65.826,59.799,
           58.812,49.185,43.137,39.64,35.373,25.418,23.48,16.047,10.822,6.618,3.614,0.661]
JCB_XS = Keno_XS[9:]
Copco_XS = JCB_XS[22:]
IG_XS = Copco_XS[5:]

XS_dict = {'KENO': Keno_XS,
           'JCB' : JCB_XS,
           'COP': Copco_XS,
           'IRNGT':  IG_XS}

flow_list = ['PMF', 'FW'] 
dam_list = ['KENO', 'JCB', 'COP', 'IRNGT']
TOA_dict = {}

# set threshold for stage difference (ft) to indicate TOA
threshold = 0.01

# define first greater function
def first_greater(df, n):
    m = df.ge(n)
    return m.any() and m.idxmax()
 

# Loop over PMF and Fair Weather runs
for dam in dam_list:
    
    # loop over dams
     
    for flow in flow_list:
        
        #chose appropriate XS list for dam
        XS_list = XS_dict[dam]
        
        # create file name for dam and flow
        f_file = '{}_{}_F.txt'.format(flow, dam)
        nf_file = '{}_{}_NF.txt'.format(flow, dam)
        
        # read files into dataframe
        fail  = pd.read_csv(f_file, sep = ",", header = 1)
        no_fail = pd.read_csv(nf_file, sep = ",", header = 1)
        
        # get only XS data (no date/time)
        fail_data = fail.iloc[:, 2:]
        nofail_data = no_fail.iloc[:, 2:]
        
        # difference the failure and no fail stage data
        difference = fail_data.subtract(nofail_data, fill_value = 0)
        
        # combine date and time into single list
        time_comb = fail['Type'] + fail[' ']
        
        # loop over columns (cross sections)
        i = 0
        time_df = list()
        
        
        while i < len(difference.columns):
            
            # select column of a single cross section
            idx_df = difference[difference.columns[i]]
            
            # find index of first time difference is above threshold
            idx = first_greater(idx_df, threshold)
            
            # find time of the first difference
            time_df.append(time_comb[idx])
            
            i+=1
        
        # get times for PMF and FW runs
        if flow == 'PMF':
            time_pmf = time_df
        else: 
            time_fw = time_df
    
    # Combine data into single dataframe      
    df = pd.DataFrame(
            {'XS': XS_list,
             'TOA_PMF': time_pmf,
             'TOA_FW': time_fw})
    
    # write to text file
    TOA_filename = "{}/{}_{}_TOA.csv".format(path,flow,dam)        
    df.to_csv(TOA_filename)

# save all data to one dictionary    
    TOA_dict[dam]  = df      
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            