#!/bin/bash
# Provisions Laravel Homestead Environment for V8 2.0 Engine and V8PHPJs extensions
# https://github.com/phpv8/v8js/blob/master/README.Linux.md
# set -x

V8_INSTALL_SCRIPT="./src/install_v8.sh"
PHP_V8_INSTALL_SCRIPT="./src/install_php_v8.sh"

INSTALL_V8=0
INSTALL_PHP_V8=0
SPECIFIC_V8_VERSION=''

PHP_LOCATION=$(find /etc -maxdepth 1 -type d -name "php")

# Tput Formatting MAN TERMINFO
INLINE_BOLD=$(tput bold)
BOLD () {
    tput bold
}
INLINE_NORMAL=$(tput sgr0)
NORMAL () {
    tput sgr0
}

handleSig () {
    printf "Script terminated\n"
    exit 130
}

trap "handleSig" SIGINT

# Basic Preliminary Checks
BOLD
[[ -x $V8_INSTALL_SCRIPT ]] || ( printf "Can't execute V8 install script (%s)\n" $V8_INSTALL_SCRIPT && exit 126 )
[[ -x $PHP_V8_INSTALL_SCRIPT ]] || ( printf "Can't execute PHPV8Js install script (%s)\n" $PHP_V8_INSTALL_SCRIPT && exit 126 )

[[ -x $(which php) ]] || ( printf 'Cant find PHP on path.\n' && exit 127 )
[[ -x $(which git) ]] || ( printf 'Cant find git on path.\n' && exit 127 )
[[ -x $(which make) ]] || ( printf 'Cant find make on path.\n' && exit 127 )
NORMAL

cat <<- _INTRO_

    This script compiles and installs the V8js 2.0 engine and PHP V8js extension,
    intended for provisioning  the Homestead Vagrant environment.

    V8 is installed to the /usr directory. ${INLINE_BOLD}This may overwrite the system copy of V8.${INLINE_NORMAL}

    https://github.com/talyssonoc/react-laravel/blob/master/install_v8js.md

_INTRO_

shopt -s nocasematch

echo $V8_INSTALL_SCRIPT

while true; do
    read -erp $'Compile and install V8 2.0 engine? (y/n)\n' V8_INSTALL_CHECK
    case $V8_INSTALL_CHECK in
        y* )
            INSTALL_V8=1

            # Check to see whether a specific version is needed
            while true; do
                read -er -t 20 -p $'Do you want to build a specific version? (y/n)\n' VERSION_RESPONSE
                [[ -z $VERSION_RESPONSE ]] && VERSION_RESPONSE='n'
                case $VERSION_RESPONSE in
                    y* )
                        while true; do
                            read -erp $'Which version? (e.g. 4.9.385.28)\n' SPECIFIC_V8_VERSION
                            if [[ -n $SPECIFIC_V8_VERSION ]]; then
                                break
                            else
                                printf 'Please enter a version. (e.g. 4.9.385.28)\n'
                                continue;
                            fi
                        done
                        break
                    ;;
                    n* )
                        break
                    ;;
                    * )
                        printf 'Please enter "y" or "n"\n'
                        continue
                esac
            done

            break;
        ;;
        n* )
            break;
        ;;
        * )
            continue;
        ;;
    esac
done

while true; do
    read -erp $'Compile and install PHPV8 JS extension? (y/n)\n' PHP_INSTALL_CHECK
    case $PHP_INSTALL_CHECK in
        y* )
            INSTALL_PHP_V8=1

            # Get mods-available directory
            # Select PHP Version

            # Get php.ini files
            if [[ ! -d $PHP_LOCATION ]]; then
                while true; do
                    read -erp $'Where is the PHP configuration directory? (Default: /etc/php)\n' PHP_LOCATION
                    if [[ -d $PHP_LOCATION ]]; then
                        break;
                    else
                        printf 'Please enter a valid directory path.\n'
                        continue;
                    fi
                done
            fi

            break;
        ;;
        n* )
            break;
        ;;
        * )
            continue;
        ;;
    esac
done

shopt -u nocasematch

if (( INSTALL_V8 != 0 )); then
    BOLD
    if [[ -n $SPECIFIC_V8_VERSION  ]]; then
        printf "Installing V8 Version: %s\n..." "$SPECIFIC_V8_VERSION"
    else
        echo "Installing latest V8..."
    fi
    #shellcheck source=src/install_v8.sh
    #shellcheck disable=SC1091
    source $V8_INSTALL_SCRIPT
    NORMAL
fi

if (( INSTALL_PHP_V8 != 0 )); then
    BOLD
    printf "Installing PHP V8Js extension...\n"
    #shellcheck source=src/install_php_v8.sh
    #shellcheck disable=SC1091
    #source $PHP_V8_INSTALL_SCRIPT
    NORMAL
fi

BOLD
printf "Install Successful\n"
NORMAL

exit 0
