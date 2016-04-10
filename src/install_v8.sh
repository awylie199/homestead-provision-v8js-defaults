#!/bin/bash
# Compiles and Installs V8Js 2.0 Engine
# https://github.com/phpv8/v8js/blob/master/README.Linux.md

# set -x

DEPOT_TOOLS_REPO="https://chromium.googlesource.com/chromium/tools/depot_tools.git"
DEPOT_TOOLS="depot_tools"

${BOLD}
cd /tmp || printf "Can't enter /tmp directory.\n" && exit 1
${NORMAL}

# Install depot_tools first (needed for source checkout)
if [[ ! -d $DEPOT_TOOLS ]]; then
    git clone $DEPOT_TOOLS_REPO $DEPOT_TOOLS
fi

${BOLD}
(( $? == 0 )) && [[ -d $DEPOT_TOOLS ]] || printf "Failed cloning chromium depot tools.\n" && exit 2
${NORMAL}

PATH=$PATH:$(pwd)/${DEPOT_TOOLS}
export PATH

# Download v8
fetch v8

${BOLD}
cd v8 || printf "Can't enter fetched v8 directory.\n" && exit 3
${NORMAL}

if [[ -n $SPECIFIC_V8_VERSION ]]; then
    git checkout "$SPECIFIC_V8_VERSION"
    if (( $? == 0 )); then
        gclient sync
    else
        printf "Failed checkout of version: %s\n" "$SPECIFIC_V8_VERSION"
        exit 4
    fi
fi

# use libicu of operating system
export GYP_DEFINES="use_system_icu=1"

# Build (with internal snapshots)
export GYPFLAGS="-Dv8_use_external_startup_data=0"
make native library=shared snapshot=on -j8

# Install to /usr
sudo mkdir -p "/usr/lib" "/usr/include"
sudo cp out/native/lib.target/lib*.so "/usr/lib/"
sudo cp -R include/* /usr/include
echo -e "create /usr/lib/libv8_libplatform.a\naddlib" "out/native/obj.target/tools/gyp/libv8_libplatform.a\nsave\nend" | sudo ar -M

exit $?
