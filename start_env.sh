#!/bin/bash

# Usage:
# ./start_env.sh
# All USB devices are shared with container

docker run \
    --privileged \
    -it \
    --rm \
    -v /dev/bus/usb:/dev/bus/usb \
    -v /home/halium:/home/halium/buildroot \
    halium_build_env:latest
