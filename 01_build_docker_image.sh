#!/bin/bash

USER_ID=$( id -u )
USER_GID=$( id -g )
USB_GID=$( grep usb /etc/group | cut -d ':' -f 3 )

echo "Building image for UID=${USER_ID}, GID=${USER_GID}, USB_GID=${USB_GID}"

docker build \
	--build-arg user_uid=${USER_ID} \
	--build-arg user_gid=${USER_GID} \
	--build-arg usb_gid=${USB_GID} \
	--build-arg git_user_name="Alexey Min" \
	--build-arg git_user_email="alexey.min@gmail.com" \
	-t los_build_env \
	.
