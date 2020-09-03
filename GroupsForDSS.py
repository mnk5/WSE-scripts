import os


# set working directory (adjust as needed)
path = "C:/Egnyte/Private/marissa/Projects/19-039 Klamath Inundation Mapping Revisions/Modeling/Final/Final/"
os.chdir(path)

## Import all files with extension

# Open groups file
Group_file = open(r"C:/Egnyte/Private/Marissa/Projects/19-039 Klamath Inundation Mapping Revisions/Modeling/Final/Final/groups.txt", "w")

# File string for writing
File_str = "File: {}KlamathRiver.dss".format(path)

# Set up DSS Pathnames
partA = 'KLAMATH RIVER MAIN'
partC = 'STAGE'
#partD = '01DEC3100'
partE = '3MIN'

Flow_list = ["PMF", "FW"]
Dam_list = ['KENO', 'JCB', 'COP', 'IRNGT']

# Make Vector of required XS values    
Keno_XS = ['234.844','233.474','231.474','229.974','229.45','228.974',
           '227.974','226.974','226.430','226.179','224.474','223.216',
           '221.695','220.974','219.140','217.268','216.249','214.974',
           '214.474','212.245','210.474','209.242','208.690','208.474',
           '207.505','206.452','205.674','204.174','202.186','201.156',
           '200.102','199.891','199.57','197.446','193.581','191.864',
           '191.64','191.151','186.033','180.675','178.563','178.188',
           '176.339','166.757','161.242','157.424','150.377','142.116',
           '133.682','129.586','123.987','108.381','107.368','106.302',
           '99.1','94.632','89.126','83.835','78.716','71.033','65.826',
           '59.799','58.812','49.185','43.137','39.64','35.373','25.418',
           '23.48','16.047','10.822','6.618','3.614','0.661']
JCB_XS = Keno_XS[9:]
Copco_XS = JCB_XS[22:]
IG_XS = Copco_XS[5:]
        
XS_dict = {'KENO': Keno_XS,
           'JCB' : JCB_XS,
           'COP': Copco_XS,
           'IRNGT':  IG_XS}


# Loop over PMF and Fair Weather runs
for flow in Flow_list:
    
    # chose appropriate time range for DSS files
    if flow == 'PMF':
        partD = "22DEC3100 - 03JAN3101"
    else: 
        partD = "24DEC3100 - 09JAN3101"
    
    
    # loop over dams
    for dam in Dam_list: 
        
        #chose appropriate XS list for dam
        XS_list = XS_dict[dam]
        
        # Write group name
        Group_name = "\nGroup: {} {} F\n".format(flow, dam)    
        Group_file.write(Group_name)    
    
        # Loop over cross sections for failure runs and write to file
        for XS in XS_list:
        
            Failure_plan = "{} {} F XS".format(flow, dam)
            Failure_DSS = "/{}/{}/{}/{}/{}/{}/".format(partA, XS, partC, partD, partE, Failure_plan)
            
            Write_str = "Name: {}\n{}\n".format(Failure_DSS, File_str)
            Group_file.write(Write_str)
            
        # Loop over cross sections for non-failure runs and write to file   
        Group_name = "End\n\nGroup: {} {} NF\n".format(flow, dam)    
        Group_file.write(Group_name)    
        
        for XS in XS_list:
        
            NoFail_plan = "{} {} NF XS".format(flow, dam)
            NoFail_DSS = "/{}/{}/{}/{}/{}/{}/".format(partA, XS, partC, partD, partE, NoFail_plan)
            
            Write_str = "Name: {}\n{}\n".format(NoFail_DSS, File_str)
            Group_file.write(Write_str)
        
        Group_file.write("End\n")
        
Group_file.close()






