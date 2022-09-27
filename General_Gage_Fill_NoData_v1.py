# -*- coding: utf-8 -*-
"""
USGS_Gage_Fill_NoData_v1.py

This script fills gaps in discontinuous USGS gage data to create a continuous 
record. The user may specify a gap duration threshold below which the discharge 
values are linearly interpolated between starting and ending values. Longer 
duration gaps in the timeseries are filled with no data (i.e. '-901').   

This script has been modified to able to fill data other than USGS gage data.
The character that starts each line of data (which must not start a header line)
must be specified and the date format in the input file must be specified - it
will automatically output in date format '%Y-%m-%d %H:%M' but this can be edited. 
The delimeter (tab versus comma or other) must also be specified.

  
"""

import os
from datetime import datetime, timedelta
import numpy as np

# provide file information
os.chdir(r'C:\working')
filename='HamsFork_Daily.txt'
Qcol= 4
TScol=3
timestep=1440 # in minutes
MaxGap=1440 # in minutes
FirstCharacter = 'U' # For USGS data, 'U'
DateFormat = '%Y-%m-%d' # For USGS data, '%Y-%m-%d %H:%M'
delimiter = '\t' # For USGS data, '\t'

# create variables
date_str=[];
discharge=[];
dobj=[];

# Read in data
f=open(filename,'r')
a=f.readlines()
f.close()
for line in a:
    
    if line[0]== FirstCharacter:  
        try:
            discharge.append(float(line.split(delimiter)[Qcol-1]))
        except ValueError:
            discharge.append(-901)
        if line.split(delimiter)[TScol]=='PDT': #account for PDT/PST
            date_object=datetime.strptime(line.split(delimiter)[TScol-1], DateFormat)-timedelta(hours=1)
        else:
            date_object=datetime.strptime(line.split(delimiter)[TScol-1], DateFormat)            
        dobj.append(date_object)   
print("Finished reading data")       

# print data for check
st_time=dobj[0]   #datetime.strptime(date_str[0],'%Y-%m-%d %H:%M')
end_time=dobj[-1] #datetime.strptime(date_str[-1],'%Y-%m-%d %H:%M')
delta=timedelta(minutes=timestep)
print("Check correct columns were read...")
print("Timeseries start = %s" %(st_time))
print("Discharge start = %.1f" %(discharge[0]))

# create complete time series of 15 min (above) with no gaps
times = []    
tobj=[]
while st_time < end_time:
    times.append(st_time.strftime('%Y-%m-%d %H:%M'))
    tobj.append(st_time)
    st_time += delta
    
Num_missing = len(tobj)-len(dobj)
print("%i total missing observations" %Num_missing)    
          
# fill gaps - this looks for all time slots with no data and inserts -901
print("Start filling all gaps in timeseries (this takes a while)")  
n=0;
Q=[];      
for i in range(len(times)):
    if dobj[n]==tobj[i]:
        Q.append(discharge[n])
        n=n+1;
    else:
        try:
            j=dobj.index(tobj[i])
        except ValueError:
             j=[]
        if j:
            Q.append(discharge[j])
            n=j+1
        else:
            Q.append(-901)
    if 1*i/float(int(len(times)/10)) % 1 == 0:
        print("%i percent complete..." %(10*i/float(int(len(times)/10))))
print("Finished filling gaps")     

#Interpolation routine- this looks for runs of 3hrs of -901
print("Start interpolating gaps in timeseries")
Qni=list(Q);
Qi=list(Q)
j=1
TS_gap=int(MaxGap/timestep)
s=0

while j:
    try:
        k=Q[j+1:].index(-901)
        j=j+k+1 # replace j 
        i=1
        while Q[j+i]==-901:
            i=i+1
        if i<=TS_gap: #if the gap in timeseries is less than or equal to max gap
                #interp lines
                Q[j:j+i]=np.interp(range(1,i+3),[1,i+2],[Q[j-1],Q[j+i]])[1:-1]
                j=j+i
                s=s+1
        else:
                j=j+i
    except ValueError:
        j=[]
        break  
print("Finished interpolation")   
print("%i gaps filled" %s)   
    
# Write File
f = open(filename[:-4]+'_filled.csv', 'w')
for i in range(len(times)):
    f.write("{},{}\n".format(times[i], Q[i]))
f.close()
print("File write complete ('%s_filled.csv')" %filename[:-4])   






