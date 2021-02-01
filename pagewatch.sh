#!/bin/bash
# pagewatch.sh - Monitors a web page for changes
# Captures page using headless chromium, parses and simplifies with lynx, then prints any changes to console
# Why chromium first, instead of just lynx? Javascript support.

# Usage: ./pagewatch.sh [url] [check interval]

# TODO add flags: debug/verbose, quiet/don't-print-diff-results, bell
# TODO add option to screen out changes that don't include spaces (basic attempt at finding natural language changes only)
# TODO make sure the headless chromium is actually running javascript. :/

# Care for Mother Earth, use recycled code!

if [ $# -lt 2 ]; then
	echo "Usage: ./pagewatch.sh [url] [check interval]"
	exit 1
fi

TARGET=$1
INTERVAL=$2
URLHASH=$(echo -n $TARGET | sha1sum | cut -d" " -f1)  # allows for running multiple pagewatch instances covering different pages without issue
TEMPDIR=pagewatch-working

function getthepage {
	chromium --headless --disable-gpu --dump-dom $TARGET > $TEMPDIR/$URLHASH.html
	lynx --dump --nolist $TEMPDIR/$URLHASH.html > $TEMPDIR/$URLHASH-new.txt 2>/dev/null
}

# main
mkdir -p $TEMPDIR
echo Getting a first look at $TARGET
getthepage
echo Watching...
for (( ; ; )); do	# for(ever) should be valid syntax, just sayin
	sleep $INTERVAL
	mv $TEMPDIR/$URLHASH-new.txt $TEMPDIR/$URLHASH-old.txt 2>/dev/null
	getthepage
	DIFF_OUTPUT="$(diff $TEMPDIR/$URLHASH-old.txt $TEMPDIR/$URLHASH-new.txt)"
	if [ "0" != "${#DIFF_OUTPUT}" ]; then
		echo CHANGE DETECTED $(date)
		diff --color=auto $TEMPDIR/$URLHASH-old.txt $TEMPDIR/$URLHASH-new.txt
	fi
done
