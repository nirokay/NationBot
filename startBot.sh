#!/usr/bin/env bash

cd $(dirname $0)

while ! git pull; do
    echo -e "Failed to pull changes... retrying."
    sleep 10
done

[ ! -f ./NationBot ] && {
    echo -e "Could not compile, no executable found."
    exit 1
}

./NationBot &
