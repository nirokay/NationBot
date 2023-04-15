#!/bin/bash

# Default vars:
RESTART_SECONDS=$(( 60 * 60 * 12 ))

# Runtime vars:
CONFIG_FILE="config.sh"
PID=-1

function compile() {
    git pull
    nimble build
}

function loadConfig() {
    [ -f "$CONFIG_FILE" ] && source "$CONFIG_FILE"
}

function main() {
    # Load up config from file (or use defaults):
    loadConfig

    # Killing process, if started already:
    if [ $PID -gt 0 ]
        then kill $PID && echo "Restarting..."
        else echo "Starting up..."
    fi

    # Start process:
    ./NationBot &
    PID=$!

    echo "Going to sleep for $RESTART_SECONDS seconds!" && sleep $RESTART_SECONDS
}

while true; do
    main
done
