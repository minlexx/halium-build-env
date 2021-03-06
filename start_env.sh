#!/bin/bash

# Usage:
# ./start_env.sh
# All USB devices are shared with container

# Path to halium source root directory on host side
HALIUM_HOST_HOME=/home/halium

docker run \
    --privileged \
    -it \
    --rm \
    -v /dev/bus/usb:/dev/bus/usb \
    -v $HALIUM_HOST_HOME:/home/halium/buildroot \
    halium_build_env:latest
