## this script does the following:
#
#  1 appends 2 by 2 the files contained in "test" and "training" directories 
#    of the "UCI HAR Dataset" and stores them in a "UCI_HAR_merged" directory.
#
#  2 creates an "human-readable" text file named "tidy_mean_std.txt" from the  
#    merged UCI HAR Dataset containing the mean or std-related variables for  
#    each record in the "X" file with subject number and activity name.
#
#  3 averages each 561 features grouped by subject and activity contained in 
#    the "X" file and wites the resulting table on the disk in a file named
#    "tidy_averages.txt"
#
#  it requires to work:
#  - that the R working directory is set at the directory containing the  
#    "UCI HAR Dataset"
#
#  it contains following functions:
#  run_analysis: main function fitted to characteristics of "UCI HAR Dataset"
#  create_merged: generic function for appending files together given a target 
#                 directory and a rule tables with following structure :
#                 src1, src2, dest
#
#
## run_analysis() main function for extracting things from "UCI HAR Dataset"
run_analysis <- function(){

    ##  1 - appends files two by two
    message("********************************")
    message("**  1 - appends files two by two")
    
    # set directories
    dest_dir = "UCI_HAR_Merged"
    src_dir_1 = "UCI HAR Dataset/test"
    src_dir_2 = "UCI HAR Dataset/train"
    
    # verifies requirements: specified dirs exist ?
    exist_spec_dir <- file.exists(src_dir_1) *
        file.exists(src_dir_2)
    if(!exist_spec_dir) 
        stop("Specified directories don't exist, stop merging")
    
    # generates mergeTable containing the couples of files to be appended
    mergeTable<-cbind(
        list.files(src_dir_1, recursive = TRUE, full.names = TRUE, 
               include.dirs = TRUE),
        list.files(src_dir_2, recursive = TRUE, full.names = TRUE, 
              include.dirs = TRUE))
    message("done generating mergeTable")
    
    # and for each couple of files the destination filename    
    targetFile <- NULL
    for (i in 1:nrow(mergeTable)){
        is_directory <- file.info(mergeTable[i,1])[,2] 
        if(is_directory){ 
            targetName<-substring(mergeTable[i,1],22, 
                          nchar(mergeTable[i,1]))
        } else {
            targetName<-paste(substring(mergeTable[i,1],22,
                            nchar(mergeTable[i,1])-9),
                      ".txt", sep ="")
        }
        targetFile<-c(targetFile,
                  paste(dest_dir,"/",targetName, sep=""))
    }
    mergeTable<-cbind(mergeTable,targetFile)
    
    # In dest_dir, appends the files as specified in mergeTable
    # use create merged function bellow 
    create_merged(dest_dir, mergeTable)
    message("**** created merged files")
    message("**** end of the first part of assignment\n\n")

    ##  2 - tidy human-readable data file containing std and
    ##      mean-related columns
    message("****************************************************")
    message("**  tidy human-readable data file containing std and")
    message("**  mean-related columns")
    
    # load tables for tidied files extraction 
    message("loading merged files")
    features <- read.table("./UCI HAR Dataset/features.txt")
    activities<- read.table("./UCI HAR Dataset/activity_labels.txt")
    X<-read.table("UCI_HAR_Merged/X.txt")
    y<-read.table("UCI_HAR_Merged/y.txt")
    subject<-read.table("UCI_HAR_Merged/subject.txt")
    message("done")
    
    # assign column headers
    names(y)<-"act_id"
    names(X)<-features[, 2]
    names(subject)<-"subject"
    names(activities)<-c("act_id","activity")
    names(features)<-c("feature_id","feature_label")
    
    # label activities contained in y.txt in a human-readable way
    HR_y<-data.frame()
    message("getting human-readable activity names")
    for (i in 1:length(y[,1])){
        HR_y[i,1]<-activities[activities$act_id == y[i,1],2]
        
    }
    names(HR_y)<-"activity"
    
    # get a list of "mean/std"-related columns index in the X table
    message("getting std or mean-related columns indexes")
    selected_fields<-as.matrix(features[
        grep("std|mean", features[,2],ignore.case=TRUE),1])
    
    # assemble tables "horizontally"
    message("binding components")
    tidy_mean_std<-cbind(subject,HR_y,X[,selected_fields[,1]])

    # write the result as tidy_mean_std.txt
    message("writing file tidy_mean_std.txt")
    write.table(tidy_mean_std, "tidy_mean_std.txt", sep="\t", row.names = FALSE)
    message("**** written tidy_mean_std.txt")
    message("**** end of the second part of assignment\n\n")
    
    ##  3 - make second tidy data file with the average of each
    ##      variable for each activity and each subject
    message("**************************************************")
    message("**  second tidy data file with the average of each") 
    message("**  variable for each activity and each subject")
    fullTable<-cbind(subject,HR_y,X)
    message("done generating 'base fullTable'")
    aveTable<-as.data.frame(matrix(NA,ncol=563, nrow=180))    
    aveTable[,2]<-as.character(aveTable[,2])
    curAvgs<- as.data.frame(matrix(NA,ncol=561, nrow=1))
    i<-1
    for (s in 1:30){
        for (a in 1:6){
            message(c("subject: ", as.character(s)," - activity: ", 
                  as.character(activities[a,2])))
            curAvgs[]<-colMeans(fullTable[
                    fullTable$subject == s & 
                    fullTable$activity == activities[a,2], 
                    3:563])
            
            aveTable[i,]<-data.frame(s,"NA",as.matrix(curAvgs))
            aveTable[i,2]<-as.character(activities[a,2])
            i<-i+1
        }
    }
    colnames(aveTable)<-c("subject", "activity",c(colnames(X)))
    write.table(aveTable, "tidy_averages.txt", sep="\t", row.names = FALSE)
    message("**** written tidy_averages.txt,")
    message("**** end of the third and last part of assignment")
}
#
#
## create_merged() Appends files 2 by 2 in new files as specified in a table 
## passed as argument
create_merged <- function(dest_dir, mergeTable){    
    # - the dest_dir argument is the path to the destination directory
    # - the mergeTable argument is a matrix with 3 columns containing 
    #   - the pathes for both source_files (col. 1 and 2) 
    #   - the path for destination file relative to dest_directory (col. 3)
    
    # create clean target directory
    unlink(dest_dir, recursive = TRUE)
    dir.create(dest_dir)
    
    # for each couple of files specified in mergeTable
    for (i in 1:length(mergeTable[,1])){
        # test if the current file is a directory
        is_directory <- file.info(mergeTable[i,1])[,2] 
        # if they are directories, create a same directory in dest_dir
        if(is_directory){
            targetFile<-mergeTable[i,3]
            if(!file.exists(targetFile)){         
                # directory doesn't exist, create it
                dir.create(targetFile)
                message(c("created directory ", targetFile))
            }
        # if they are files create a recipient and append the two files
        } else { 
            
            targetFile<-mergeTable[i,3]
            
            if(!file.exists(targetFile)){ 
                # target file doesn't exist, create it
                file.create(targetFile)
                message(c("created file ", targetFile))
            }
            
            for (j in 1:2){
            	# and append source files
                message(c("appending ",mergeTable[i,j]))
                file.append(targetFile, mergeTable[i,j])
            }
        }
        
    }
    message("done appending files")
}
