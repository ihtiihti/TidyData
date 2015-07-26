This is the repository that contains implementation of the Course Project of the "Getting and Cleaning Data» course that you may find in coursera.org.

This is implementation by @ihtiihti.

The repository consists of three files: 
* README.md -- this file
* CodeBook.md -- the file that describes implementation details
* run_analysis.R -- the R file that contains all source

To generate your tidy data, go through these steps:
1. Download and unpack raw data [Data Set](https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip).
2. In *run_analysis.R* file change the path to
	1. *data.set.directory* -- the full path to the directory where raw data were unpacked in in the previous step;
	2. *tidy.data.file* -- the name of the file where tidy data have to be stored.
3. Run *run_analysis.R*
4. After sucessfull run of the script you shall find a text file with tidy data.

Enjoy!