#!/usr/bin/env bash

# YOUTRACK_HOME is defined in the dockerfile
SETUP_FILE=$YOUTRACK_HOME/initial-setup-done
EXECUTABLE=$YOUTRACK_HOME/bin/youtrack.sh

# Check if there are any java options, and there are no setup file
if [ -n "$JETBRAINS_YOUTRACK_JVM_OPTIONS" ] && [ ! -f $SETUP_FILE ]; then
    echo Setting JVM Options ...

    i=0
    for opt in ${JETBRAINS_YOUTRACK_JVM_OPTIONS[@]}; do
        clOptions[$i]=-J$opt
        i=$(($i+1))
    done

    $EXECUTABLE configure ${clOptions[@]}
    touch $SETUP_FILE
fi

exec $EXECUTABLE run --no-browser