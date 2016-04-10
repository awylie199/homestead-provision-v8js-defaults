#!/bin/bash
# Provisions Laravel Homestead Environment for V8 2.0 Engine and V8PHPJs extensions
# https://github.com/phpv8/v8js/blob/master/README.Linux.md

# set -x

# Tput Formatting MAN TERMINFO
BOLD=$(tput bold)
NORMAL=$(tput sgr0)

INSTALL_V8=0
INSTALL_PHP_V8=0
SPECIFIC_V8_VERSION

PHP_LOCATION=$(find /etc -maxdepth 1 -type d -name "php")
APACHE_MODS=$(find "$PHP_LOCATION" -type d -name "mods-available")

handleSig() {
    shopt -s nocasematch
    $BOLD

    while true; do
        read -erp $'Do you want to cancel script execution? (y/n)\n' EXIT_CHECK
        case $EXIT_CHECK in
            "y*" )
                printf 'Ok, exiting.\n'
                exit $?
            ;;
            "n*" )
                printf 'Ok, continuing.\n'
                break
            ;;
            "*" )
                printf 'Please enter "y" or "n".\n'
            ;;
        esac
    done

    $NORMAL
    shopt -u nocasematch
}

handleExit() {
    log "Exiting: $?"
    $NORMAL
    exit $?
}

log() {
    $BOLD
    if [[ -n "$1" ]]; then
        printf "%s\n" "$1"
    else
        printf "Exiting\n"
    fi
    $NORMAL
}

trap "handleExit" EXIT
trap "handleSig" SIGINT SIGTERM SIGHUP

# Basic Preliminary Checks
$BOLD
[[ -x "src/install_v8.sh" ]] || printf "Can't execute V8 install script (src/install_v8.sh)\n" && exit 1
[[ -x "src/install_php_v8.sh" ]] || printf "Can't execute PHPV8Js install script (src/install_php_v8.sh)\n" && exit 2

[[ -x $(which php) ]] || printf 'Cant find PHP on path.\n' && exit 3
[[ -x $(which git) ]] || printf 'Cant find git on path.\n' && exit 4
[[ -x $(which make) ]] || printf 'Cant find make on path.\n' && exit 5
$NORMAL

cat <<- _INTRO_
    This script compiles and installs the V8js 2.0 engine and PHP V8js extension, intended for provisioning  the Homestead Vagrant environment.

    V8 is installed to the /usr directory. ${BOLD}This may overwrite the system copy of V8.${NORMAL}

    https://github.com/talyssonoc/react-laravel/blob/master/install_v8js.md
_INTRO_

shopt -s nocasematch

while true; do
    read -erp $'Compile and install V8 2.0 engine? (y/n)\n' V8_INSTALL_CHECK
    case $V8_INSTALL_CHECK in
        "y*" )
            INSTALL_V8=1

            # Check to see whether a specific version is needed
            while true; do
                read -er -t 20 -p $'Do you want to build a specific version? (y/n)\n' VERSION_RESPONSE
                [[ -z $VERSION_RESPONSE ]] && VERSION_RESPONSE='n'
                case $VERSION_RESPONSE in
                    "y*" )
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
                    "n*" )
                        break
                    ;;
                    "*" )
                        printf 'Please enter "y" or "n"\n'
                        continue
                esac
            done

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
    read -erp $'Compile and install PHPV8 JS extension? (y/n)\n' PHP_INSTALL_CHECK
    case $PHP_INSTALL_CHECK in
        "y*" )
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

            if [[ ! -d $APACHE_MODS ]]; then
                while true; do
                    read -erp $'Where is the Apache Mods directory? (Default: /etc/php/<php-version>/mods-available)\n' APACHE_MODS
                    if [[ -d APACHE_MODS ]]; then
                        break;
                    else
                        continue;
                    fi
                done
            fi
            # Check if more than one mods directory (i.e. PHP 5.6 and PHP 7.0)
            if (( $($APACHE_MODS | wc -l) > 1 )); then
                select MOD in $APACHE_MODS; do
                    printf "Using %s\n" "$MOD"
                done
            fi

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

if (( INSTALL_V8 != 0 )); then
    ${BOLD}
    echo "Installing V8 2.0: "
    if [[ -n $SPECIFIC_V8_VERSION  ]]; then
        printf "%s\n" "$SPECIFIC_V8_VERSION"
    else
        echo "Latest"
    fi
    ${NORMAL}
    . src/install_v8.sh
fi

if (( INSTALL_PHP_V8 != 0 )); then
    ${BOLD}
    printf "Installing PHP V8Js extension...\n"
    . src/install_php_v8.sh
    ${NORMAL}
fi

${BOLD}
printf "Install Successful\n"
${NORMAL}

exit 0
