#!/bin/bash
# Compiles and Installs V8Js 2.0 Engine

# set -x

DEPOT_TOOLS_REPO="https://chromium.googlesource.com/chromium/tools/depot_tools.git"
DEPOT_TOOLS="depot_tools"
V8_PATH="/usr"

# Install V8 Engine to Custom Directory
read -er -t 20 -p $'Do you want to install V8 to a custom directory? Enter a directory now, otherwise it will be installed to the default "/usr" directory.\n' V8_PATH_OVERRIDE

[[ -n $V8_PATH_OVERRIDE && -d $V8_PATH_OVERRIDE ]] && V8_PATH=$V8_PATH_OVERRIDE

echo "V8 Path set to: ${bold}$V8_PATH${normal}"

cd /tmp || echo "${bold}Can't enter /tmp directory.${normal}" && exit 1

# Install depot_tools first (needed for source checkout)
if [[ ! -d $DEPOT_TOOLS ]]; then
    git clone $DEPOT_TOOLS_REPO $DEPOT_TOOLS
fi

[[ ! -d $DEPOT_TOOLS ]] && echo "${bold}Failed cloning chromium depot tools.${normal}" && exit 2

PATH=$PATH:$(pwd)/${DEPOT_TOOLS}
export PATH

# Download v8
fetch v8
cd v8 || echo "${bold}Can't enter fetched v8 directory.${normal}" && exit 3

# (optional) If you'd like to build a certain version:

shopt -s nocasematch

while true; do
    read -er -t 20 -p $'Do you want to build a specific version? (y/n)\n' VERSION_RESPONSE
    [[ -z $VERSION_RESPONSE ]] && VERSION_RESPONSE='n'
    case $VERSION_RESPONSE in
        "y*" )
            while true; do
                read -erp $'What version? (e.g. 4.9.385.28)\n' VERSION
                if [ -n "$VERSION" ]; then
                    git checkout "$VERSION"
                    if (( $? == 0 )); then
                        gclient sync
                        break;
                    else
                        echo "Failed checkout of version: $VERSION"
                        continue;
                    fi
                else
                    echo "Please enter a version string"
                    continue;
                fi
            done
            break
        ;;
        "n*" )
            break
        ;;
        "*" ) echo "Please enter 'y' or 'n'"
            continue
    esac
done

shopt -u nocasematch

# use libicu of operating system
export GYP_DEFINES="use_system_icu=1"

# Build (with internal snapshots)
export GYPFLAGS="-Dv8_use_external_startup_data=0"
make native library=shared snapshot=on -j8

# Install to V8_PATH
sudo mkdir -p "${V8_PATH}/lib" "${V8_PATH}/include"
sudo cp out/native/lib.target/lib*.so "${V8_PATH}/lib/"
sudo cp -R include/* /usr/include
echo -e "create ${V8_PATH}/lib/libv8_libplatform.a\naddlib" "out/native/obj.target/tools/gyp/libv8_libplatform.a\nsave\nend" | sudo ar -M

exit 0
