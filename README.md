getting_and_cleaning_data_project
=================================

repository for the project of "getting and cleaning data"

the run_analysis.R file does the following:
- appends 2 by 2 the files contained in "test" and "training" directories 
  of the "UCI HAR Dataset" and stores them in a "UCI_HAR_merged" directory.
- creates an "human-readable" text file named "tidy_mean_std.txt" from the  
  merged UCI HAR Dataset containing the mean or std-related variables for  
  each record in the "X" file with subject number and activity name.
- averages each 561 features grouped by subject and activity contained in 
  the "X" file and wites the resulting table on the disk in a file named
  "tidy_averages.txt"


it requires to work that the R working directory is set at the directory 
  containing the "UCI HAR Dataset"


it contains following functions:
- run_analysis: main function fitted to characteristics of "UCI HAR Dataset"
- create_merged: generic function for appending files together given a target 
  directory and a rule tables with following structure :
  src1, src2, dest
