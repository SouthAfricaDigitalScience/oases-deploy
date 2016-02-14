#!/bin/bash -e
# Build script for OASES
. /etc/profile.d/modules.sh

module add ci
module add zlib
module add velvet

SOURCE_FILE=${NAME}_${VERSION}.tgz

echo "REPO_DIR is "
echo $REPO_DIR
echo "SRC_DIR is "
echo $SRC_DIR
echo "WORKSPACE is "
echo $WORKSPACE
echo "SOFT_DIR is"
echo $SOFT_DIR

mkdir -p ${WORKSPACE}
mkdir -p ${SRC_DIR}

#  Download the source file

if [ ! -e ${SRC_DIR}/${SOURCE_FILE}.lock ] && [ ! -s ${SRC_DIR}/${SOURCE_FILE} ] ; then
  touch  ${SRC_DIR}/${SOURCE_FILE}.lock
  echo "seems like this is the first build - let's geet the source"
  wget https://www.ebi.ac.uk/~zerbino/${NAME}/${SOURCE_FILE} -O ${SRC_DIR}/${SOURCE_FILE}
  echo "releasing lock"
  rm -v ${SRC_DIR}/${SOURCE_FILE}.lock
elif [ -e ${SRC_DIR}/${SOURCE_FILE}.lock ] ; then
  # Someone else has the file, wait till it's released
  while [ -e ${SRC_DIR}/${SOURCE_FILE}.lock ] ; do
    echo " There seems to be a download currently under way, will check again in 5 sec"
    sleep 5
  done
else
  echo "continuing from previous builds, using source at " ${SRC_DIR}/${SOURCE_FILE}
fi

# The version in the name of the tarball the directory which it contains differ : 0.2.08 vs 0.2.8
# We therefore need to create the directory by hand and use the strip-components trick.
mkdir -p ${WORKSPACE}/${NAME}-${VERSION}
tar xzf  ${SRC_DIR}/${SOURCE_FILE} -C ${WORKSPACE}/${NAME}-${VERSION} --skip-old-files --strip-components=1
cp Makefile ${WORKSPACE}/${NAME}-${VERSION}
cd ${WORKSPACE}/${NAME}-${VERSION}/


make
