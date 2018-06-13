#!/bin/bash
docker run \
    -it \
    --rm \
    --device=/dev/bus/usb/001/005 \
    -v /home/halium:/home/halium \
    halium_build_env:latest
