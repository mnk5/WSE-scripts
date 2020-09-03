# Math functions on ASCII of Precip files

library(RSAGA)

# set units as "mm" or "inches" - mm will convert data
units <- "mm" 

# Read in data
setwd("C:/Egnyte/Private/marissa/Projects/19-029 Viva Naughton Probable Maximum Flood Inflow Determination/GIS/Data/Gridded_Precip/ASCII")

# read ascii grids exported from GIS
G_24 <- read.ascii.grid("g_24_vvn_albers.asc", return.header = T)
G_48 <- read.ascii.grid("g_24to48_vvn_albers.asc", return.header = T)
G_72 <- read.ascii.grid("g_48to72_vvn_albers.asc", return.header = T)
L_100 <- read.ascii.grid("l_vvn_100mi_albers.asc", return.header = T)
L_100_Hi <- read.ascii.grid("l_vvn_100mi_highpmp_albers.asc", return.header = T)

############# General Storm ######################

# Get day 1 and 3 from 24 hr to 15 min values
G_48_15min <- G_48$data/24/4
G_72_15min <- G_72$data/24/4

# reductions in PMP for May and June w snow
G_48_15min_May <- G_48_15min*0.868
G_72_15min_May <- G_72_15min*0.868

G_48_15min_June <- G_48_15min*0.943
G_72_15min_June <- G_72_15min*0.943


# non-dimensional scalars for 2nd day from CO-NM study
G_multipliers <- c(0.0025,0.0025,0.0024,0.0025,0.005,0.0051,0.0051,0.0051,0.0049,
                    0.005,0.0049,0.005,0.0074,0.0075,0.0074,0.0075,0.0076,0.0076,0.0076,0.0077,0.0099,0.01,0.0099,
                    0.0099,0.0124,0.0124,0.0124,0.0124,0.0127,0.0127,0.0127,0.0128,0.0149,0.0148,0.0149,0.0149,0.0149,
                    0.0149,0.0148,0.0149,0.0202,0.0203,0.0203,0.0203,0.0199,0.0198,0.0199,0.0198,0.0174,0.0173,0.0174,
                    0.0173,0.0178,0.0178,0.0178,0.0177,0.0149,0.0148,0.0149,0.0149,0.0149,0.0149,0.0148,0.0149,0.0128,
                    0.0127,0.0127,0.0127,0.0124,0.0124,0.0124,0.0124,0.0099,0.0099,0.01,0.0099,0.0077,0.0076,0.0076,0.0076,
                    0.0049,0.005,0.0049,0.005,0.0025,0.0025,0.0024,0.0025,0.0013,0.0013,0.0013,0.0012,0.0013,0.0012,0.0013,0.0012)

# Multiply largest 24 hr total by non-dimentional multipliers to get a grid for each 15 min
i <- 1
G_24_15min <-list()

for (value in G_multipliers){
  G_24_15min[[i]] <- G_24$data*value
  i <- i + 1
}

G_24_15min_May <- lapply(G_24_15min,function(x) x * 0.868)
G_24_15min_June <- lapply(G_24_15min,function(x) x * 0.943)

###################### LOCAL STORM ############################

# Non-dimensional multipliers for local storm from CO-NM study
L_multipliers <- c(0.0499,0.0499,0.0499,0.0499,0.0499,0.0499,0.0499,0.0499,0.0499,0.0499,0.0499,0.0499,0.0175,0.0168,0.0167,
                   0.0167,0.0168,0.0167,0.0167,0.0168,0.0167,0.0167,0.0168,0.0165,0.0083,0.0083,0.0083,0.0084,0.0083,0.0083,
                   0.0083,0.0083,0.0083,0.0084,0.0083,0.0083,0.0042,0.0041,0.0042,0.0041,0.0042,0.0042,0.0041,0.0042,0.0041,
                   0.0042,0.0041,0.0042,0.0025,0.0026,0.0025,0.0025,0.0025,0.0025,0.0025,0.0025,0.0025,0.0025,0.0026,0.0024,
                   0.0017,0.0017,0.0016,0.0017,0.0017,0.0016,0.0017,0.0016,0.0017,0.0017,0.0016,0.0017)

# Multiply 100 mi 6hr total by non-dimensional increments
i <- 1
L_100_5min <- list()
L_100_Hi_5min <- list()

for (value in L_multipliers){
  L_100_5min[[i]] <- L_100$data*value
  L_100_Hi_5min[[i]] <- L_100_Hi$data*value
  i <- i + 1
}


################## CONVERT AND WRITE TO ASCII #################

# Convert to mm if units are mm
if (units == "mm") {
  G_48_15min <- G_48_15min * 25.4
  G_72_15min <- G_72_15min * 25.4
  G_48_15min_May <- G_48_15min_May * 25.4
  G_72_15min_May <- G_72_15min_May * 25.4
  G_48_15min_June <- G_48_15min_June * 25.4
  G_72_15min_June <- G_72_15min_June * 25.4
  G_24_15min <- lapply(G_24_15min,function(x) x * 25.4)
  G_24_15min_May <- lapply(G_24_15min_May,function(x) x * 25.4)
  G_24_15min_June <- lapply(G_24_15min_June,function(x) x * 25.4)
  L_100_5min <- lapply(L_100_5min,function(x) x * 25.4)
  L_100_Hi_5min <- lapply(L_100_Hi_5min,function(x) x * 25.4)
}

# Make grid of zeros for after precip
Zero_grid <- ifelse(G_24$data>0, 0, G_24$data)

setwd("./15_min_grid")

# write one file for 15 min value for days 1 and 3 and after day 3
write.ascii.grid(G_48_15min,"Hour_1_to_24_15min.asc", header = G_48$header, hdr.digits = 0)  
write.ascii.grid(G_72_15min,"Hour_48_to_72_15min.asc", header = G_72$header, hdr.digits = 0)
write.ascii.grid(G_48_15min_May,"Hour_1_to_24_15min_May.asc", header = G_48$header, hdr.digits = 0)  
write.ascii.grid(G_72_15min_May,"Hour_48_to_72_15min_May.asc", header = G_72$header, hdr.digits = 0)
write.ascii.grid(G_48_15min_June,"Hour_1_to_24_15min_June.asc", header = G_48$header, hdr.digits = 0)  
write.ascii.grid(G_72_15min_June,"Hour_48_to_72_15min_June.asc", header = G_72$header, hdr.digits = 0)
write.ascii.grid(Zero_grid,"Hour_72_to_end_15min.asc", header = G_72$header, hdr.digits = 0)

G_sequence <- seq(24.25, 48, 0.25)

k <- 1
for (val in G_sequence){
  filename <- sprintf("Hour_%.2f_15min.asc", val)
  filename_may <- sprintf("Hour_%.2f_15min_May.asc", val)
  filename_june <- sprintf("Hour_%.2f_15min_June.asc", val)
  write.ascii.grid(G_24_15min[[k]], filename, header = G_24$header, hdr.digits = 0)
  write.ascii.grid(G_24_15min_May[[k]], filename_may, header = G_24$header, hdr.digits = 0)
  write.ascii.grid(G_24_15min_June[[k]], filename_june, header = G_24$header, hdr.digits = 0)
  k <- k+1
}

setwd("../5_min_grid")

L_sequence <- seq(5, 360, 5)

k <- 1
for (val in L_sequence){
  filename <- sprintf("Min_%.0f_5min.asc", val)
  filename_Hi <- sprintf("Min_%.0f_Hi_5min.asc", val)
  write.ascii.grid(L_100_5min[[k]], filename, header = L_100$header, hdr.digits = 0)
  write.ascii.grid(L_100_Hi_5min[[k]], filename_Hi, header = L_100_Hi$header, hdr.digits = 0)
  k <- k+1
}

write.ascii.grid(Zero_grid,"Min_365_to_end_5min.asc", header = L_100$header, hdr.digits = 0)  
