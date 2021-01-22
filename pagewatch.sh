#!/bin/bash
# pagewatch.sh - Monitors a web page for changes
# Requires lynx

# Usage: ./pagewatch.sh [url] [check interval]

# Original code shamelessly borrowed from bhfsteve: http://bhfsteve.blogspot.com/2013/03/monitoring-web-page-for-changes-using.html

if [ $# -lt 2 ]; then
	echo "Usage: ./pagewatch.sh [url] [check interval]"
	exit
fi

URLHASH=$(echo -n $1 | sha1sum | cut -d" " -f1)

echo Getting a first look at $1
#curl $1 -L --compressed -s > pagewatch-$URLHASH-new.temp
lynx --dump $1 > pagewatch-$URLHASH-new.temp
echo Watching...
for (( ; ; )); do	# for(ever) should be valid syntax, just sayin
	sleep $2
	mv pagewatch-$URLHASH-new.temp pagewatch-$URLHASH-old.temp 2> /dev/null
	#curl $1 -L --compressed -s > pagewatch-$URLHASH-new.temp
	lynx --dump $1 > pagewatch-$URLHASH-new.temp
	DIFF_OUTPUT="$(diff pagewatch-$URLHASH-new.temp pagewatch-$URLHASH-old.temp)"
	if [ "0" != "${#DIFF_OUTPUT}" ]; then
		echo CHANGE DETECTED $(date)
		echo $DIFF_OUTPUT
	fi
done
