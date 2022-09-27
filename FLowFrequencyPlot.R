# Flow frequency plot in probability space

# Plots flow data in probability space to allow edits to graphs
# M. Karpack 9/27/2022

library(ggplot2)
library(reshape2)
library(scales)
library(RColorBrewer)
library(lmomco)

# Set working directory to folder for input/output files
setwd("C:/Egnyte/Private/marissa/Projects/19-029 Viva Naughton Probable Maximum Flood Inflow Determination/Hydrology")

################ Load data ####################
# flow freq data columns: Annual exceedance probability (decimal, not percent), return period, flow, variance, 0.05 CL, 0.95 CL

flow.freq <- read.csv("vvn_FlowFrequencyresults.csv")

#rename columns for consistency in plotting
colnames(flow.freq) <- c("AEP", "return.period", "flow", "variance", "UCL", "LCL")

# Use inverse normal distribution to find z value for all probabilities

flow.freq$z.score <- qnorm(1-(flow.freq[,1]))

# Load or copy in annual peak data (not both)
# Don't need to be sorted

#annual.peaks <- read.csv("filename goes here")
annual.peaks <- c(1137.4, 1089.5, 863.4, 1730.1, 1730.1, 1713.0, 760.6, 1274.5, 411.1, 
                  1017.5, 1313.9, 1483.5, 1764.4, 1438.9, 1901.4, 1541.7, 1315.6, 1480.0, 
                  2603.8, 1884.3, 1493.7, 1730.1, 1764.4, 1665.0, 82.2, 1798.7, 1308.7, 
                  1637.6, 558.4, 2021.3, 2449.6, 2706.5, 1224.8, 3820.0, 997.0, 656.1, 
                  909.6, 688.6, 1036.4, 394.0, 2192.6, 661.2, 1438.9, 2055.6, 2209.8, 
                  1019.2, 2021.3, 705.8, 601.3, 477.9, 669.8, 531.0, 2038.5, 1444.1, 
                  546.4, 1598.2, 1137.4, 1125.4, 2175.5, 743.4, 835.9, 1884.3, 873.6, 
                  1668.5, 2124.1, 990.1, 1175.1, 918.2, 553.3
)

# Calculate weibull plotting position
weibull <- pp(annual.peaks, sort = FALSE)
observed <- data.frame(annual.peaks, weibull)
observed$z.score <- qnorm(weibull)


############ Plot Data #################
# Plot FFA curve and points, and confidence limits

# set probability scale
# change values in xlabels to specify desired tick points
xlabels <- c(0.999, 0.99, 0.9, 0.5, 0.2, 0.1, 0.05, 0.02, 0.01, 0.001, 0.0001, 0.00001, 0.000001, 0.0000001)
xticks <- qnorm(1-xlabels)
return.labels <- signif(1/xlabels, digits = 2)


# Create base plot
# change size, color, linetype variables to edit the appearance of the graph

p <- ggplot(flow.freq, aes(x = z.score, color = Legend)) +
  geom_line(aes(y = flow, color = "Computed Curve" ), size = 1.25) +
  #geom_point(aes(y = flow)) +
  scale_y_continuous(trans="log10", name = "Flow, cfs") +
  scale_x_continuous(name = "Probability", breaks = xticks, labels = xlabels, 
                     sec.axis = dup_axis(name = "Return Period, years", labels = return.labels)) + 
  geom_line(aes(y = LCL, color = "95% Confidence Limit"), size = 1, linetype = "dashed") +
  geom_line(aes(y = UCL, color = "5% Confidence Limit"), size = 1,linetype = "dashed") +
  annotation_logticks(sides="lr") +
  theme_bw() +
  theme(panel.grid.minor = element_blank())

# add observed data and legend
p <- p +
  geom_point(data = observed, aes(x = z.score, y = annual.peaks, color = "Observed Events"), 
             shape = 1, size = 2) +
  scale_color_manual(breaks = c("Computed Curve", "95% Confidence Limit", "5% Confidence Limit", "Observed Events"),
                       values = c("black", "chartreuse3", "darkmagenta", "blue2"),
                       guide = guide_legend(override.aes = list(
                          linetype = c("solid", "dashed", "dashed", "blank"),
                          shape = c(NA, NA, NA, 1)))) +
  theme(legend.title = element_blank(), legend.position = c(.15, .85))
  
  
p


# save the image to file (will save at same size/scale as shown in console viewer)
outfile <- "FrequencyPlot.png"
ggsave(outfile, p, dpi = 300)
