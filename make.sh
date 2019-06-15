#!/usr/bin/env bash

if [[ ${#} -eq 0 ]]; then
    echo "Need install dir"
    exit 1
fi

installDir="${1}"
myDir=$(readlink -f $(dirname "${0}"))

if ! ls "${myDir}/bin/sfp" > /dev/null 2> /dev/null; then
    echo "make.sh cannot find shuffle paper install files for copying while searching in '${myDir}'. Are the files there?"
    exit 1
fi

install -Dm 755 "${myDir}/bin/alterWallInDB.sh" "${installDir}"
install -Dm 755 "${myDir}/bin/changeBG.sh" "${installDir}"
install -Dm 755 "${myDir}/bin/getSQLStatement.sh" "${installDir}"
install -Dm 755 "${myDir}/bin/getWallURI.sh" "${installDir}"
install -Dm 755 "${myDir}/bin/install.sh" "${installDir}"
install -Dm 755 "${myDir}/bin/randomBG.sh" "${installDir}"
install -Dm 755 "${myDir}/bin/removeWall.sh" "${installDir}"
install -Dm 755 "${myDir}/bin/sfp" "${installDir}"
install -Dm 755 "${myDir}/bin/wallDims.sh" "${installDir}"
install -Dm 755 "${myDir}/bin/wallMiner.sh" "${installDir}"
install -Dm 755 "${myDir}/bin/wallOption.sh" "${installDir}"
install -Dm 755 "${myDir}/bin/wallStats.sh" "${installDir}"
