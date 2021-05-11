#!/bin/bash
docker build \
	--build-arg user_uid=10105 \
	--build-arg user_gid=1000 \
	--build-arg git_user_name="Alexey Min" \
	--build-arg git_user_email="alexey.min@gmail.com" \
	-t los_build_env \
	.
