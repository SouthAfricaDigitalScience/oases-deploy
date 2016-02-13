#!/bin/bash -e
# Check build file for OASES
. /etc/profile.d/modules.sh
module add ci
module add velvet
cd ${WORKSPACE}/${NAME}_${VERSION}/

cp -rvf oases ${SOFT_DIR}
cp -rvf scripts src obj OasesManual.pdf ${SOFT_DIR}

mkdir -p ${SOFT_DIR}
mkdir -p modules
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
setenv       OASES_DIR           /apprepo/$::env(SITE)/$::env(OS)/$::env(ARCH)/$NAME/$VERSION
prepend-path PATH                $::env(OASES_DIR)/
prepend-path PATH                $::env(OASES_DIR)/scripts
# Add CFLAGS if you want to compile against the headers
prepend-path CFLAGS              $::env(OASES_DIR)/src
MODULE_FILE
) > modules/$VERSION

mkdir -p ${BIOINFORMATICS_MODULES}/${NAME}
cp modules/$VERSION ${BIOINFORMATICS_MODULES}/${NAME}
