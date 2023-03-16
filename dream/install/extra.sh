#!/bin/bash
set -e
set -x

sudo apt-get -y update
sudo apt-get -y upgrade
sudo DEBIAN_FRONTEND=noninteractive  apt-get install --no-install-recommends -y \
	gdb \
	htop \
	ipe \
	iproute2 \
	lcov \
	menu \
	mesa-utils \
	ros-humble-navigation2 \
	ros-humble-nav2-bringup \
	openbox \
	python3-jinja2 \
	python3-numpy \
	python3-vcstool \
	python3-xdg \
	python3-xmltodict \
	python3-pykwalify \
	python3-pyelftools \
	qt5dxcb-plugin \
	ros-humble-rqt-tf-tree \
	screen \
	terminator \
	vim

sudo pip install west
