#!/bin/bash
# pagewatch.sh - Monitors a web page for changes
# Usage: ./pagewatch.sh [url] [check interval]
# Original code shamelessly borrowed from bhfsteve: http://bhfsteve.blogspot.com/2013/03/monitoring-web-page-for-changes-using.html

if [ $# -lt 2 ]; then
    echo "Usage: ./pagewatch.sh [url] [check interval]"
    exit
fi

URLHASH=$(echo -n $1 | sha1sum | cut -d" " -f1)

echo Getting a first look at $1
curl $1 -L --compressed -s > pagewatch-$URLHASH-new.html
echo Watching...
for (( ; ; )); do
    sleep $2
    mv pagewatch-$URLHASH-new.html pagewatch-$URLHASH-old.html 2> /dev/null
    curl $1 -L --compressed -s > pagewatch-$URLHASH-new.html
    DIFF_OUTPUT="$(diff pagewatch-$URLHASH-new.html pagewatch-$URLHASH-old.html)"
    if [ "0" != "${#DIFF_OUTPUT}" ]; then
        echo CHANGE DETECTED $(date)
    fi
done
