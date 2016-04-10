#!/bin/bash
# Compiles and Installs PHP V8Js extension
# https://github.com/phpv8/v8js/blob/master/README.Linux.md

# set -x

V8_EXTENSION=<<- _EXTENSION_
[v8js]
; PHP V8 JS Extension
; https://github.com/phpv8/v8js/blob/master/README.Linux.md
extension=v8js.so
_EXTENSION_

V8JS_INI="v8js.ini"
V8JS_DIR="php-v8js"
PHPV8_REPO="https://github.com/phpv8/v8js.git"
PHP_EXTENSIONS_DIR=$(find "$PHP_LOCATION" -type d -name "conf.d")

cd /tmp || echo "${BOLD}Can't change to /tmp directory.${NORMAL}" && exit 1

git clone "$PHPV8_REPO" "$V8JS_DIR"

(( $? == 0 )) && [[ -d $V8JS_DIR ]] || echo "${BOLD}Failed cloning v8js repository.${NORMAL}" && exit 2

cd v8js || echo "${BOLD}Can't change to cloned v8js directory.${NORMAL}" && exit 3

# Compiles Shared Extension and Adds .so to Extensions Directory
# https://secure.php.net/manual/en/install.pecl.phpize.php
phpize
./configure
make
make test
sudo make install

cd "$APACHE_MODS_DIR" || printf "Failed trying to change to mods dir %s" "$APACHE_MODS_DIR" && exit 4

$PHP_EXTENSIONS_DIR | while IFS= read -r -d $'\0' EXTENSION_DIR; do
    cd "$EXTENSION_DIR" || printf "Failed trying to change to %s\n" "$EXTENSION_DIR" && exit 5
    touch $V8JS_INI
    chmod 770 $V8JS_INI
    $V8_EXTENSION >> v8js.ini
    ln -s v8js.ini "$EXTENSION_DIR"
done

exit $?
