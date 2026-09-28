#!/usr/bin/env bash

if [ ! -f app.jar ]; then
    ./build.sh || exit 1
fi

java -jar app.jar "$@"
exit $?
