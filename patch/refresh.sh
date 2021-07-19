#!/bin/sh

# This script is used to create a new version of the patch to include FR24 elements in the webpage
# It downloads the flightaware/dump1090 release indicated in the DUMP1090_VERSION environment variable, adds the FR logo to the HTML source tree and applies the patch

# Exit if the DUMP1090_VERSION environment variable not set
if [ -z "${DUMP1090_VERSION}" ]; then
  echo "FATAL: the DUMP1090_VERSION environment variable not defined. Exiting..."
  exit
fi

# Define the file to download and the folders to work in
URL=https://github.com/flightaware/dump1090/archive/${DUMP1090_VERSION}.tar.gz
DIR=`dirname "$(readlink -f "$0")"`
UPSTREAM=$DIR/upstream
MODIFIED=$DIR/modified

# Delete any folders that might have been left from a previous execution
rm -rf $UPSTREAM
rm -rf $MODIFIED
mkdir -p $UPSTREAM

UPSTREAM_RELEASE_FILE=/tmp/flightaware_dump1090_${DUMP1090_VERSION}.tar.gz
if [ ! -f "${UPSTREAM_RELEASE_FILE}" ]; then
  echo "Downloading flightaware/dump1090 release ${DUMP1090_VERSION}"
  wget -O ${UPSTREAM_RELEASE_FILE} $URL
fi
tar xzf ${UPSTREAM_RELEASE_FILE} --directory=$UPSTREAM
# Don't delete the downloaded file if in DEVEL mode, so as not to have to redownload it
if [ -z "${DEVEL}" ]; then
  rm ${UPSTREAM_RELEASE_FILE}
fi

# Move the upstream files one level up, so as to not keep the version number in the path
mv $UPSTREAM/dump1090-*/* $UPSTREAM
rm -r $UPSTREAM/dump1090-*/
# Copy the freshly downloaded release files to the `modified` folder to apply the patches to
cp -r $UPSTREAM $MODIFIED

# In DEVEL mode, add dummy aircrafts file
if [ ! -z "${DEVEL}" ]; then
  DUMMY_AIRCRAFTS_FILE=$DIR/resources/aircraft.json
  if [ ! -f "${DUMMY_AIRCRAFTS_FILE}" ]; then
    echo "Downloading dummy aircraft.json file"
    wget -O ${DUMMY_AIRCRAFTS_FILE} https://docker-fr24feed-piaware-dump1090.netlify.app/data/aircraft.json
  fi
  if [ -f "${DUMMY_AIRCRAFTS_FILE}" ]; then
    mkdir -p $MODIFIED/public_html_merged/data/
    cp $DUMMY_AIRCRAFTS_FILE $MODIFIED/public_html_merged/data/
  fi
fi

echo "Modifying the web page to include Flightradar24 elements"
# Copy the FR24 logo to the images folder in the `modified` folder
cp $DIR/resources/fr24-logo.svg $DIR/modified/public_html_merged/images
# Patch the files in the `modified` folder
patch --ignore-whitespace -p1 -ru --force -d $DIR/modified < $DIR/flightradar24.patch

# Done -- See README.md file if the previous command failed, could happen if upstream changed the same lines in their latest release
if [ $? -eq 0 ]
then
  echo "\nFiles succesfully patched, open this file in your webbrowser to see the changes:"
  echo "$MODIFIED/public_html_merged/index.html"
  echo "You can also run a quick-and-dirty web server to serve these files:"
  echo "python3 -m http.server 8000 --bind 127.0.0.1 --directory $MODIFIED/public_html_merged"
else
  echo "\nERROR: Patching the files failed, please review the previous output to identify where." >&2
  echo "It likely means that there were changes made upstream to the same lines that are changed by the patch, see README.md file for a suggestion on how to update the patch file."
fi
