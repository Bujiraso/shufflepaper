#!/usr/bin/env bash
# make file to deploy shufflepaper to a chosen directory

myDir=$(readlink -f $(dirname "${0}"))
install() {
    if [[ ${#} -eq 0 ]]; then
        echo "Usage: make install INSTALL_DIR"
        exit 1
    fi

    installDir="${1}"

    if ! ls "${myDir}/bin/sfp" > /dev/null 2> /dev/null; then
        echo "make.sh cannot find shuffle paper install files for copying while searching in '${myDir}'. Are the files there?"
        exit 1
    fi

    # Install all sfp scripts to the install dir as executables
    install -Dm 755 -t "${installDir}" "${myDir}"/bin/sfp*
}

function test() {
    # Put the bin dir here at the start of the path to ensure intercepting of user's config
    export PATH="${myDir}/bin/":${PATH}
    for testFile in "${myDir}"/t/*; do
        "${testFile}"
        testResult=${?}
        if [[ ${testResult} -ne 0 ]]; then
            echo "== TEST FAILED ==" > /dev/stderr
            echo "The failed test case is t/$(basename "${testFile}")" > /dev/stderr
            return ${testResult}
        fi
    done
    echo "PASS"
}

# Main logic {
if [[ ${#} -eq 0 ]];then
    echo "Usage: ${0} (install INSTALL_DIR|test)"
    exit 0
fi

command=${1}
shift
${command} "${@}"
# } 
