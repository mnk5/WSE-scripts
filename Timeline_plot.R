# Timeline Script for Cedar Wood Project

# Plots timeline of data and analyses
# M. Karpack 5/25/2021

library(ggplot2)
library(reshape2)
library(scales)
library(lubridate)
library(RColorBrewer)
library(gridExtra)
library(dplyr)

setwd("C:/Egnyte/Shared/Projects/21-001_Cedar_Large_Wood_Study/")

# read cleaned 15 min USGS flow data at Renton gage
flow <- read.csv("Hydrology/Gage Data/USGS_Cedar_renton_15min_filled.csv")

# Format, clean and subset flow data
flow$Date_Time <- ymd_hm(flow$Date_Time)
flow[flow == -901] <- NA

flow_subset <- flow[flow$Date_Time > "2006-12-31 16:45:00 UTC",]

# create plot of flow only
p <- ggplot(flow_subset, aes(x= Date_Time, y = Flow)) +
  geom_line() +
  scale_x_datetime(date_breaks = "years", labels = date_format("%Y")) +
  xlab("") +
  ylab("Discharge, cfs") +
  theme_minimal()


############################################
# Make Timeline
############################################


# load events
events <- read.csv("Reporting/Literature Review/TimelineDates.csv")

events$date <- with(events, ymd(sprintf('%04d%02d%02d', Year, Month, 1)))
events <- events[with(events, order(date)),]

# set colors for each event class
event_type <- unique(events$Type)
event_colors <-c("#e41a1c", "#377eb8","#4daf4a", "#984ea3")

events$Type <- factor(events$Type, levels = event_type, ordered = TRUE)

# set up timeline locations
positions <- c(0.5, -0.5, 1.0, -1.0, 1.5, -1.5)
directions <- c(1, -1)

line_pos <- data.frame(
  "date"=unique(events$date),
  "position"=rep(positions, length.out=length(unique(events$date))),
  "direction"=rep(directions, length.out=length(unique(events$date)))
)

events <- merge(x= events, y= line_pos, by="date", all = TRUE)
events <- events[with(events, order(date, Type)),]

text_offset <- 0.1

events$month_count <- ave(events$date == events$date, events$date, FUN = cumsum)
events$text_position <- (events$month_count * text_offset * events$direction) + events$position

# adjust text position up/down for wrapped length of label
wrap_length <- 15
events$text_position <- events$text_position + (((ceiling(nchar(events$Name)/wrap_length))-1)*0.1*events$direction)



# Create dataframe of all years for labels

year_range <- seq(min(events$date), max(events$date), by = "year")
year_format <- format(year_range, "%Y")
year_df <- data.frame(year_range, year_format)


# Create scaled flow df to match timeline scale
max_y <-floor(max(events$text_position) + 0.5)

flow_subset$scaled_flow <- flow_subset$Flow * max_y/max(flow_subset$Flow, na.rm = TRUE)
flow_subset$Date_Time <- as.Date(flow_subset$Date_Time)


  geom_line(data = flow_subset, aes(x= Date_Time, y = scaled_flow), inherit.aes = FALSE, color = "gray88")

# make plot

timeline <- ggplot(events, aes(x=date, y=0, col = Type, label = Name)) +
  labs(col="") +
  scale_color_manual(values = event_colors, labels = event_type, drop = FALSE) +
  theme_classic() +
  ylim(NA, max(events$text_position) + 0.5) +
  xlim(NA, max(events$date)+ 100)+
  geom_line(data = flow_subset, aes(x= Date_Time, y = scaled_flow), inherit.aes = FALSE, color = "gray75", size = 0.2) +
  geom_hline(yintercept = 0, color = "black", size = 1) +
  geom_segment(data = events[events$month_count == 1,], aes(y = position, yend = 0, xend = date), color = "black", size = 0.3) +
  geom_point(aes(y=0), size = 2) +
  theme(axis.line.y=element_blank(),
        axis.text.y=element_blank(),
        axis.title.x=element_blank(),
        axis.title.y=element_blank(),
        axis.ticks.y=element_blank(),
        axis.text.x =element_blank(),
        axis.ticks.x =element_blank(),
        axis.line.x =element_blank(),
        legend.position = "bottom",
        legend.text = element_text(margin = margin(r = 5, unit = "pt"))) +
  #theme(plot.margin=unit(c(0.2,0.2,0.2, 0.2),"in")) +
  #geom_text(data=month_df, aes(x=month_range,y=-0.1,label=month_format),
            #size=2.5,vjust=0.5, color='black', angle=90) +
  geom_text(data=year_df, aes(x=year_range,y=-0.2,label=year_format, 
                              fontface="bold"),size=2.5, color='black') +
  geom_text(aes(y=text_position,label=stringr::str_wrap(Name, 15)),size=2.5, lineheight = 0.75)


timeline

outfile <- "Reporting/Literature Review/Timeline.png"
ggsave(outfile, timeline, width = 6.5, units = "in", dpi = 400)
