#!/bin/sh
# Write script for assignment 1
# Author: Hector Guarneros
# Write a shell script finder-app/writer.sh as described below
# *Accepts the following arguments: the first argument is a full path
# to a file (including filename) on the filesystem, referred to below
# as writefile; the second argument is a text string which will
# be written within this file, referred to below as writestr
# *Exits with value 1 error and print statements if any of the arguments
# above were not specified
# *Creates a new file with name and path writefile with content writestr,
# overwriting any existing file and creating the path if it doesnt exist.
# Exits with value 1 and error print statement if the file could not
# be created.
# Example
#        writer.sh /tmp/aesd/assignment1/sample.txt ios
# Creates file
#     /tmp/aesd/assignment1/sample.txt
#             With content
#             ios


# Check if the correct number of arguments is provided
if [ "$#" -ne 2 ]; then
    echo "Error! Two arguments required: $0 <path_to_file> <text_string>"
    exit 1
fi

writefile=$1
writestr=$2

# Create the directory structure if it doesn't exist
mkdir -p "$(dirname "$writefile")"
# Write the text string to the file, overwriting any existing content
echo ${writestr} > $writefile
echo "File created successfully: $writefile"
# Give it execute permissions
#chmod +x writer.sh
