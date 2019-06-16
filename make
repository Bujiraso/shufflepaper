#!/usr/bin/env bash
# make file to deploy shufflepaper to a chosen directory

if [[ ${#} -eq 0 ]]; then
    echo "Usage: ${0} INSTALL_DIR"
    exit 1
fi

installDir="${1}"
myDir=$(readlink -f $(dirname "${0}"))

if ! ls "${myDir}/bin/sfp" > /dev/null 2> /dev/null; then
    echo "make.sh cannot find shuffle paper install files for copying while searching in '${myDir}'. Are the files there?"
    exit 1
fi

# Install all sfp scripts to the install dir as executables
install -Dm 755 -t "${installDir}" "${myDir}"/bin/sfp*
