#!/bin/sh
#
# This grade.sh is specifically for PA2.  It calls the PA2main
# with the commands MAX, DEPARTURES, and LIMIT #, where
# the number passed to LIMIT varies.
#
# grade.sh is a shell script that runs the given main class
# on all of the inputs (*.csv files) in the given input directory.
# Does all this by copying the src/*.java files into TestingTemp/
# and running the tests in TestingTemp/.
#
# usage examples:
#   ./grade.sh JavaHelloWorld PublicTestCases
#   ./grade.sh PA1Main MyTestCases
#
# FIXME: This is not available yet.
# It is also possible to run the script on an individual file:
#   ./grade.sh JavaHelloWorld PublicTestCases file1.csv CMD
#
# The assumption is that each main is operating on a given file.
# The input files in the specified input directory will be 
# given to the program.  Here are the operations performed:
#
#   javac JavaHelloWorld.java
#   java JavaHelloWorld PublicTestCases/file1.csv MAX
#   java JavaHelloWorld PublicTestCases/file1.csv DEPARTURES
#   java JavaHelloWorld PublicTestCases/file1.csv LIMIT 1
#   java JavaHelloWorld PublicTestCases/file1.csv LIMIT 2
#   java JavaHelloWorld PublicTestCases/file1.csv LIMIT 3
#   java JavaHelloWorld PublicTestCases/file2.csv MAX
#   java JavaHelloWorld PublicTestCases/file2.csv DEPARTURES
#   java JavaHelloWorld PublicTestCases/file2.csv LIMIT 1
#   java JavaHelloWorld PublicTestCases/file2.csv LIMIT 2
#   java JavaHelloWorld PublicTestCases/file2.csv LIMIT 3
#	...
#
# Another assumption is that all of the source files are in the 
# default package and are in the src/ subdirectory.
#
#***************************

# Parameter $1 will be the PA2 command
# If the PA2 command is LIMIT, then will grab
# parameter $2 for number to limit things to.
# Global variables $infile, $inputdir,
# and $TESTS_PASSED are read and modified.
function runCmdNDiff() {
	base_in=$(basename $infile .csv)
	
	# runs current test and captures output
	# and also finds the expected output
	if [ "$1" == "LIMIT" ]
	then
		java $main $infile LIMIT $2 > out
		expected_file="../$inputdir/cmdLIMIT_$2-$base_in.out"
	else 
		java $main $infile $1 > out 
		expected_file="../$inputdir/cmd$1-$base_in.out"
	fi

	#checks if there is a difference between "user output" and "test output"
	if diff -B -w out $expected_file > diffout
	then
		echo "Passed $main test $infile"
		echo ""
		TESTS_PASSED=$((TESTS_PASSED+1))
	else
		echo "Failed $main test $infile"
		echo "*********** OUTPUT: Actual output followed by expected."
		cat diffout
		echo  "*******************************"
		echo ""
	fi
	rm diffout
}


# Check we need at least 2.
if [ $# -gt 1 ]
then
	# naming command-line parameters to script
    main=$1
    inputdir=$2
    
    # copying over all the source files into TestingTemp/
    # and then moving into that directory.
    cp src/*.java TestingTemp/
    cd TestingTemp/
    
    # compiling the driver and any local files it imports
    echo ""
    echo "==== compiling $main ===="
    javac $main.java
    if [ $? -ne 0 ]
    then
    	echo "******************************************"
    	echo "grade.sh ERROR: java compilation failed."
    	exit 1
	fi
    
    #gets the total number of tests from the PublicTest directory
    TOTAL_CSV=$(ls ../$inputdir/*.csv | wc -l)
    # FIXME: 5 is a magic number!!
    TOTAL_TESTS=$(($TOTAL_CSV * 5))
    TESTS_PASSED=0

    echo ""
    # if compilation worked then run it on each file in the given directory
	for infile in `ls -v ../$inputdir/*.csv`
	do
		runCmdNDiff "MAX"
		runCmdNDiff "DEPARTURES"
		runCmdNDiff "LIMIT" 1
		runCmdNDiff "LIMIT" 2
		runCmdNDiff "LIMIT" 3

	done
    echo "**** Passed $TESTS_PASSED / $TOTAL_TESTS tests for $main ****"
    echo ""

    #if all passed exit with status 0
    #if not exit with status 1
    if [ "$TOTAL_TESTS" -ne "$TESTS_PASSED" ]
    then
        exit 1
    else
        exit 0
    fi

# Not enough parameters given to script.
else
    echo
    echo "usage: ./grade.sh PA2Main PublicTestCases"
fi
echo
