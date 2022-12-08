#!/bin/bash
#Created by:Tom Webb
#Version 0.2
#usage linux-ir-create.sh filelist

#Error if no file given
if [ $# == 0 ]; then
echo -e "Usage: `basename $0` /path/to/file_list"
exit 1
fi

#Error if not sudo/root
if [[ $EUID -ne 0 ]]; then
echo "You must be root/sudo to run the script"
exit 1;
fi

echo "Enter the path where you want the /bin and /lib folders to be created"
read IR_LOCATION

#Setup DIR PATH
mkdir $IR_LOCATION/bin
mkdir $IR_LOCATION/lib

while read line; do

    FIND_BIN=`whereis -b $line|awk '{print $2}'` #Find the location of the binary file
        if  [ -z $FIND_BIN ]; then #if results empty
            echo "$line is not installed or in your path"

            else
            cp $FIND_BIN $IR_LOCATION/bin/IR_$line #Copies binary file to the new directory and renames it

            for i in `ldd  $FIND_BIN |grep '/' |cut -d '>' -f2- |cut -d '(' -f1`;    #Takes the path of the bin file and looks up required libraries and removes the 1st line and set as a variable
                do
                cp $i $IR_LOCATION/lib #Copies the library file to the new IR Location for each library
                done
        fi
done <$1 #Use file from command line argument
