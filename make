#!/usr/bin/env bash
# make file to deploy shufflepaper to a chosen directory

export BASE_DIR=$(readlink -f $(dirname "${0}"))
install() {
    if [[ ${#} -eq 0 ]]; then
        echo "Usage: make install INSTALL_DIR"
        exit 1
    fi

    installDir="${1}"

    if ! ls "${BASE_DIR}/bin/sfp" > /dev/null 2> /dev/null; then
        echo "make.sh cannot find shuffle paper install files for copying while searching in '${BASE_DIR}'. Are the files there?"
        exit 1
    fi

    # Install all sfp scripts to the install dir as executables
    install -Dm 755 -t "${installDir}" "${BASE_DIR}"/bin/sfp*
}

function test() {
    # Test Range is the files to test
    if [[ ! -z ${1+x} ]]; then
        testRange="$(readlink -f "${1}")"
    else
        testRange=$(readlink -f "${BASE_DIR}"/t/*)
    fi

    echo "${testRange}" | while read testFile; do
        # Skip directories and test env's
        if [[  -d "${testFile}" || ! -x "${testFile}" ]]; then
            continue
        fi

        env -i "${BASE_DIR}/test-runner" "${testFile}"
        testResult=${?}
        if [[ ${testResult} -ne 0 ]]; then
            echo "== TESTS FAILED ==" > /dev/stderr
            echo "The failed test class is t/$(basename "${testFile}")" > /dev/stderr
            return ${testResult}
        else
            echo
        fi
    done
    echo "== TESTS PASS =="
}

# Main logic {
if [[ ${#} -eq 0 ]];then
    echo "Usage: ${0} install INSTALL_DIR"
    echo "Usage: ${0} test [TEST_CLASSES]"
    exit 0
fi

command=${1}
shift
${command} "${@}"
# }
