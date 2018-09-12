#!/bin/bash

RELEASE=ubuntu-daily:cosmic

#####################################################################


set -e
SCRIPT_HOME=$(readlink -f "$(dirname "${BASH_SOURCE[0]}")")
set -u

NAME=$1
shift

source $SCRIPT_HOME/lxclaunch-common.sh $NAME $RELEASE $@
