# Flow frequency plot in probability space

# Plots data from flow frequency with controls on colors, legend, etc. 
# M. Karpack 08/14/2023

library(ggplot2)
library(reshape2)
library(scales)
library(RColorBrewer)
library(lmomco)
library(ggrepel)

# Set working directory to folder for input/output files
setwd("C:/Egnyte/Shared/Projects/23-032 Round Butte Flood Analysis/Hydrology")

################ Load data ####################
# flow freq data columns: Annual exceedance probability (percent), return period, flow, variance, 0.05 CL, 0.95 CL

flow.freq <- read.csv("RoundButte_FFA.csv")

#rename columns for consistency in plotting
colnames(flow.freq) <- c("AEP", "return.period", "flow", "variance", "UCL", "LCL")

# Convert AEP from percent to decimal (remove if AEP is in decimal already)
flow.freq$AEP <- flow.freq$AEP/100

# Use inverse normal distribution to find z value for all probabilities
flow.freq$z.score <- qnorm(1-(flow.freq[,1]))


# Load or copy in annual peak data (not both)
# (Don't need to be sorted)

#annual.peaks <- read.csv("filename goes here")
annual.peaks <- c(5069, 6861, 4362, 18537, 5302, 6368, 5925, 6573, 8785, 9197, 
                  10729, 5905, 8322, 6152, 7108, 4609, 8158, 7468, 6625, 7427, 
                  12098, 9227, 9001, 6903, 9978, 5864, 5102, 7293, 4774, 4052, 
                  4344, 8454, 4064, 6240, 12841, 13761, 8620, 8349, 9152, 4305, 
                  5061, 5885, 6261, 4558, 8819, 6010, 5908, 5765, 6403, 9005, 6653, 
                  6519, 7260, 7718, 6528, 9232, 6076, 8978, 4141, 5473, 5291, 6490
)

# Calculate weibull plotting position for observed data
weibull <- pp(annual.peaks, sort = FALSE)
observed <- data.frame(annual.peaks, weibull)
observed$z.score <- qnorm(weibull)

# Add key flow to graph as horizontal line if desired
key.flow = 31000


############ Plot Data #################
# Plot FFA curve and observed points, and confidence limits

# set probability scale
# change values in xlabels to specify desired tick points
xlabels <- c(0.99, 0.9, 0.5, 0.2, 0.1, 0.05, 0.02, 0.01, 0.001, 0.0001, 0.00001, 0.000001)
xticks <- qnorm(1-xlabels)
return.labels <- signif(1/xlabels, digits = 2)


# Create base plot
# change size, linetype, shape variables to edit the appearance of the graph (not color!)

p <- ggplot(flow.freq, aes(x = z.score)) +
  geom_line(aes(y = flow, color = "Computed Curve" ), size = 1.25) +
  #geom_point(aes(y = flow)) +
  scale_y_continuous(trans="log10", name = "Inflow, cfs", labels = comma) +
  scale_x_continuous(name = "Probability", breaks = xticks, labels = xlabels, 
                     sec.axis = dup_axis(name = "Return Period, years", labels = return.labels)) + 
  geom_line(aes(y = LCL, color = "95% Confidence Limit"), size = 1, linetype = "dashed") +
  geom_line(aes(y = UCL, color = "5% Confidence Limit"), size = 1,linetype = "dashed") +
  annotation_logticks(sides="lr") +
  theme_bw() +
  theme(panel.grid.minor = element_blank())

# add observed data points
p <- p +
  geom_point(data = observed, aes(x = z.score, y = annual.peaks, color = "Observed Events"), 
             shape = 1, size = 2)


# Add horizontal line at maximum passable flow (change name as desired)
max.passable <- data.frame(yintercept = key.flow, Name = "Maximum Passable Flow")
p <- p + geom_hline(data = max.passable, aes(yintercept = 31000, color = Name), linetype = "twodash", size = 0.75)

# add legend (change colors here)
p <- p +
  scale_color_manual(breaks = c("Computed Curve", "95% Confidence Limit", "5% Confidence Limit", "Observed Events", max.passable$Name),
                       values = c("black", "chartreuse3", "darkmagenta", "blue2", "cornsilk4"),
      guide = guide_legend(override.aes = list(
      linetype = c("solid", "dashed", "dashed", "blank", "twodash"),
      shape = c(NA, NA, NA, 1, NA)))) +
  theme(legend.title = element_blank(), legend.position = c(.17, .8))


# save the image to file (will save at same size/scale as shown in console viewer)
outfile <- "FrequencyPlot.png"
ggsave(outfile, p, dpi = 300)
