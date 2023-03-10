#!/bin/bash
VNCPASSWD=$1
ZSDK_VERSION="0.15.2"

sudo -E /opt/toolchains/zephyr-sdk-${ZSDK_VERSION}/setup.sh -c
sudo chown -R user:user /home/user/.cmake

# create symlink to west in $HOME/bin
mkdir -p ~/bin
cd ~/bin
ln -s /opt/.venv-zephyr/bin/west .

# setup vnc
mkdir ~/.vnc && echo "$VNCPASSWD" | /opt/TurboVNC/bin/vncpasswd -f > ~/.vnc/passwd && \
  chmod 600 ~/.vnc/passwd && \
  openssl req -x509 -nodes -newkey rsa:3702 -keyout ~/.vnc/x509_private.pem -out ~/.vnc/x509_cert.pem -days 3650 -subj '/CN=www.mydom.com/O=My Company Name LTD./C=US'

# setup .profile, note bashrc doesn't get sourced by docker by defualt, .profile does
cat << EOF >> ~/.profile
source /opt/ros/humble/setup.bash
export RMW_IMPLEMENTATION=rmw_cyclonedds_cpp
export GZ_SIM_RESOURCE_PATH=/workdir/dream/models:/workdir/dream/worlds
if [ -f /workdir/gazebo/install/setup.sh ]; then
  source /workdir/gazebo/install/setup.sh
  echo "gazebo built, sourcing"
fi
if [ -f /workdir/cranium/install/setup.sh ]; then
  source /workdir/cranium/install/setup.sh
  echo "cranium built, sourcing"
fi
if [ -f /workdir/electrode/install/setup.sh ]; then
  source /workdir/electrode/install/setup.sh
  echo "electrode built, sourcing"
fi
EOF
