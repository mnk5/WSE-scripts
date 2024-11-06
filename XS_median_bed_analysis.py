# -*- coding: utf-8 -*-
"""
Created on Wed Sep  4 11:29:29 2024

@author: Marissa
"""
import os
import numpy as np
import pandas as pd
import matplotlib as mpl
import matplotlib.pyplot as plt
import seaborn as sns

# Set working directory
os.chdir("C:/Users/Marissa/Desktop")

# read in data
df = pd.read_csv('cross_section_median_bed_elevations_sorted.csv')

############ User Inputs #################
# define years of interest
start_year = 1970
end_year = 2025

# Define river station and names of points of interest
POI_df = pd.DataFrame({
    'Point Name': ['weir','widened section','old railroad trussle','Sandy Cove Park','Record Office revet.',
                         'Pump Station revet.','South Fork confluence'],
    'River Mile': [38.47,38.53,39.29,39.65,39.91,40.33,41.78]
})

########## Data subsetting and color scale ################

# subset data to only years of interest
df = df[(df['year'] >= start_year) & (df['year'] <= end_year)]

# Normalize year values for color mapping
norm = plt.Normalize(df['year'].min(), df['year'].max())
cmap = mpl.colormaps['viridis']

# Apply normalization to get colors for each year
df['color'] = df['year'].apply(lambda x: cmap(norm(x)))

# Create a color palette for seaborn
color_palette = dict(zip(df['year'].unique(), df['color'].unique()))

# Define labels for complete bed or not
bank_map = {-1: 'Banks not included', 1: 'Banks included'}  
df['Complete Bed?'] = df['compelete bed? (-1 inidcates not)'].map(bank_map)

################# Make Plot ############################

plt.figure(figsize=(10, 6))
sns.lineplot(data=df, x='RM (mi)', y='median bed elevation (weighted)', hue='year', 
             palette=color_palette, style = 'Complete Bed?', markers=True)

# Add vertical lines for points of interest
for rm in POI_df['River Mile']:
    plt.axvline(x=rm, color='grey', linestyle='dotted')

# Add annotations for points of interest
for i, row in POI_df.iterrows():
    plt.text(row['River Mile'], df['median bed elevation (weighted)'].max(), row['Point Name'], 
             rotation=90, verticalalignment='top', horizontalalignment='center', fontsize=9, color='black')



# Add labels and title
plt.xlabel('River Mile')
plt.ylabel('Elevation, ft')
plt.title('River Mile vs. Bed Elevation')
plt.grid(True)


# Show plot
plt.show()


# fig = plt.figure(figsize=(10,11)) # create the canvas for plotting
# ax1 = plt.subplot(2,1,1) 
# # (2,1,1) indicates total number of rows, columns, and figure number respectively
# ax2 = plt.subplot(2,1,2)

# # create lables for open vs. closed points
# ax1.scatter([0],[0],color = 'k', label = 'banks included')
# ax1.scatter([0],[0],color = 'white',linewidths = 1.5, edgecolor = 'k', label = 'banks not included')

# # format into being organized by years
# for year in df['year'].unique():
#     x = []
#     y = []
#     complete = 0
#     for j in range(len(yr)):
#         if float(yr[j]) == float(years[i]):
#             x.append(RM[j])
#             y.append(bed_elev_weighted[j])
#             if bed_complete[j] == 1: # conviniently, all sets of cross sections are either complete or possibly biased
#                 complete = 1
                
#     # plot            
#     ax1.plot(x,y,label = years[i], color = colors[i])
#     if complete == 0:
#         ax1.scatter(x,y,color = 'white',linewidths = 1.5, edgecolor = colors[i])
#     if complete == 1:
#         ax1.scatter(x,y,color = colors[i])
        
#     ax2.plot(x,y,label = years[i], color = colors[i])
#     if complete == 0:
#         ax2.scatter(x,y,color = 'white',linewidths = 1.5, edgecolor = colors[i])
#     if complete == 1:
#         ax2.scatter(x,y,color = colors[i])
        
# # add in areas of relevance
# ax1.vlines(x=points_of_interest_RM, ymin=378, ymax=398, color = 'k', linestyle = 'dotted')
# ax2.vlines(x=points_of_interest_RM, ymin=386.5, ymax=420, color = 'k', linestyle = 'dotted')
# for i in range(len(points_of_interest_RM)):
#     ax1.text(points_of_interest_RM[i], 399, points_of_interest[i], rotation=90, verticalalignment='baseline', horizontalalignment='center')
#     if i < 4:
#         ax2.text(points_of_interest_RM[i], 386, points_of_interest[i], rotation=90, verticalalignment='top', horizontalalignment='center')
        
# # add in notes on aggradation and erosion
# ax1.hlines(y=380, xmin = 41.78, xmax = 42.19, color = 'brown', linestyle = 'dashed')
# ax1.text(41.8,381,'agg.', rotation = 0, color = 'brown')
# ax1.hlines(y=380, xmin = 39.811, xmax = 40.078, color = 'cornflowerblue', linestyle = 'dashdot')
# ax1.text(39.811,381,'ero.', rotation = 0, color = 'cornflowerblue')
        
# ax1.set_xlabel('River mile (approximate)')
# ax1.set_ylabel('Median bed elevation (ft)')
# ax1.set_xlim(38.4,42.52)
# ax1.set_ylim(379,417)
# ax1.grid()
# ax1.legend(bbox_to_anchor=(0.9, 0.8),facecolor='white',framealpha =1) # WORRY--including years that don't have the plot

# ax2.set_xlabel('River mile (approximate)')
# ax2.set_ylabel('Median bed elevation (ft)')
# ax2.set_xlim(38.45,39.7)
# ax2.set_ylim(378,399)
# ax2.grid()

# plt.savefig("Cross section comparison.png")
# plt.show()
