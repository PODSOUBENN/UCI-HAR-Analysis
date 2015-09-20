Purpose of run_analysis.R script
------------------------------------------------------

This script (Steps of ""Loading"" and "construction of mydf" dataset are melt in code for memory optimization, but for comprehension) :

###1/ Load datasets (Except brute data) : "Inertial Signals"
*from here : "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"*

> For understanding the data :
>
> > Composed of 17 features (In reality, data contain 33 features, because features XYZ are separate in 3 features), 17 function have been applied on each feature
>
> > Each observation is an analysis on a fixed-width sliding windows of 2.56 sec and 50% overlap (128 readings/window)

**Reference tables :**

- 'activity_labels.txt' : Links the class labels with their activity name (6 lines, 2 columns)

- 'features.txt' : Features/Measurements names (561 lines, 1 column) 


**Datasets are separated in 2 datasets (Test of a machine learning system) : training datasets (7352 lines), test datasets (2947 lines)**

- '{train/test}/subject_{train/test}.txt': Each row identifies the subject who performed the activity for each window sample. Its range is from 1 to 30.  (CSV file, 1 column, no header, no separator)

- '{train/test}/X_{train/test}.txt': Training set containing 561 Features/Measurements (Fixed-Witdh file of 561 columns, and width = 16)
    - 'features.txt' has been used to name all columns (parenthesis for function in column name have been replaced by   underscore)
    - After loading, only columns containing "mean__" and "std__" has been keeped (66 columns)
    *Note : Using function 'read.fwf' on my system has been a poor experience : Slow and consuming a lots of memory (may be an incompatibility or a bug on 3.2.1 version with Windows 64 bits environment).*

- '{train/test}/y_{train/test}.txt': Test Training id activity. Its range is from 1 to 6. (CSV file, 1 column, no header, no separator)
	 
###2/ Construct a dataset "mydf" : Clean datasets and Merge them in a big one keeping only fields measurement with name containing "mean" or "std"
**Characteristics of the dataset "mydef" :**

- 69 Columns : 33 mean measurements / 33 std measurements / y / subject / ActivityLabel (Label attached to y value)
- 10299 lines : for perspective only, 30 subjects with an average of 343 events by subject

**In details, steps to construct dataset mydf :**

- Same process for test and train :

    - bind by column 'subject_{train/test}.txt' (Column named 'subject') and 'y_{train/test}.txt' (Column named 'y')
    - merge result with 'activity_labels.txt' (Column named 'ActivityId' and 'ActivityLabel') by 'y' == 'ActivityId'
    - bind by column result with 'X_{train/test}.txt' (66 Columns named with 'features.txt', with 'mean' and 'std' columns selected in loading operation)
    - bind by row the 2 datasets results from the previous process
	  
  - Data catalog of dataset "mydf" :
```
tBodyAcc.mean__.X
tBodyAcc.mean__.Y
tBodyAcc.mean__.Z
tBodyAcc.std__.X
tBodyAcc.std__.Y
tBodyAcc.std__.Z
tGravityAcc.mean__.X
tGravityAcc.mean__.Y
tGravityAcc.mean__.Z
tGravityAcc.std__.X
tGravityAcc.std__.Y
tGravityAcc.std__.Z
tBodyAccJerk.mean__.X
tBodyAccJerk.mean__.Y
tBodyAccJerk.mean__.Z
tBodyAccJerk.std__.X
tBodyAccJerk.std__.Y
tBodyAccJerk.std__.Z
tBodyGyro.mean__.X
tBodyGyro.mean__.Y
tBodyGyro.mean__.Z
tBodyGyro.std__.X
tBodyGyro.std__.Y
tBodyGyro.std__.Z
tBodyGyroJerk.mean__.X
tBodyGyroJerk.mean__.Y
tBodyGyroJerk.mean__.Z
tBodyGyroJerk.std__.X
tBodyGyroJerk.std__.Y
tBodyGyroJerk.std__.Z
tBodyAccMag.mean__
tBodyAccMag.std__
tGravityAccMag.mean__
tGravityAccMag.std__
tBodyAccJerkMag.mean__
tBodyAccJerkMag.std__
tBodyGyroMag.mean__
tBodyGyroMag.std__
tBodyGyroJerkMag.mean__
tBodyGyroJerkMag.std__
fBodyAcc.mean__.X
fBodyAcc.mean__.Y
fBodyAcc.mean__.Z
fBodyAcc.std__.X
fBodyAcc.std__.Y
fBodyAcc.std__.Z
fBodyAccJerk.mean__.X
fBodyAccJerk.mean__.Y
fBodyAccJerk.mean__.Z
fBodyAccJerk.std__.X
fBodyAccJerk.std__.Y
fBodyAccJerk.std__.Z
fBodyGyro.mean__.X
fBodyGyro.mean__.Y
fBodyGyro.mean__.Z
fBodyGyro.std__.X
fBodyGyro.std__.Y
fBodyGyro.std__.Z
fBodyAccMag.mean__
fBodyAccMag.std__
fBodyBodyAccJerkMag.mean__
fBodyBodyAccJerkMag.std__
fBodyBodyGyroMag.mean__
fBodyBodyGyroMag.std__
fBodyBodyGyroJerkMag.mean__
fBodyBodyGyroJerkMag.std__
y
subject
ActivityLabel
```
  
### 3/ Construct "mydf_tidy" data.frame
- In details the data catalog of dataset "mydf_tidy" :

    - based on mydf, apply a mean function on each measurements columns by "y" / "subject" / "ActivityLabel" columns
    - "pivot" measurements columns to row (Measurement=Column names of measurements columns, value=Value of measurements columns)
    - Split the column Measurement in 3 columns : measurement, func and measurement2
    - Collapse columns measurement and measurement2, and suppress -NA from measurement column
    - Suppress columns y and measurement2
    - Pivot measurement values to columns


- Data catalog of dataset "mydf_tidy" :
```
Key columns :
  subject: The subject who performed the activity for each window sample. Its range is from 1 to 30.
  ActivityLabel: Activity Name. List : LAYING, SITTING, STANDING, WALKING, WALKING_DOWNSTAIRS, WALKING_UPSTAIRS.
  func: function apply to features. List : mean__, avg__
Features columns : Born min=-1 to max=1
  fBodyAcc-X
  fBodyAcc-Y
  fBodyAcc-Z
  fBodyAccJerk-X
  fBodyAccJerk-Y
  fBodyAccJerk-Z
  fBodyAccMag
  fBodyBodyAccJerkMag
  fBodyBodyGyroJerkMag
  fBodyBodyGyroMag
  fBodyGyro-X
  fBodyGyro-Y
  fBodyGyro-Z
  tBodyAcc-X
  tBodyAcc-Y
  tBodyAcc-Z
  tBodyAccJerk-X
  tBodyAccJerk-Y
  tBodyAccJerk-Z
  tBodyAccJerkMag
  tBodyAccMag
  tBodyGyro-X
  tBodyGyro-Y
  tBodyGyro-Z
  tBodyGyroJerk-X
  tBodyGyroJerk-Y
  tBodyGyroJerk-Z
  tBodyGyroJerkMag
  tBodyGyroMag
  tGravityAcc-X
  tGravityAcc-Y
  tGravityAcc-Z
  tGravityAccMag
```

