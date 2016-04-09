#!/bin/bash
# Compiles and Installs PHP V8Js extension

# set -x

PHPV8_REPO="https://github.com/phpv8/v8js.git"
V8JS_INI="v8js.ini"
PHP_CLI_INI_DIR=$(php --ini | grep "Scan for additional .ini files in:" | cut -d : -f 2)
PHP_FPM_INI_DIR=$()

PHP_CLI_V8_INI=$(php --ini | grep -i 'v8.*\.ini')
PHP_FPM_V8_INI=$()

cd /tmp || echo "${bold}Can't change to /tmp directory.${normal}" && exit 1

git clone "$PHPV8_REPO" "$V8JS_DIR"

[[ ! -d $V8JS_DIR ]] && echo "${bold}Failed cloning v8js repository.${normal}" && exit 2

cd v8js || echo "${bold}Can't change to cloned v8js directory.${normal}" && exit 3

phpize
./configure
make
make test
sudo make install

[[ ! -f $PHP_CLI_V8_INI ]] && PHP_CLI_V8_INI="${PHP_CLI_INI_DIR}/${V8JS_INI}"
[[ ! -f $PHP_FPM_V8_INI ]] && PHP_FPM_V8_INI="${PHP_CLI_INI_DIR}/${V8JS_INI}"

echo "Using PHP CLI V8 ini at: $PHP_CLI_V8_INI"
read -erp $'Is this correct?\n'

'extension=v8js.so' >> "$PHP_CLI_V8_INI"
'extension=v8js.so' >> "$PHP_FPM_V8_INI"

exit 0
