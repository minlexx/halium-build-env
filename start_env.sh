#!/bin/bash

# Usage:
# ./start_env.sh /path/to/phone_device
# ./start_env.sh /dev/bus/usb/001/006
# TODO: autodetect device...

DEVICE=$1

docker run \
    -it \
    --rm \
    --device=$DEVICE \
    -v /home/halium:/home/halium \
    halium_build_env:latest
