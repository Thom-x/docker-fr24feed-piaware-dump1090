#!/bin/sh

# This script is used to create a new version of the patch to include FR24 elements in the webpage
# It downloads the flightaware/dump1090 release indicated in the DUMP1090_VERSION environment variable, adds the FR logo to the HTML source tree and applies the patch

# Define the file to download and the folders to work in
URL=https://github.com/flightaware/dump1090/archive/${DUMP1090_VERSION}.tar.gz
DIR=`dirname "$(readlink -f "$0")"`
UPSTREAM=$DIR/upstream
MODIFIED=$DIR/modified

# Delete any folders that might have been left from a previous execution
rm -rf $UPSTREAM
rm -rf $MODIFIED
mkdir -p $UPSTREAM

echo "Downloading flightaware/dump1090 release ${DUMP1090_VERSION}"
wget -O /tmp/flightaware_dump1090.tar.gz $URL
tar xzf /tmp/flightaware_dump1090.tar.gz --directory=$UPSTREAM
rm /tmp/flightaware_dump1090.tar.gz
# Copy the freshly downloaded release files to the `modified` folder to apply the patches to
cp -r $UPSTREAM $MODIFIED

echo "Modifying the web page to include Flightradar24 elements"
# Copy the FR24 logo to the images folder in the `modified` folder
cp $DIR/resources/fr24-logo.svg $DIR/modified/dump1090-3.8.1/public_html/images
# Patch the files in the `modified` folder
patch -p2 -ru -d $DIR/modified < $DIR/flightradar24.patch

# Done -- See README.md file if the previous command failed, could happen if upstream changed the same lines in their latest release
echo "\nFiles succesfully patched, open this file in your webbrowser to see the changes:"
echo "$MODIFIED/dump1090-3.8.1/public_html/index.html"
