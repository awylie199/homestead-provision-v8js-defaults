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

V8JS_DIR="php-v8js"
PHPV8_REPO="https://github.com/phpv8/v8js.git"
PHP_INIS=$(find "$PHP_LOCATION" -type f -name 'php.ini')

cd /tmp || ( echo "Can't change to /tmp directory." && exit 126 )

git clone "$PHPV8_REPO" "$V8JS_DIR"

BOLD
( (( $? == 0 )) && [[ -d $V8JS_DIR ]] ) || ( echo "Failed cloning v8js repository." && exit 1 )
NORMAL

BOLD
cd v8js || ( echo "Can't change to cloned v8js directory." && exit 127 )
NORMAL

# Compiles Shared Extension and Adds .so to Extensions Directory
# https://secure.php.net/manual/en/install.pecl.phpize.php
phpize
./configure
make
make test
sudo make install

BOLD
if [[ -z $PHP_INIS ]]; then
    printf "Couldn't find your php.ini file in your PHP config directory\n"
fi
NORMAL

$PHP_INIS | while IFS= read -r -d $'\0' INI; do
    printf "Adding PHP V8JS extension to: %s" "$INI"
    $V8_EXTENSION >> "$INI"
done

exit $?
