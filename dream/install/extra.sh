#!/bin/bash
set -e
set -x

sudo apt-get -y update
sudo apt-get -y upgrade
sudo DEBIAN_FRONTEND=noninteractive  apt-get install --no-install-recommends -y \
	appmenu-gtk2-module \
	appmenu-gtk3-module \
	clang-format \
	clang-tidy \
	ddd \
	gcc-multilib \
	gdb \
	gnupg2 \
	htop \
	ipe \
	iproute2 \
	keychain \
	libcanberra-gtk3-module \
	lcov \
	meld \
	menu \
	mesa-utils \
	nodejs \
	openbox \
	python3-jinja2 \
	python3-numpy \
	python3-xdg \
	python3-xmltodict \
	qt5dxcb-plugin \
	screen \
	terminator \
	vim \
	xterm

sudo pip install protobuf

# remove plugins that don't work on docker for terminator
sudo rm -rf /usr/lib/python3/dist-packages/terminatorlib/plugins/activitywatch.py
sudo rm -rf /usr/lib/python3/dist-packages/terminatorlib/plugins/command_notify.py

