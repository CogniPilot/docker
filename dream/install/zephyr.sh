#!/bin/bash
set -e
set -x

WGET_ARGS="-q --show-progress --progress=bar:force:noscroll --no-check-certificate"
ZSDK_VERSION="0.15.2"

# install required packages
# https://docs.zephyrproject.org/latest/develop/getting_started/index.html
sudo apt-get -y update
sudo apt-get -y upgrade
sudo DEBIAN_FRONTEND=noninteractive  apt-get install --no-install-recommends -y \
	git cmake ninja-build gperf \
 	ccache dfu-util device-tree-compiler wget \
	python3-pip \
	python3-pyelftools \
	python3-setuptools \
	python3-tk \
	python3-wheel \
 	python3-dev \
	xz-utils \
	file \
	make gcc libmagic1 \
	libasan6 net-tools valgrind

# get sdk
sudo mkdir -p /opt/toolchains
cd /opt/toolchains
sudo wget ${WGET_ARGS} https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v${ZSDK_VERSION}/zephyr-sdk-${ZSDK_VERSION}_linux-${HOSTTYPE}_minimal.tar.gz
sudo tar xf zephyr-sdk-${ZSDK_VERSION}_linux-${HOSTTYPE}_minimal.tar.gz
sudo zephyr-sdk-${ZSDK_VERSION}/setup.sh -h -c
sudo rm zephyr-sdk-${ZSDK_VERSION}_linux-${HOSTTYPE}_minimal.tar.gz

# setup west
CURRENT_USER=`whoami`
sudo mkdir /opt/.venv-zephyr
sudo chown $CURRENT_USER:$CURRENT_USER /opt/.venv-zephyr
python3 -m venv --prompt zephyr /opt/.venv-zephyr
source /opt/.venv-zephyr/bin/activate
pip install wheel
pip install west
pip install catkin-tools
pip install -r https://raw.githubusercontent.com/zephyrproject-rtos/zephyr/master/scripts/requirements.txt
pip3 check


