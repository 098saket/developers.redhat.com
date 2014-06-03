#!/bin/bash

DIR=$(cd -P -- "$(dirname -- "$0")" && pwd -P)

if ! type "pngquant" > /dev/null; then
  brew install pngquant
fi

if ! type "optipng" > /dev/null; then
  brew install optipng
fi

wget http://curl.haxx.se/ca/cacert.pem
export SSL_CERT_FILE=`pwd`/cacert.pem
