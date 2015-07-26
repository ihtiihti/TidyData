This document describes implementation details to generated tidy data.

# Specification

More information about the specification you shall find in [coursersa.org](https://class.coursera.org/getdata-030/human_grading/view/courses/975114/assessments/3/submissions).

1. Merges the training and the test sets to create one data set.

2. Extracts only the measurements on the mean and standard deviation for each measurement. 

3. Uses descriptive activity names to name the activities in the data set

4. Appropriately labels the data set with descriptive variable names. 

5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

# Functions
Below you shall find information about all functions used to generate the tidy data.
More information about arguments of all functions you shall find in the comments provided for all functions.

## `read.training`
The function implements reading of raw data from data set.

According to the structure of raw data, you shall notice that a full path to any data of a `set` (either `test` or `train`) looks as following:

```
<directory path>/<set>/<type>_<set>.txt
```

Taking into consideration that observation, the process of reading data is generalised and covered just in one function -- `read.training`.

## `read.aggregated.training`

The function aggregates data both from `train` and `test` data sets.

## `read.meta`
The functions reads meta information about provided data (`activity labels`, `features`).

## `build.tidy.data`
The function that implements the core functionality of the R-script.
More information about the function you shall find below.

# Build Tidy Data

## Read data
### Meta Data
At this step the following data are read:
* `meta.activities` -- activity labels those match `activity ID` to its `name`
* `meta.labels` -- labels of features those match `feature ID` to its `name`

### Raw Data
At this step merged data (data both from `test` and `train` sets) are read, namely:
* `train.subjects` -- a list of subjects those map measurements to a particular subject
* `train.input` -- a data frame of training input data that may be considered as a matrix of 561 columns and number of rows is equal to the capacity of `train.subjects'
* `train.output` -- a list of activities those are suits to `train.input`

## Filter Measurements
We have to select only features those are either `mean` or `standard deviation`. According to the feature descriptions, a feature with a mean value has `mean()` suffix and a feature with a standard deviation value has `std` suffix. Thus, we have to go through all features and select among them the features those have either `mean()` of `std()` suffixes.

After that filtering, we have `target.label.filter` -- a Boolean vector of target features where:
* `TRUE` -- feature must be included into consideration;
* `FALSE` -- feature must be excluded.

## Output Matrix
All data will be placed into a matrix `filtered.train.output`.
Initially, the matrix has `0` columns because there is no data and it has `2 + length(target.label.filter)` rows; here `2` -- two extra columns for the left most columns:
* `Subject`
* `Activity`

In the further processing that matrix will be filled by data row by row.

## `activity.filter.matrix`
In the future processing, we need to find a set of measurements those belong both to a particular measurement and a certain subject.
Due to the fact that that processing should be applied in a loop, for each subject, it is worth to calculate that Boolean matrix once (no of activities x activities in raw data) and reuse it.

## Core Filtering
### Go through all subjects
All available subjects are processed in `for` loop at the first level.
Each subject has its id -- `subject.id`.

### Go through all activities
For each subject go through all its activities.

The selection Boolean vector of meaning (for a particular subject and particular activity) stored in `data.filter `.

### Go though all target features and find their mean
```
if(TRUE %in% data.filter) {
```
It is checked that the data are not empty. If the data are empty (there is no `TRUE` in selection vector at all) -- escape further steps of data processing.

```
subject.row <- apply(filtered.train.input[data.filter,], 2, mean)
```
At this stage means of all features is calculated.

```
filtered.train.output <- rbind(
    filtered.train.output,
    c(
        c(subject.id),
        as.vector(meta.activities[[2]][[activity.id]]),
        subject.row
    )
)
```
At this stage a new row is appended at the `filtered.train.output` (output matrix).

## Set Names of Columns for Matrix
Assign appropriate names of columns for the output matrix.

## Transform Output Matrix to Data Frame
```
as.data.frame(filtered.train.output)
```

The last line of the function -- thus return value

