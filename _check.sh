#!/bin/bash
## Checking for required dependencies
## @date 2024-06-14 (last modifications)

#EDIT=nano

# https://intoli.com/blog/exit-on-errors-in-bash-scripts/

echo "Running" `realpath $0`
source ./screen.ini

set -e 
echo -e $COLOR3"\n\tThis script stops on any error!\n\tWhen it stop, remove source of the error & run it again!\n"$NORMCO
     
echo -e "Test for required software:\n" 
echo -e "Processing.org..."

find ~/ -name "processing" -type f -executable -print > processing_dirs.lst
grep --color "processing" processing_dirs.lst
wc -l processing_dirs.lst

echo -e $COLOR1"\n\tLooks like you have Processing."$NORMCO
echo -e $COLOR3"\tRemember to run 'install' in its main directory.\n"$NORMCO

#echo -e "\nVideo library..."exp
#find ~/ -name "hamoid"  -print > hamoid_dirs.lst
#grep --color "hamoid" hamoid_dirs.lst
#wc -l hamoid_dirs.lst

#echo -e "\n\tLooks like you have Hamoid Video Library."

#echo -e "\nffmpeg tool..."
#ffmpeg -version | grep --color "ffmpeg.*version"
#echo -e "\n\tLooks like you have ffmpeg tool instaled\n"


#instalacja zmiennej ze ścieżką do IDE processingu
#jesli jest to potrzebne
set +e
echo -e $COLOR1"In"$COLOR2 $HOME/.profile $COLOR1":"$NORMCO

grep -q "PRIDE" $HOME/.profile

if [  $? != 0  ]
then
     tmp=`tail -1 processing_dirs.lst`
     PRIDE="$tmp"
     echo -e "\nProcessing IDE is" $PRIDE
     echo -e "\nexport PRIDE="$tmp >> $HOME/.profile
fi

grep --color "PRIDE" $HOME/.profile

echo;echo
