#!/bin/bash

# Usage:
# ./02_start_container.sh [-i]
# All USB devices are shared with container

# Path to source root directory on host side
HOST_HOME=/home/lexx/android

docker container run \
    --interactive \
    --tty \
    --privileged \
    --rm \
    --hostname los_build_env \
    --name los_build_env \
    -v /dev/bus/usb:/dev/bus/usb \
    -v ${HOST_HOME}:/home/los_dev/android \
    los_build_env:latest
