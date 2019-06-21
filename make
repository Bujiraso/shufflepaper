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
    # Test Range is the files to test
    testRange="${1}"

    testEnv="${myDir}/.testenv"

    for testFile in ${testRange:-"${myDir}"/t/*}; do
        # Skip directories and test env's
        if [[  -d "${testFile}" || ! -x "${testFile}" ]]; then
            continue
        fi

        echo "Testing class: $(basename "${testFile}") ... "
        env -i "$(readlink -f "${testFile}")" "${testEnv}"
        testResult=${?}
        if [[ ${testResult} -ne 0 ]]; then
            echo "== TESTS FAILED ==" > /dev/stderr
            echo "The failed test class is t/$(basename "${testFile}")" > /dev/stderr
            return ${testResult}
        fi
        echo
    done
    echo "== TESTS PASS =="
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
