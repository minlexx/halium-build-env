FROM ubuntu:16.04

# we need i386 libs...
RUN dpkg --add-architecture i386
# initial repository update
RUN apt update && apt -y upgrade

# useful utils
RUN apt install -y usbutils net-tools android-tools-adb android-tools-fsutils

# deps for building heimdall from source
RUN apt install -y git build-essential
RUN apt install -y zlib1g-dev libssl-dev

# direct halium deps
RUN apt -y install git gnupg flex bison gperf \
  zip bzr curl libc6-dev libncurses5-dev:i386 x11proto-core-dev \
  libx11-dev:i386 libreadline6-dev:i386 libgl1-mesa-glx:i386 \
  libgl1-mesa-dev g++-multilib mingw-w64-i686-dev tofrodos \
  python-markdown libxml2-utils xsltproc zlib1g-dev:i386 schedtool \
  repo liblz4-tool bc lzop

RUN mkdir -p /home/halium
WORKDIR /home/halium
 
CMD [ "/bin/bash" ]
