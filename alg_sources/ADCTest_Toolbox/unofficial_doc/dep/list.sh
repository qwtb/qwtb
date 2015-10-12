#!/bin/bash

# create tmp directory
mkdir deptmp

# find the matlab files (with path)
find $1 -name "*.m" > deptmp/file_list_comp

# find the matlab files (without path)
find $1 -name "*.m" -printf "%f\n" > deptmp/file_list_short

# remove the extension *.m
sed -e 's/.m$//g' deptmp/file_list_short > deptmp/file_list_short_noext

# remove *.m and setup for grep
sed -e 's/.m$/\\(/g' deptmp/file_list_short > deptmp/grep_file

exit 0;
