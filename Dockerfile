FROM ubuntu:16.04

# we need i386 libs...
RUN dpkg --add-architecture i386
# initial repository update
RUN apt update && apt -y upgrade

# useful utils
RUN apt install -y usbutils net-tools android-tools-adb android-tools-fsutils nano

# deps for building heimdall from source
RUN apt install -y build-essential git cmake
RUN apt install -y zlib1g-dev libssl-dev libusb-1.0.0-dev libgl1-mesa-glx libgl1-mesa-dev
# build heimdall
RUN mkdir -p /projects \
    && cd /projects \
    && git clone https://gitlab.com/BenjaminDobell/Heimdall.git \
    && cd Heimdall \
    && mkdir build \
    && cd build \
    && cmake -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr -DDISABLE_FRONTEND=ON ../ \
    && cmake --build . --target install

# direct halium deps
RUN apt -y install gnupg flex bison gperf \
  zip bzr curl libc6-dev libncurses5-dev:i386 x11proto-core-dev \
  libx11-dev:i386 libreadline6-dev:i386 libgl1-mesa-glx:i386 \
  libgl1-mesa-dev g++-multilib mingw-w64-i686-dev tofrodos \
  python-markdown libxml2-utils xsltproc zlib1g-dev:i386 schedtool \
  repo liblz4-tool bc lzop

# halium docs don't say that, but imagemagick is also needed (for mka mkbootimg)
RUN apt install -y imagemagick
# cpio is needed to build images...
RUN apt install -y cpio
# required by JBB's halium-install-standalone
RUN apt install -y qemu binfmt-support qemu-user-static e2fsprogs sudo

# setup local user (change GID and UID to yours)
RUN groupadd --gid 10001 halium_devs
RUN useradd --uid 10105 -s /bin/bash -d /home/halium -g 10001 halium_dev
RUN echo "halium_dev ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
RUN mkdir /home/halium && chown -R halium_dev:halium_devs /home/halium
# to access USB devices some needs to be in plugdev group or usb
RUN gpasswd -a halium_dev plugdev
RUN groupadd --gid 85 usb
RUN gpasswd -a halium_dev usb

COPY --chown=halium_dev:halium_devs .bashrc /home/halium/
# new version of repo
COPY --chown=root:root repo /usr/bin

USER halium_dev

# setup git user name & email (change this!)
RUN git config --global user.name "Alexey Min"
RUN git config --global user.email "alexey.min@gmail.com"

WORKDIR /home/halium
 
CMD [ "/bin/bash" ]
