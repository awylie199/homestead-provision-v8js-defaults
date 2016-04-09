#!/bin/bash
# Provisions Laravel Homestead Environment for V8 2.0 Engine and V8PHPJs extensions

# shellcheck source=./install_v8.sh
# shellcheck source=./install_php_v8.sh

# set -x

# Tput Formatting MAN TERMINFO
bold=$(tput bold)
normal=$(tput sgr0)

handleSig() {
    shopt -s nocasematch

    while true; do
        read -erp $'Do you want to cancel script execution? (y/n)\n' EXIT_CHECK
        case $EXIT_CHECK in
            "y*" )
                'Ok, exiting.'
                handle
            ;;
            "n*" )
                'Ok, continuing.'
                break
            ;;
            "*" )
                "Please enter 'y' or 'n'."
            ;;
        esac
    done

    shopt -u nocasematch
}

handleExit() {
    log "Exiting: $?"
    exit $?
}

log() {
    if [[ -n "$1" ]]; then
        echo "${bold}$1${normal}"
    else
        echo "${bold}Exiting${normal}"
    fi
}

trap "handleExit" EXIT
trap "handleSig" SIGINT SIGTERM SIGHUP

# Basic Checks
[[ ! -x "./install_v8.sh" ]] && echo "Can't execute V8 install script (./install_v8.sh)" && exit 1
[[ ! -x "./install_php_v8.sh" ]] && echo "Can't execute PHPV8Js install script (./install_php_v8.sh)" && exit 2
[[ ! -x "$(which php)" ]] && echo "Can't find PHP on path" && exit 3
[[ ! -x "$(which git)" ]] && echo "Can't find git on path" && exit 4

cat <<- _INTRO_
    ${bold}
        This file compiles and installs the V8js 2.0 engine and PHP V8js extension on the Homestead Vagrant environment.
    ${normal}
_INTRO_

shopt -s nocasematch

while true; do
    read -erp "Compile and Install V8 2.0 Engine? (y/n)" V8_INSTALL_CHECK
    case $V8_INSTALL_CHECK in
        "y*" )
            echo "${bold}Installing PHP V8Js extension...${normal}"
            #. ./install_php_v8.sh;
            break;
        ;;
        "n*" )
            break;
        ;;
        "*" )
            continue;
        ;;
    esac
done

while true; do
    read -erp "Compile and PHPV8 Js Extension? (y/n)" PHP_INSTALL_CHECK
    case $PHP_INSTALL_CHECK in
        "y*" )
            echo "${bold}Installing V8...${normal}"
            #. ./install_v8.sh;
            break;
        ;;
        "n*" )
            break;
        ;;
        "*" )
            continue;
        ;;
    esac
done

shopt -u nocasematch

echo "${bold}Install Successful${normal}"
exit 0
