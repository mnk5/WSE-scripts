# Script to plot output hydrographs

# Loads hydrographs from excel and plots as faceted graphs
# For Viva Naughton report
# M. Karpack, 2020

#library(hydroutils)
#library(dssrip)
library(ggplot2)
library(readxl)
library(reshape2)
library(scales)
library(RColorBrewer)
library(gridExtra)
library(dplyr)



# load data from excel sheet

setwd("C:/Egnyte/Private/marissa/Projects/19-029 Viva Naughton Probable Maximum Flood Inflow Determination/Hydrology")

local.grid <- data.frame(read_excel("VVN_OutputHydrographs.xlsx", sheet = 1))
general.grid <- read_excel("VVN_OutputHydrographs.xlsx", sheet = 2)

local.lumped <- data.frame(read_excel("VVN_OutputHydrographs.xlsx", sheet = 3))
general.lumped <- data.frame(read_excel("VVN_OutputHydrographs.xlsx", sheet = 4))

# Make col names match
colnames(general.lumped) <- colnames(general.grid)

# Melt to use with ggplot
local.grid.melt <- melt(local.grid, id.var = 'Time..hr.')
local.lumped.melt <- melt(local.lumped, id.var = 'Time..hr.')

general.grid.melt <- melt(general.grid, id.var = 'Hours')
general.lumped.melt <- melt(general.lumped, id.var = 'Hours')

# add column for rain only
rain.local <- colnames(local.grid)[seq(3,9,2)]
rain.general <- colnames(general.grid)[seq(3,19,2)]

local.grid.melt$rain.only <- ifelse(local.grid.melt$variable %in% rain.local, "Rain Only", "No")
local.lumped.melt$rain.only <- ifelse(local.lumped.melt$variable %in% rain.local, "Rain Only", "No")

general.grid.melt$rain.only <- ifelse(general.grid.melt$variable %in% rain.general, "Rain Only", "No")
general.lumped.melt$rain.only <- ifelse(general.lumped.melt$variable %in% rain.general, "Rain Only", "No")

# add column for month to general

May.col <- colnames(general.grid)[2:7]
Jun.col <- colnames(general.grid)[8:13]
Jul.col <- colnames(general.grid)[14:19]

general.grid.melt$month[general.grid.melt$variable %in% May.col] <- "May"
general.grid.melt$month[general.grid.melt$variable %in% Jun.col] <- "June"
general.grid.melt$month[general.grid.melt$variable %in% Jul.col] <- "July"

general.grid.melt$month <- factor(general.grid.melt$month, levels= c("May","June", "July"))

general.lumped.melt$month[general.lumped.melt$variable %in% May.col] <- "May"
general.lumped.melt$month[general.lumped.melt$variable %in% Jun.col] <- "June"
general.lumped.melt$month[general.lumped.melt$variable %in% Jul.col] <- "July"

general.lumped.melt$month <- factor(general.lumped.melt$month, levels= c("May","June", "July"))


# # Colorblind friendly palettes
# cbPalette <- c("#999999", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")
Paired.rev.color <- c("#FF7F00","#FDBF6F", "#1F78B4","#A6CEE3", "#33A02C", "#B2DF8A","#E31A1C","#FB9A99")
Paired.gen.color <- c("#1F78B4","#A6CEE3", "#33A02C", "#B2DF8A","#E31A1C","#FB9A99","#1F78B4","#A6CEE3", 
                      "#33A02C", "#B2DF8A","#E31A1C","#FB9A99","#1F78B4","#A6CEE3", "#33A02C", "#B2DF8A",
                      "#E31A1C","#FB9A99")
                    
# Plot just controlling hydrograph
names(general.grid)[2]<-"MaySynth"
h <- ggplot(general.grid, aes(x = Hours, y = MaySynth)) + 
  geom_line(size = 1, color = "#1F78B4") +
  theme_bw(base_size = 14) + 
  theme(plot.margin = unit(c(10, 20, 10, 10), "points")) +
  labs(title = "Controlling PMF Inflow") +
  scale_x_continuous(name = "Time after start of PMP, hours", breaks = seq(0, 120, 24), expand=c(0.0,0.001)) + 
  scale_y_continuous(name = "Reservoir inflow, cfs",labels = comma, expand=c(0.0001,0), limits = c(0, 45000)) 
  

# Plot all local storms

lg <- ggplot(local.grid.melt, aes(x=Time..hr., y = value, col = variable)) + 
  geom_line(size = 1) +
  theme_bw(base_size = 14) +
  theme(legend.position = c(.85, .75)) +
  labs(color = "Storm Pattern", title = "Gridded Model Local Storms") +
  scale_x_continuous(name = "Time after start of PMP, hours", breaks = seq(0, 36, 6), expand=c(0.0,0.001)) + 
  scale_y_continuous(name = "Reservoir inflow, cfs",labels = comma, expand=c(0.0001,0), limits = c(0, 40000)) +
  scale_color_manual(values = Paired.rev.color, labels = c("2 hr", "2 hr, rain only", "Synthetic", "Synthetic, rain only", 
                                                           "Huff-90", "Huff-90, rain only", "Huff-10", "Huff-10, rain only"))
#+scale_linetype_manual(guide = FALSE, values=c(1,5)) 

ll <- ggplot(local.lumped.melt, aes(x=Time..hr., y = value, col = variable)) + 
  geom_line(size = 1) +
  theme_bw(base_size = 14) +
  theme(legend.position = c(.85, .75)) +
  labs(color = "Storm Pattern", title = "Lumped Model Local Storms") +
  scale_x_continuous(name = "Time after start of PMP, hours", breaks = seq(0, 36, 6), expand=c(0.0,0.001)) + 
  scale_y_continuous(name = "Reservoir inflow, cfs",labels = comma, expand=c(0.0001,0), limits = c(0, 40000)) +
  scale_color_manual(values = Paired.rev.color, labels = c("2 hr", "2 hr, rain only", "Synthetic", "Synthetic, rain only", 
                                                    "Huff-90", "Huff-90, rain only", "Huff-10", "Huff-10, rain only")) 
#+scale_linetype_manual(guide = FALSE, values=c(1,5))

# Plot general storm hydrographs
legend.values <- colnames(general.grid)[2:7]
legend.labels <- c("Synthetic", "Synthetic, rain only", "Huff-90", "Huff-90, rain only", "Huff-10", "Huff-10, rain only")

gg <- ggplot(general.grid.melt, aes(x=Hours, y = value, col = variable)) + geom_line(size = 1) +
  theme_bw(base_size = 14) +
  facet_wrap(~ month, ncol = 3) +
  theme(legend.position = "bottom") +
  labs(color = "Storm Pattern", title = "Gridded Model General Storms") +
  scale_x_continuous(name = "Time after start of PMP, hours", breaks = seq(0, 119, 24), expand=c(0,0)) + 
  scale_y_continuous(name = "Reservoir inflow, cfs",labels = comma, expand=c(0.0001,0), limits = c(0, 45000)) +
  scale_color_manual( breaks = legend.values, labels = legend.labels, values = Paired.gen.color) 
 # scale_linetype_manual(guide = FALSE, values=c(1,5))

gl <- ggplot(general.lumped.melt, aes(x=Hours, y = value, col = variable)) + 
  geom_line(size = 1) +
  theme_bw(base_size = 14) +
  facet_wrap(~ month, ncol = 3) +
  theme(legend.position = "bottom") +
  labs(color = "Storm Pattern", title = "Lumped Model General Storms") +
  scale_x_continuous(name = "Time after start of PMP, hours", breaks = seq(0, 119, 24), expand=c(0,0)) + 
  scale_y_continuous(name = "Reservoir inflow, cfs",labels = comma, expand=c(0.0001,0), limits = c(0, 45000)) +
  scale_color_manual( breaks = legend.values, labels = legend.labels, values = Paired.gen.color) 
#  scale_linetype_manual(guide = FALSE, values=c(1,5))

##################################
# SWE Graphs

read_excel_allsheets <- function(filename) {
  sheets <- readxl::excel_sheets(filename)
  x <- lapply(sheets, function(X) readxl::read_excel(filename, sheet = X))
  x <- lapply(x, as.data.frame)
  names(x) <- sheets
  x
}

SWE <- read_excel_allsheets("VVN_Output_SWEReduction.xlsx")
run.names <- c("May Gridded Huff-10","May Gridded Huff-90","May Gridded Synthetic",
               "June Gridded Huff-10","June Gridded Huff-90","June Gridded Synthetic",
               "May Lumped Huff-10","May Lumped Huff-90","May Lumped Synthetic",
               "June Lumped Huff-10","June Lumped Huff-90", "June Lumped Synthetic"  )

SWE.melt <- lapply(SWE, function(X) melt(X, id.var = "Time"))

# add date column
for (val in c(1,2,3,7,8,9)) {
 SWE.melt[[val]] <- cbind(SWE.melt[[val]], Month ="May")
}

for (val in c(4,5,6,10,11,12)) {
  SWE.melt[[val]] <- cbind(SWE.melt[[val]], Month ="June")
}

# Add model type column
for (val in seq(1,6)) {
  SWE.melt[[val]] <- cbind(SWE.melt[[val]], Model ="Gridded")
}

for (val in seq(7,12)) {
  SWE.melt[[val]] <- cbind(SWE.melt[[val]], Model ="Lumped")
}

# Add temporal pattern column
for (val in seq(1,12,3)) {
  SWE.melt[[val]] <- cbind(SWE.melt[[val]], Pattern ="Huff-10")
}

for (val in seq(2,12,3)) {
  SWE.melt[[val]] <- cbind(SWE.melt[[val]], Pattern ="Huff-90")
}

for (val in seq(3,12,3)) {
  SWE.melt[[val]] <- cbind(SWE.melt[[val]], Pattern ="Synthetic")
}

# Concatenate list items
SWE.df.all <- bind_rows(SWE.melt, .id = "Run")
subbasin.order <- c(levels(SWE.df.all$variable)[11] , levels(SWE.df.all$variable)[1:10])
SWE.df.all$variable <- factor(SWE.df.all$variable, levels = subbasin.order)

SWE.df.May <- SWE.df.all[SWE.df.all$Month == "May",]
SWE.df.Jun <- SWE.df.all[SWE.df.all$Month == "June",]

# Make plots

m <- ggplot(data = SWE.df.May, aes(x = Time, y = value, color = variable)) +
  geom_line(size = 1) +
  facet_grid(Model ~ Pattern) +
  theme_bw(base_size = 14) +
  theme(panel.spacing.x=unit(0.5, "lines"),panel.spacing.y=unit(1, "lines")) +
  scale_x_continuous(name = "Time after start of PMP, hours", breaks = seq(0, 119, 24), expand=c(0,0)) + 
  scale_y_continuous(name = "SWE, inches", limits = c(0, 35), expand=c(0.001,0)) +
  labs(color = "", title = "May 15th Reduction in SWE")

j <- ggplot(data = SWE.df.Jun, aes(x = Time, y = value, color = variable)) +
  geom_line(size = 1) +
  facet_grid(Model ~ Pattern) +
  theme_bw(base_size = 14) +
  theme(panel.spacing.x=unit(0.5, "lines"),panel.spacing.y=unit(1, "lines")) +
  scale_x_continuous(name = "Time after start of PMP, hours", breaks = seq(0, 119, 24), expand=c(0,0)) + 
  scale_y_continuous(name = "SWE, inches", limits = c(0, 15), expand=c(0.0,0)) +
  labs(color = "", title = "June 15th Reduction in SWE")

m
j

# 
# SWE_plots <- list()
# for (i in 1: length(SWE)){
#   SWE.df <- melt(SWE[[i]], id.var = "Time")
#   if (i %in% c(1,2,3,7,8,9)){
#     p <- ggplot(data = SWE.df, aes(x = Time, y = value, color = variable)) +
#         geom_line(size = 1) +
#         theme_bw(base_size = 14) +
#         scale_x_continuous(name = "Time after start of PMP, hours", breaks = seq(0, 120, 24), expand=c(0,0.001)) + 
#         scale_y_continuous(name = "SWE, inches", limits = c(0, 40), expand=c(0.001,0)) +
#         labs(color = "", title = run.names[i])
#   }else{
#     p <- ggplot(data = SWE.df, aes(x = Time, y = value, color = variable)) +
#         geom_line(size = 1) +
#         theme_bw(base_size = 14) +
#         scale_x_continuous(name = "Time after start of PMP, hours", breaks = seq(0, 120, 24), expand=c(0,0.001)) + 
#         scale_y_continuous(name = "SWE, inches", limits = c(0, 15), expand=c(0.001,0)) +
#         labs(color = "", title = run.names[i])
#     }
#           
#   SWE_plots[[i]] <- p
# }
# 
# # Arrange plots
# 
# May <- grid.arrange(SWE_plots[[1]], SWE_plots[[2]],SWE_plots[[3]], SWE_plots[[4]], SWE_plots[[5]], SWE_plots[[6]], 
#                     nrow = 2)

#################################
# output and save graphs

setwd("C:/Egnyte/Private/marissa/Projects/19-029 Viva Naughton Probable Maximum Flood Inflow Determination/Report/Figures")

ggsave("ControllingPMF.jpg", h, width = 10, height = 6.2, units = "in")

ggsave("LocalGrid.jpg", lg, width = 10, height = 6.2, units = "in")
ggsave("LocalLumped.jpg", ll, width = 10, height = 6.2, units = "in")
ggsave("GeneralGrid.jpg", gg, width = 10, height = 5.8, units = "in")
ggsave("GeneralLumped.jpg", gl, width = 10, height = 5.8, units = "in")

ggsave("MaySWEgraph.jpg", m, width = 10, height = 6, units = "in")
ggsave("JunSWEgraph.jpg", j, width = 10, height = 6, units = "in")


