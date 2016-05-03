#!/bin/bash

#
# Script to launch cache-import to automatically import source files from a
# Caché instance for this project
#
# Right now it is supposed that this project lives into its own namespace...
# This is a limitation which will be removed in the future.
#

#
# Read the information on how to build the jar on cache-import project page:
#
# https://github.com/litesolutions/cache-import
#
CACHE_IMPORT_JAR="$HOME/bin/cache-import.jar"

if [ ! -f "$CACHE_IMPORT_JAR" ]; then  
    echo >&2 "cache-import.jar not found"
    exit 1
fi

echo -n "Enter username: "
read USER

echo -n "Enter password: "
read -s PASSWORD

echo

java -jar $CACHE_IMPORT_JAR export cfg=cache-import.properties \
    user="$USER" password="$PASSWORD"

if [ "$?" != "0" ]; then
    echo >&2 "Failed to retrieve sources :( Please check the stack trace above"
    exit 1
fi

#
# Another limitation...
#

# No idea why, we always get this... We don't want it

rm -rf src/INFORMATION

#
# Also, clean up the files:
#
# * clear all spaces at the end of lines;
# * turn crlf into lf all around
#

find src -type f -exec dos2unix {} \;
find src -type f -exec sed -i 's,\s\+$,,' {} \;

