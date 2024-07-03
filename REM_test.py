# -*- coding: utf-8 -*-
"""
Created on Thu May 16 10:49:36 2024

@author: Marissa
"""
# River REM Toolbox

from riverrem.REMMaker import REMMaker
import os

os.chdir("C:/Users/Marissa/Documents/Personal/REM")

#set DEM and options like output, stream centerline
rem_maker = REMMaker(dem = 'Gunnison_DEM.tif') 

#make REM
rem_maker.make_rem()

rem_maker.make_rem_viz()

