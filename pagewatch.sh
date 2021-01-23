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

USERAGENT="Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:86.0) Gecko/20100101 Firefox/86.0"
# some websites don't like lynx. yeah, we're totally firefox on win10

echo Getting a first look at $1
#curl $1 -L --compressed -s > pagewatch-$URLHASH-new.temp
lynx --dump --nolist --useragent="$USERAGENT" $1 > pagewatch-$URLHASH-new.temp 2>/dev/null
echo Watching...
for (( ; ; )); do	# for(ever) should be valid syntax, just sayin
	sleep $2
	mv pagewatch-$URLHASH-new.temp pagewatch-$URLHASH-old.temp 2>/dev/null
	#curl $1 -L --compressed -s > pagewatch-$URLHASH-new.temp
	lynx --dump --nolist --useragent="$USERAGENT" $1 > pagewatch-$URLHASH-new.temp 2>/dev/null
	DIFF_OUTPUT="$(diff pagewatch-$URLHASH-old.temp pagewatch-$URLHASH-new.temp)"
	if [ "0" != "${#DIFF_OUTPUT}" ]; then
		echo CHANGE DETECTED $(date)
		diff --color=always pagewatch-$URLHASH-old.temp pagewatch-$URLHASH-new.temp
	fi
done
