# Runtime stage
FROM thies88/base-ubuntu

ARG BUILD_DATE
ARG VERSION
LABEL build_version="version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="Thies88"

RUN \
 echo "enable src repos" && \
 sed -i "/^#.*deb.*main restricted$/s/^# //g" /etc/apt/sources.list && \
 sed -i "/^#.*deb.*universe$/s/^# //g" /etc/apt/sources.list && \
 #sed -i "/^#.*deb.*multiverse$/s/^# //g" /etc/apt/sources.list && \
 # fix issue when installing certen deps
 mkdir /usr/share/man/man1/ && \
 echo "**** install apt-utils and locales ****" && \
 apt-get update && \
 apt-get install -y --no-install-recommends \
	### For building
	git \
	cmake \
	### For running
    openbox \
	python-numpy \
	#xterm \
	#openssh-client \
	net-tools \
	xvfb && \
	#handbrake && \

# install noVNC
cd /usr/share && \
git clone https://github.com/novnc/noVNC && \
rm -rf /usr/share/noVNC/.git* .esl* && \

# build and install libvncserver
apt-get build-dep -y libvncserver && \
cd / && \
git clone https://github.com/LibVNC/libvncserver && \
cd /libvncserver && \
cmake . && \
make install && \
#cmake --build .

# build and install x11vnc
#fix weird deps issue
#mkdir /usr/share/man/man1/
apt-get build-dep -y x11vnc && \
cd / && \
git clone https://github.com/LibVNC/x11vnc && \
cd /x11vnc && \
autoreconf -v --install  && \
./configure  && \
make install  && \

 echo "**** cleanup ****" && \
 apt-get autoremove -y --purge binutils-x86-64-linux-gnu libgcc-7-dev git cmake autoconf automake build-essential dpkg-dev default-jdk-headless default-jre java-common openjdk-11-jre-headless openjdk-11-jdk openjdk-11-jdk-headless xtrans-dev x11proto-core-dev x11proto-damage-dev x11proto-dev gcc-7 cpp-7  && \
 apt-get clean && \
 rm -rf \
	/tmp/* \
	/var/lib/apt/lists/* \
	/var/cache/apt/* \
	/var/tmp/* \
	/var/log/* \
	/usr/share/doc/* \
	/usr/share/info/* \
	/var/cache/debconf/* \
	/usr/share/zoneinfo/* \
	/usr/share/man/* \
	/usr/share/locale/* \
	#
	/libvncserver \
	/x11vnc

# add local files
COPY root/ /

ENTRYPOINT ["/bin/bash", "/init"]
