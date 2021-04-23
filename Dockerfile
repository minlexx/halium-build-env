FROM ubuntu:20.04

# we need i386 libs...
RUN dpkg --add-architecture i386
# initial repository update
RUN apt update && apt -y upgrade

# useful utils
RUN DEBIAN_FRONTEND=noninteractive apt install -y usbutils net-tools nano sudo neofetch curl
# Android tools
RUN DEBIAN_FRONTEND=noninteractive apt install -y adb fastboot heimdall-flash android-sdk-libsparse-utils
# some development tools
RUN DEBIAN_FRONTEND=noninteractive apt install -y build-essential git cmake

# direct LineageOS dependencies as listed in build wiki page
RUN DEBIAN_FRONTEND=noninteractive apt -y install \
	bc bison build-essential ccache curl flex \
	g++-multilib gcc-multilib git gnupg gperf imagemagick \
	lib32ncurses5-dev lib32readline-dev lib32z1-dev liblz4-tool \
	libncurses5 libncurses5-dev libsdl1.2-dev libssl-dev libxml2 \
	libxml2-utils lzop pngcrush rsync schedtool squashfs-tools \
	xsltproc zip zlib1g-dev

# needed to build images...
RUN apt install -y cpio e2fsprogs
# QEMU user emulation
RUN apt install -y qemu binfmt-support qemu-user-static
# required for make menuconfig in kernel
# (cd $OUT/obj/KERNEL_OBJ && ARCH=arm CROSS_COMPILE=arm-linux-androidkernel- V=1 make menuconfig)
#RUN apt install -y libncursesw5-dev
# ncurses dev package is already instaled as part of LOS deps above?

# Different versions of LineageOS require different JDK (Java Development Kit) versions.
# LineageOS 18.1: OpenJDK 11 (included in source download)
# LineageOS 16.0-17.1: OpenJDK 1.9 (included in source download)
# LineageOS 14.1-15.1: OpenJDK 1.8 (install openjdk-8-jdk)
#RUN DEBIAN_FRONTEND=noninteractive apt install -y openjdk-8-jdk

# setup local user (change GID and UID to match yours in the host system)
RUN groupadd --gid 1000 los_devs
RUN useradd --uid 10105 -s /bin/bash -d /home/los_dev -g 1000 los_dev
RUN echo "los_dev ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
RUN mkdir /home/los_dev
RUN mkdir /home/los_dev/bin
RUN chown -R los_dev:los_devs /home/los_dev
# to access USB devices you need to be in plugdev group or usb
RUN gpasswd -a los_dev plugdev
RUN groupadd --gid 85 usb
RUN gpasswd -a los_dev usb

COPY --chown=los_dev:los_devs .bashrc /home/los_dev/

# Download fresh version of repo (this is only done once during creation of the container)
RUN curl https://storage.googleapis.com/git-repo-downloads/repo > /home/los_dev/bin/repo
RUN chmod a+x /home/los_dev/bin/repo
# And then repo should be able to suggest to auto-update itself, make it writable by user
RUN chown los_dev:los_devs /home/los_dev/bin/repo

# To allow repo to run, replace '#!/usr/bin/env python' => '#!/usr/bin/env python3'
RUN sed -i 's_#!/usr/bin/env python_#!/usr/bin/env python3_' /home/los_dev/bin/repo

# Apparently the line above does not help, some other build scripts require
#  /usr/bin/python, which is not present! Let /usr/bin/python point to python3,
#  this seems to work in my tests
RUN ln -s /usr/bin/python3 /usr/bin/python

USER los_dev

# setup git user name & email (change this!)
RUN git config --global user.name "Alexey Min"
RUN git config --global user.email "alexey.min@gmail.com"

WORKDIR /home/los_dev
 
CMD [ "/bin/bash" ]
