#!/bin/bash
#
# htmparse.sh - v.01
#
# Feb,2019
#
# w41l3r


#
# Global vars
#

URL_LIST="urlist.txt"
FINAL_LIST="report.txt"

function print_banner {
echo
echo  "  _   _ _            ______           "        
echo  " | | | | |           | ___ \                  "
echo  " | |_| | |_ _ __ ___ | |_/ /_ _ _ __ ___  ___ "
echo  " |  _  | __| '_ \ _ \|  __/ _  | '__/ __|/ _ \\"
echo  " | | | | |_| | | | | | | | (_| | |  \__ \  __/"
echo  " \_| |_/\__|_| |_| |_\_|  \__,_|_|  |___/\___|"
echo
echo  " v.0.1, w41l3r - all rights Reserved :D"
echo
echo  " This software gets all urls referenced by some site"
echo  " (as much as possible!) and generates a list: $FINAL_LIST"
echo
}

function print_syntax {

echo  " Syntax: htmparse.sh -u url [-r num_of_recursive_iteracts]"
echo  "   e.g.: htmparse.sh -u sexypage.com -r 3"
echo
                                             
}

#This function gets informed url and generates a list of urls
# seen (href entries) in the index.html file
function spider {

SITE=$1

#Test url
if ! host $SITE >/dev/null 2>/dev/null
then
 echo "ERROR! ${SITE}:invalid url"
 exit 1
fi

#
#Try to download index
#
mkdir $SITE 2>/dev/null
cd $SITE
if [ $? -ne 0 ];then
 echo "Error: Insufficient privileges!"
 exit 1
fi

wget $SITE  >/dev/null 2>/dev/null
if [ $? -ne 0 ];then
 echo "ERROR downloading index from $SITE"
 echo "Exiting..."
 exit 1
fi

#Check index file
if [ -s "index.html" ];then
  INDEX="index.html"
elif [ -s "index.htm" ];then
 INDEX="index.htm"
else
  echo "Error: index not found. Exiting..."
  exit 1
fi

#Parse index file (work with href entries)
# and generate url list
cat $INDEX | sed 's/>/>\n/g' | grep href| cut -f3 -d/| \
 cut -f1 -d\" | sort -u| grep "\." > $URL_LIST

cd ..

#end of spider function
}

#############################################################
# Main
#############################################################

N_ITERACTS=0 #Iteracts counter, default value

if [ $# -lt 1 ]; then
print_banner
print_syntax
exit 9
fi

while getopts "u:i:" OPT; do
case "$OPT" in
"u") USERURL=$OPTARG;;
"i") N_ITERACTS=$OPTARG;;
"?") print_banner; print_syntax; exit 9;;
*) print_banner; print_syntax; exit 9;;
esac

if [ -z $USERURL ]; then
 print_banner
 print_syntax
 exit 9
fi

WORKDIR="${USERURL}-`date +%d%b%H%M`"
mkdir $WORKDIR 2>/dev/null
if [ $? -ne 0 ];then
 echo "Error creating work_dir. Exiting..."
 exit 1
fi
cd $WORKDIR

spider $USERURL

#
#if user wants recursive...
#
if [ $N_ITERACTS -gt 0 ];then
 i=0
 echo "Starting recursive spider, level $i..."
 while [ $i -lt $N_ITERACTS ];do
  cat */$URL_LIST | while read urline
  do
	if [ -d "$urline" ];then
          continue #url already taken
	fi
	spider $urline
  done
 done
fi

cat */$URL_LIST |sort -u |uniq -c >> $FINAL_LIST

exit 0
