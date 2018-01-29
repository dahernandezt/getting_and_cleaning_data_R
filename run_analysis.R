library(tidyr)
library(dplyr)
train_subject <- read.table("./projectSource/UCI HAR Dataset/train/subject_train.txt")
train_X_train <- read.table("./projectSource/UCI HAR Dataset/train/X_train.txt")
train_y_train <- read.table("./projectSource/UCI HAR Dataset/train/y_train.txt")
test_X_test <- read.table("./projectSource/UCI HAR Dataset/test/X_test.txt")
test_y_test <- read.table("./projectSource/UCI HAR Dataset/test/y_test.txt")
test_subject <- read.table("./projectSource/UCI HAR Dataset/test/subject_test.txt")
features <- read.table("./projectSource/UCI HAR Dataset/features.txt")
activities<- read.table("./projectSource/UCI HAR Dataset/activity_labels.txt")

names(train_subject) <- c("subject")
names(train_y_train) <- c("activity_id")
names(train_X_train) <- features$V2
names(activities) <- c("activity_id","activity")


filteredXtrain <- train_X_train[,c(grep("-mean\\(",names(train_X_train)),grep("-std\\(",names(train_X_train)))]
filteredXtrain <- cbind(train_subject,filteredXtrain)
filteredXtrain <- cbind(train_y_train,filteredXtrain)
trainData <- merge(filteredXtrain,activities)

names(test_subject) <- c("subject")
names(test_y_test) <- c("activity_id")
names(test_X_test) <- features$V2


filteredXtest <- test_X_test[,c(grep("-mean\\(",names(test_X_test)),grep("-std\\(",names(test_X_test)))]
filteredXtest <- cbind(test_subject,filteredXtest)
filteredXtest <- cbind(test_y_test,filteredXtest)
testData <- merge(filteredXtest,activities)

mergedData <- rbind(testData,trainData)
mergedData2 <- gather(mergedData,key="measure",value="value",-c("activity_id","subject","activity"))
mergedData2$subject <- as.factor(mergedData2$subject)
mergedData2$activity_id <- as.factor(mergedData2$activity_id)
mergedData3 <- separate(mergedData2,col=measure,into=c("feature","measure","axis"))
mergedData3$axis[mergedData3$axis==""] <- NA
finalData <- mergedData3[,2:7]
finalDataGrouped <- group_by(finalData,subject,activity,feature,measure,axis)
result <- summarise(finalDataGrouped,value = mean(value))
result$activity <- as.factor(result$activity)
result$feature <- as.factor(result$feature)
result$measure <- as.factor(result$measure)
result$axis <- as.factor(result$axis)
write.table(result,"result.txt",row.names = FALSE)
