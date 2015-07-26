read.training <- function(directory, set, type) {
    ## Read data format from a certain sub-directory(type) of a certain kind
    ##
    ## 'directory' -- the root directory where all data are located
    ##
    ## 'set' -- the set of data to read
    ##      two types of data sets are supported at this moment:
    ##      * 'test'
    ##      * 'train'
    ## 'type' -- the type of data to read
    ##      three type of data are supported at this moment:
    ##      * 'subject' -- a list subjects IDs
    ##          returns a list of subject labels [1-30]
    ##      * 'X'       -- train input data
    ##          return a data frame with 561 features
    ##      * 'y'       -- train output data
    ##          return a data frame of mappings activity ID to its labels

    # create a full path to the test data
    file.path = paste(directory, '/', set, '/', type, '_', set, '.txt', sep = '')
    read.table(file.path, header = FALSE)
}

read.aggregated.training <- function(directory, type) {
    ## Read aggregated data format from both test and train data sets
    ##
    ## 'directory' -- the root directory where all data are located
    ##
    ## 'type' -- the type of data to read (see @ read.training)
    rbind(
        read.training(directory, 'test' , type),
        read.training(directory, 'train', type)
    )
}

read.meta <- function(directory, type) {
    ## Read meta data
    ##
    ## 'directory' -- the root directory where all data are located
    ##
    ## 'type' -- the type of meta data to read
    ##      two types of meta data are supported at this moment:
    ##      * 'activity_labels' -- activity labels
    ##      * 'features'        -- features labels
    file.path = paste(directory, "/", type, ".txt", sep = "")
    read.table(file.path, header = FALSE)
}

build.tidy.data <- function(directory) {
    ## Build Tidy Data
    ##
    ## 'directory' -- the root directory where all data are located
    ##

    # Read Meta Data
    meta.activities <- read.meta(directory, 'activity_labels')
    meta.labels <- read.meta(directory, 'features')

    # Read Data (both train and test)
    train.subjects <- read.aggregated.training(directory, 'subject')
    train.input <- read.aggregated.training(directory, 'X')
    train.output <- read.aggregated.training(directory, 'y')

    # Select only mean or standard deviation measures
    target.label.filter <- c()
    for (meta in meta.labels[,2]) {
        if (length(grep('(?:mean|std)\\(\\)', meta, perl = TRUE, value = TRUE))) {
            target.label.filter <- c(target.label.filter, TRUE)
        } else {
            target.label.filter <- c(target.label.filter, FALSE)
        }
    }

    # Select only target measurements from train input data
    filtered.train.input <- train.input[, target.label.filter]

    # Rename labels as `mean(<label name>)'
    measure.labels <- c(c("Subject", "Activity"), as.vector(meta.labels[target.label.filter,][,2]))

    # Create output matrix where
    #   * 1st column -- Subject
    #   * 2nd column  -- Label of activity
    #   * the rest of columns -- means of mean or std deviations of variables
    filtered.train.output <- matrix(
        nrow = 0,
        ncol = length(measure.labels)
    )

    activity.filter.matrix <- matrix(nrow = 0, ncol = nrow(train.output))
    activities <- as.vector(train.output)
    for (ix in 1:max(as.vector(meta.activities[,1]))) {
        activity.filter.matrix <- rbind(
            activity.filter.matrix,
            matrix(
                data = c(c(activities == ix)),
                nrow = 1,
                ncol = nrow(train.output)
            )
        )
    }

    # Measure means for each subject
    subjects <- as.vector(train.subjects[,1])
    activites <- unique(as.vector(meta.activities[,1]))
    for (subject.id in unique(subjects)) {
        subject.filter <- subjects == subject.id
        for (activity.id in activites) {
            activity.filter <- as.vector(activity.filter.matrix[activity.id,])
            data.filter <- activity.filter & subject.filter

            if(TRUE %in% data.filter) {
                subject.row <- apply(filtered.train.input[data.filter,], 2, mean)
                filtered.train.output <- rbind(
                    filtered.train.output,
                    c(
                        c(subject.id),
                        as.vector(meta.activities[[2]][[activity.id]]),
                        subject.row
                    )
                )
            }
        }
    }

    colnames(filtered.train.output, do.NULL = FALSE)
    colnames(filtered.train.output) <-measure.labels

    as.data.frame(filtered.train.output)
}

data.set.directory <- "~/Public/Sources/Education/coursera.org/Getting and Cleaning Data/Course Project/UCI HAR Dataset/"
tidy.data.file <- "~/Public/Sources/Education/coursera.org/Getting and Cleaning Data/Course Project/tidy.data.txt"

tidy.data <- build.tidy.data(data.set.directory)
write.table(tidy.data, tidy.data.file, row.names = FALSE)
