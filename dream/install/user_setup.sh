#!/bin/bash
VNCPASSWD=$1
ZSDK_VERSION="0.15.2"

sudo -E /opt/toolchains/zephyr-sdk-${ZSDK_VERSION}/setup.sh -c
sudo chown -R user:user /home/user/.cmake

# create symlink to west in $HOME/bin
mkdir -p ~/bin
cd ~/bin
ln -s /opt/.venv-zephyr/bin/west .
ln -s /workdir/cerebri_workspace/cerebri/build/zephyr/zephyr.elf cerebri

# setup vnc
mkdir ~/.vnc && echo "$VNCPASSWD" | /opt/TurboVNC/bin/vncpasswd -f > ~/.vnc/passwd && \
  chmod 600 ~/.vnc/passwd && \
  openssl req -x509 -nodes -newkey rsa:3702 -keyout ~/.vnc/x509_private.pem -out ~/.vnc/x509_cert.pem -days 3650 -subj '/CN=www.mydom.com/O=My Company Name LTD./C=US'

cat << EOF >> ~/.bashrc
source /opt/ros/humble/setup.bash
export RMW_IMPLEMENTATION=rmw_cyclonedds_cpp
export GZ_SIM_RESOURCE_PATH=/workdir/ws/src/dream/models:/workdir/ws/src/dream/worlds
if [ -f /workdir/ws/install/setup.sh ]; then
  source /workdir/ws/install/setup.sh
  echo "dream built, sourcing"
fi
if [ -f /workdir/gazebo/install/setup.sh ]; then
  source /workdir/gazebo/install/setup.sh
  echo "gazebo built, sourcing"
fi
EOF
