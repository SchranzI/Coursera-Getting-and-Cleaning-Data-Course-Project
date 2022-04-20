library(reshape2)

filename <- "getdata_dataset.zip"

## Get Data from web / locally
if (!file.exists(filename)){
  fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "
  download.file(fileURL, filename, method="curl")
}  
if (!file.exists("UCI HAR Dataset")) { 
  unzip(filename) 
}

## Load activity labels, features
activityLabels <- read.table("UCI HAR Dataset/activity_labels.txt")
activityLabels[,2] <- as.character(activityLabels[,2])
ft <- read.table("UCI HAR Dataset/features.txt")
ft[,2] <- as.character(ft[,2])

## Extract data mean, standard deviation
ftWanted <- grep(".*mean.*|.*std.*", ft[,2])
ftWanted.names <- features[ftWanted,2]
ftWanted.names = gsub('-mean', 'Mean', ftWanted.names)
ftsWanted.names = gsub('-std', 'Std', ftWanted.names)
ftWanted.names <- gsub('[-()]', '', ftWanted.names)


## train data
tr <- read.table("UCI HAR Dataset/train/X_train.txt")[ftWanted]
trActivities <- read.table("UCI HAR Dataset/train/Y_train.txt")
trSubjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
tr <- cbind(trSubjects, trActivities, tr)

## test data
te <- read.table("UCI HAR Dataset/test/X_test.txt")[ftWanted]
teActivities <- read.table("UCI HAR Dataset/test/Y_test.txt")
teSubjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
te <- cbind(teSubjects, teActivities, te)

## merge data and add labels
allData <- rbind(tr, te)
colnames(allData) <- c("subject", "activity", ftWanted.names)

## turn activities, subjects into factors
allData$activity <- factor(allData$activity, levels = activityLabels[,1], labels = activityLabels[,2])
allData$subject <- as.factor(allData$subject)
allData.melted <- melt(allData, id = c("subject", "activity"))
allData.mean <- dcast(allData.melted, subject + activity ~ variable, mean)

## write tidied data into txt
write.table(allData.mean, "tidy_data.txt", row.names = FALSE, quote = FALSE)

