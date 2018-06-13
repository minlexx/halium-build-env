#!/bin/bash

# DEVICE=
# ... --device=$DEVICE

docker run \
    -it \
    --rm \
    -v /home/halium:/home/halium \
    halium_build_env:latest
