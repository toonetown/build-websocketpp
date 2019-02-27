#!/bin/bash

cd "$(dirname "${0}")"
BUILD_DIR="$(pwd)"
cd ->/dev/null

# Overridable build locations
: ${DEFAULT_WEBSOCKETPP_DIST:="${BUILD_DIR}/websocketpp"}
: ${OBJDIR_ROOT:="${BUILD_DIR}/target"}

print_usage() {
    while [ $# -gt 0 ]; do
        echo "${1}" >&2
        shift 1
        if [ $# -eq 0 ]; then echo "" >&2; fi
    done
    echo "Usage: ${0} [/path/to/websocketpp-dist] <'package'|'clean'>"                      >&2
    echo ""                                                                                 >&2
    echo "\"/path/to/websocketpp-dist\" is optional and defaults to:"                       >&2
    echo "    \"${DEFAULT_WEBSOCKETPP_DIST}\""                                              >&2
    echo ""                                                                                 >&2
    echo "You can specify to package the release (after it's already been built) by"        >&2
    echo "running \"${0} package /path/to/output"                                           >&2
    echo ""                                                                                 >&2
    return 1
}

do_clean() { rm -rf "${OBJDIR_ROOT}"; }

do_copy_headers() {
    do_clean || return $?
    mkdir -p "${OBJDIR_ROOT}/include" || return $?
    cp -r "${PATH_TO_WEBSOCKETPP_DIST}/websocketpp" "${OBJDIR_ROOT}/include/" || return $?
}

do_package() {
    [ -d "${1}" ] || {
        print_usage "Invalid package output directory:" "    \"${1}\""
        exit $?
    }
    
    # Copy the headers
    do_copy_headers || return $?
    
    # Build the tarball
    VER="$(cat "${PATH_TO_WEBSOCKETPP_DIST}/CMakeLists.txt" \
           | sed -nE 's/^set \(WEBSOCKETPP_.+_VERSION ([0-9]+)\).*$/\1./p' \
           | tr -d '\n' \
           | sed -e 's/\.$//g')"
    BASE="websocketpp-${VER}"
    cp -r "${OBJDIR_ROOT}" "${BASE}" || exit $?
    rm -rf "${BASE}/"*"/build" || exit $?
    find "${BASE}" -name .DS_Store -exec rm {} \; || exit $?
    tar -zcvpf "${1}/${BASE}.tar.gz" "${BASE}" || exit $?
    rm -rf "${BASE}"
}


# Calculate the path to the websocketpp-dist repository
if [ -d "${1}" ]; then
    cd "${1}"
    PATH_TO_WEBSOCKETPP_DIST="$(pwd)"
    cd ->/dev/null
    shift 1
else
    PATH_TO_WEBSOCKETPP_DIST="${DEFAULT_WEBSOCKETPP_DIST}"
fi

[ -d "${PATH_TO_WEBSOCKETPP_DIST}" -a \
  -f "${PATH_TO_WEBSOCKETPP_DIST}/websocketpp/client.hpp" -a \
  -f "${PATH_TO_WEBSOCKETPP_DIST}/CMakeLists.txt" ] || {
    print_usage "Invalid Websocket++ directory:" "    \"${PATH_TO_WEBSOCKETPP_DIST}\""
    exit $?
}


# Call bootstrap if that's what we specified
if [ "${1}" == "bootstrap" ]; then
    do_bootstrap ${2}
    exit $?
fi

# Call the appropriate function based on target
TARGET="${1}"; shift
case "${TARGET}" in
    "clean")
        do_clean
        ;;
    "package")
        do_package "$@"
        ;;
    *)
        print_usage "Missing/invalid target '${TARGET}'"
        ;;
esac
exit $?
