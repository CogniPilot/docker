#!/bin/bash

# setup .profile, note bashrc doesn't get sourced by docker by defualt, .profile does
cat << EOF >> ~/.profile
source /usr/share/virtualenvwrapper/virtualenvwrapper.sh
EOF

