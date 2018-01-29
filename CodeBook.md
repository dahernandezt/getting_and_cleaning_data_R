# Getting and Cleaning Data Final Proyect Code Book

## Final Data Variables explanation

* subject: The subject id
* activity: Activity name
* feature: The feature taken measurement of.
* measue: The statistic measure (mean or standard deviation).
* axis: For those features measured into different axis.
* value: The mean of all values for the given subject,activity and measure.

## Run Analysis code explanation

### Loading libraries
Firs step on the process is to load tidyr and dplyr libraries.
```
library(tidyr)
library(dplyr)
```

### Load Data
Then load each data file into a data frame variable. Files inside "Inertial Signals" folder were not used since I assume that 
the files X_train.txt and X_tests contains summarized data from those.
```
train_subject <- read.table("./projectSource/UCI HAR Dataset/train/subject_train.txt")
train_X_train <- read.table("./projectSource/UCI HAR Dataset/train/X_train.txt")
train_y_train <- read.table("./projectSource/UCI HAR Dataset/train/y_train.txt")
test_X_test <- read.table("./projectSource/UCI HAR Dataset/test/X_test.txt")
test_y_test <- read.table("./projectSource/UCI HAR Dataset/test/y_test.txt")
test_subject <- read.table("./projectSource/UCI HAR Dataset/test/subject_test.txt")
features <- read.table("./projectSource/UCI HAR Dataset/features.txt")
activities<- read.table("./projectSource/UCI HAR Dataset/activity_labels.txt")
```

### Variables Naming
Name variables properly on each data frame.
```
names(train_subject) <- c("subject")
names(train_y_train) <- c("activity_id")
names(test_subject) <- c("subject")
names(test_y_test) <- c("activity_id")
names(activities) <- c("activity_id","activity")
```

The variables from the X_train and X_test files were named using the convention described on "features.txt" 
```
names(train_X_train) <- features$V2
names(test_X_test) <- features$V2
```

### Filtering variables
Only the mean() and std() variables were taken into a new subsetted data frame.
```
filteredXtrain <- train_X_train[,c(grep("-mean\\(",names(train_X_train)),grep("-std\\(",names(train_X_train)))]
```

### Adding subject and activity information.

Add a subject row into the filtered data frame for train datasets.
```
filteredXtrain <- cbind(train_subject,filteredXtrain)
```

Add an activity_id row into the filtered data frame.
```
filteredXtrain <- cbind(train_y_train,filteredXtrain)
```

Finally add activity names through merge.
```
trainData <- merge(filteredXtrain,activities)
```

Repeating the same process with the test datasets.
```
filteredXtest <- test_X_test[,c(grep("-mean\\(",names(test_X_test)),grep("-std\\(",names(test_X_test)))]
filteredXtest <- cbind(test_subject,filteredXtest)
filteredXtest <- cbind(test_y_test,filteredXtest)
testData <- merge(filteredXtest,activities)
```

### Mergin files 
First step on making the data tidy, joining into one file both test and train datasets.
```
mergedData <- rbind(testData,trainData)
```

### Getting the type of measurement as a variable.
The type of measurement should be a single variable with a value associated.
```
mergedData2 <- gather(mergedData,key="measure",value="value",-c("activity_id","subject","activity"))
```

### Subject and activity should be factors.
```
mergedData2$subject <- as.factor(mergedData2$subject)
mergedData2$activity_id <- as.factor(mergedData2$activity_id)
```

### Separating variables to get one per row.
The type of measure variable contains information about 3 different things, split it into 3 columns.
```
mergedData3 <- separate(mergedData2,col=measure,into=c("variable","measure","axis"))
```

After separating, no all the type of measurements have an axis value, assigning NA values in that case.
```
mergedData3$axis[mergedData3$axis==""] <- NA
```

### Some pruning
The activity_id and activity variables are redundant, keeping activity since is more descriptive.
```
finalData <- mergedData3[,2:7]
```

### Step 5: Getting the summarized means of each measure.
Group and summarize values taking the mean.
```
finalDataGrouped <- group_by(finalData,subject,activity,variable,measure,axis)
result <- summarise(finalDataGrouped,value = mean(value))
```

Convert into factors 
```
result$activity <- as.factor(result$activity)
result$variable <- as.factor(result$variable)
result$measure <- as.factor(result$measure)
result$axis <- as.factor(result$axis)
```

### Result Sharing into a new dataset file.

Writing results into a file.
```
write.table(result,"result.txt",row.names = FALSE)
```
