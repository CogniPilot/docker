#!/bin/bash
set -e
set -x

sudo dpkg --unpack /opt/JLink_Linux_V788c_x86_64.deb
sudo rm /var/lib/dpkg/info/jlink.postinst -f
sudo dpkg --configure jlink
sudo apt install -yf
