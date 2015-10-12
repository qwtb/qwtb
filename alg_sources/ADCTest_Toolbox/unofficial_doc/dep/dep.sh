#!/bin/bash

# search the function calls in the file
grep -E -n -f deptmp/grep_file $1 > deptmp/grep_match

# remove the comments and the function declaration
grep -E -v -e "^[0-9]*:[ 	]*%" deptmp/grep_match > deptmp/grep_match_nocom
grep -E -v -e "^[0-9]*:[ 	]*function" deptmp/grep_match_nocom > deptmp/grep_match_remo

# clean the output (return only the function name -o)
grep -E -o -f deptmp/grep_file  deptmp/grep_match_remo > deptmp/grep_match_clean
sed -e 's/(//g' deptmp/grep_match_clean > deptmp/dep_list

# find the line number
cat deptmp/grep_match_remo | cut -d : -f1 > deptmp/dep_number

exit 0;
