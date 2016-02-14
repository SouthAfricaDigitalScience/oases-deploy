#!/bin/bash -e
# Deploy script for OASES
. /etc/profile.d/modules.sh
module add deploy
module add zlib
module add velvet
cd ${WORKSPACE}/${NAME}-${VERSION}/
echo "All tests have passed, will now build into ${SOFT_DIR}"
make clean
make
echo "Buld has passed, now copying to install directory"
cp -rvf oases ${SOFT_DIR}
cp -rvf scripts src obj OasesManual.pdf ${SOFT_DIR}

echo "Creating the modules file directory ${LIBRARIES_MODULES}"
mkdir -p ${BIOINFORMATICS_MODULES}/${NAME}
(
cat <<MODULE_FILE
#%Module1.0
## $NAME modulefile
##
proc ModulesHelp { } {
    puts stderr "       This module does nothing but alert the user"
    puts stderr "       that the [module-info name] module is not available"
}

module-whatis   "$NAME $VERSION."
setenv       OASES_VERSION       $VERSION
setenv       OASES_DIR           $::env(CVMFS_DIR)$::env(SITE)/$::env(OS)/$::env(ARCH)/$NAME/$VERSION
prepend-path PATH                $::env(OASES_DIR)/
prepend-path PATH                $::env(OASES_DIR)/scripts
# Add CFLAGS if you want to compile against the headers
prepend-path CFLAGS              $::env(OASES_DIR)/src
MODULE_FILE
) > ${LIBRARIES_MODULES}/${NAME}/${VERSION}
