# 1 - Initialization
# 1.1 - Load LaF library for functions : laf_open_fwf, laf_to_ffdf
library("LaF")

# 1.2 - Load tidyr library for functions : gather, separate, spread
library("tidyr")

# 1.3 - Load dplyr library for functions : mutate, select
library("dplyr")

# 1.4 - Initialize "Sources Filename"
src_features_filename <- file.path(".", "features.txt")
src_activity_labels_filename <- file.path(".", "activity_labels.txt")

src_subject_test_filename <- file.path(".", "test", "subject_test.txt")
src_X_test_filename <- file.path(".", "test", "X_test.txt")
src_y_test_filename <- file.path(".", "test", "y_test.txt")
src_subject_train_filename <- file.path(".", "train", "subject_train.txt")
src_X_train_filename <- file.path(".", "train", "X_train.txt")
src_y_train_filename <- file.path(".", "train", "y_train.txt")

#src_subject_test_filename <- file.path(".", "sample_test", "subject_test.txt")
#src_X_test_filename <- file.path(".", "sample_test", "X_test.txt")
#src_y_test_filename <- file.path(".", "sample_test", "y_test.txt")
#src_subject_train_filename <- file.path(".", "sample_train", "subject_train.txt")
#src_X_train_filename <- file.path(".", "sample_train", "X_train.txt")
#src_y_train_filename <- file.path(".", "sample_train", "y_train.txt")

# 1.5 - Check files existence before beginning to load them
src_filenames <- c(
	  src_features_filename,
	  src_activity_labels_filename,
      src_subject_test_filename,
	  src_X_test_filename,
	  src_y_test_filename,
	  src_subject_train_filename,
	  src_y_train_filename)
src_filenames_existing <- file.exists(src_filenames)
if (!all(src_filenames_existing)) {
	stop(paste0("No data found for those files : ", paste0(src_filenames[!src_filenames_existing], sep = ", ")))
}

# 2 - Construct "mydf" data.frame : Contains datasets "Test" and "Train" mixed with Activity Labels, with only measurements columns name containing mean and std
# 2.1 - Get features names and replace parenthesis by underscore
print(paste0("2.1 - Loading '", src_features_filename, "'..."))
features <- read.csv(src_features_filename, header = FALSE, sep = " ", col.names = c("Id", "Name"))
features <- transform(features, Name = sub("[\\)\\(].", "__", Name))

# 2.2 - Get Activity Labels
print(paste0("2.2 - Loading '", src_activity_labels_filename, "'..."))
activity_labels <- read.csv(src_activity_labels_filename, header = FALSE, sep = " ", col.names = c("ActivityId", "ActivityLabel"))

# 2.3 - Load Test files and construct mydf
print("2.3 - Load Test files and construct mydf :")
print(paste0("    Loading '", src_subject_test_filename, "'..."))
mydf <- read.csv(src_subject_test_filename, header = FALSE, col.names = c("subject"))

print(paste0("    Loading '", src_y_test_filename, "'..."))
mydf <- cbind(read.csv(src_y_test_filename, header = FALSE, col.names = c("y")), mydf)

print("    Merge mydb with activity labels...")
mydf <- merge(mydf, activity_labels, by.x = "y", by.y = "ActivityId")

print(paste0("    Loading '", src_X_test_filename, "'..."))
#Problem with function : Too slow, consuming a lots of memory - X <- read.fwf(src_X_test_filename, widths = rep(c(16), times = 561), col.names = features$Name)
X <- laf_open_fwf(src_X_test_filename, column_widths = rep(c(16), times = 561), column_types = rep(c("numeric"), times = 561), column_names = features$Name)

# Extract only columns which contain fonction mean() and std(), parenthesis have been transformed in underscore before
mydf <- cbind(X[,grep("(mean__)|(std__)", names(X))], mydf)
X <- NULL

# 2.4 - Load Train files and construct mydf_train
print("2.4 - Load Train files and construct mydf_train")
print(paste0("    Loading '", src_subject_train_filename, "'..."))
mydf_train <- read.csv(src_subject_train_filename, header = FALSE, col.names = c("subject"))

print(paste0("    Loading '", src_y_train_filename, "'..."))
mydf_train <- cbind(read.csv(src_y_train_filename, header = FALSE, col.names = c("y")), mydf_train)

print("    Merge mydb with activity labels...")
mydf_train <- merge(mydf_train, activity_labels, by.x = "y", by.y = "ActivityId")

print(paste0("    Loading '", src_X_train_filename, "'..."))
#Problem with function : Too slow, consuming a lots of memory - X <- read.fwf(src_X_train_filename, widths = rep(c(16), times = 561), col.names = features$Name)
X <- laf_open_fwf(src_X_train_filename, column_widths = rep(c(16), times = 561), column_types = rep(c("numeric"), times = 561), column_names = features$Name)

# Extract only columns which contain fonction mean() and std(), parenthesis have been transformed in underscore before
mydf_train <- cbind(X[,grep("(mean__)|(std__)", names(X))], mydf_train)


# 2.5 - Bind Test and Train data in one data.frame
print("2.5 - Bind Test and Train data in one data.frame")
mydf <- rbind(mydf, mydf_train)

# 3 - Construct "mydf_tidy" data.frame from "mydf"
#        a tidy dataset from average of each variable for each activity and each subject.
print("3 - Construct mydf_tidy data.frame from mydf")

# 3.1 - Aggregate mydf by subject and ActivityLabel (and y), and apply a mean function to all measurements columns
print("3.1 - Aggregate mydf by subject and ActivityLabel (and y), and apply a mean function to all measurements columns")
mydf_tidy <- aggregate(formula = . ~ subject + y + ActivityLabel, data = mydf, FUN = mean)

# 3.2 - Pivot all measurements from column to rows 
print("3.2 - Pivot all measurements from column to rows")
mydf_tidy <- gather(data = mydf_tidy, key = measurements, value = value, -subject, -y, -ActivityLabel)

# 3.3 - Split the column measurements in 3 columns : measurement, func and measurement2
print("3.3 - Split the column measurements in 3 columns : measurement, func and measurement2")
mydf_tidy <- separate(data = mydf_tidy, col = measurements, sep = "\\.", into = c("measurement", "func", "measurement2"), fill = "right")

# 3.4 - Collapse columns measurement and measurement2
print("3.4 - Collapse columns measurement and measurement2, and suppress -NA from measurement column")
mydf_tidy <- mutate(.data = mydf_tidy, measurement = paste0(measurement, "-", measurement2))

# Suppress "-NA" from measurement column
mydf_tidy$measurement <- gsub("-NA", "", mydf_tidy$measurement)

# 3.7 - Suppress columns y and measurement2
print("3.7 - Suppress columns y and measurement2")
mydf_tidy <- select(.data = mydf_tidy, -y, -measurement2)

# 3.8 - Pivot measurement values to columns
print("3.8 - Pivot measurement values to columns")
mydf_tidy <- spread(data = mydf_tidy, key = measurement, value = value)

# 3.9 - Write mydf_tidy to file
write.table(x = mydf_tidy, file = file.path(".", "mydf_tidy.txt"), row.name = FALSE)

# Cleaning environment
rm(src_filenames)
rm(src_filenames_existing)
rm(X)
rm(mydf_train)
rm(activity_labels)
rm(features)
rm(src_features_filename)
rm(src_activity_labels_filename)
rm(src_subject_test_filename)
rm(src_X_test_filename)
rm(src_y_test_filename)
rm(src_subject_train_filename)
rm(src_X_train_filename)
rm(src_y_train_filename)
