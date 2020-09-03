# Math functions on ASCII of Precip files

library(RSAGA)

# Read in data
setwd("C:/Egnyte/Private/marissa/Projects/19-029 Viva Naughton Probable Maximum Flood Inflow Determination/GIS/Data/Gridded_Precip/Snowmelt/ASCII")

# read ascii grids exported from GIS
header <- read.ascii.grid.header("may_hitemp.asc")

May_HiTemp <- read.ascii.grid("may_hitemp.asc", return.header = F)
May_LoTemp <- read.ascii.grid("may_lotemp.asc", return.header = F)
Jun_HiTemp <- read.ascii.grid("jun_hitemp.asc", return.header = F)
Jun_LoTemp <- read.ascii.grid("jun_lotemp.asc", return.header = F)


############# Temperature Time Series ######################

# create hour sequence
hours <- seq(0, 23, 1)


# define time series function
temp.timeseries <- function(hr, HiGrid, LoGrid) {
  if (hr < 10){
    temp.grid <- (-((HiGrid - LoGrid)/2) * cos(hr*pi/9) + ((HiGrid + LoGrid)/2))
  } else {
    temp.grid <- (((HiGrid - LoGrid)/2) * cos((hr-10)*pi/13) + ((HiGrid + LoGrid)/2))
  }
  return(temp.grid)
}

# calculate with grids
May_Temp_series <- list()
Jun_Temp_series <- list()

for (hour in hours){
    May_Temp_series[[hour+1]] <- temp.timeseries(hour, May_HiTemp, May_LoTemp)
    Jun_Temp_series[[hour+1]] <- temp.timeseries(hour, Jun_HiTemp, Jun_LoTemp)
}


################## WRITE TO ASCII #################


setwd("./Temp_timeseries")


for (hr in hours){
  filename_may <- sprintf("Hour_%02.0f_MayTemp.asc", hr)
  filename_jun <- sprintf("Hour_%02.0f_JunTemp.asc", hr)
  
  write.ascii.grid(May_Temp_series[[hr+1]], filename_may, header = header, hdr.digits = 0)
  write.ascii.grid(Jun_Temp_series[[hr+1]], filename_jun, header = header, hdr.digits = 0)
}

