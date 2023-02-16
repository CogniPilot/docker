#!/bin/bash
set -e
set -x

VNCPASSWD="$1"
ZSDK_VERSION="0.15.2"

sudo -E /opt/toolchains/zephyr-sdk-${ZSDK_VERSION}/setup.sh -c
sudo chown -R user:user /home/user/.cmake

sudo rosdep init

# create symlink to west in $HOME/bin
mkdir -p ~/bin
cd ~/bin
ln -s /opt/.venv-zephyr/bin/west .

# setup vnc
mkdir ~/.vnc && echo "$VNCPASSWD" | /opt/TurboVNC/bin/vncpasswd -f > ~/.vnc/passwd && \
  chmod 600 ~/.vnc/passwd && \
  openssl req -x509 -nodes -newkey rsa:3702 -keyout ~/.vnc/x509_private.pem -out ~/.vnc/x509_cert.pem -days 3650 -subj '/CN=www.mydom.com/O=My Company Name LTD./C=US'

cat << EOF >> ~/.bashrc
source /opt/ros/humble/setup.bash
export ZEPHYR_BASE=~/work/zephyr_workspace/zephyr
export CCACHE_TEMPDIR=/tmp/ccache
export RMW_IMPLEMENTATION=rmw_cyclonedds_cpp
export PYTHONWARNINGS=ignore:::setuptools.installer,ignore:::setuptools.command.install
export GZ_SIM_RESOURCE_PATH=~/work/ws/src/dream/models:~/work/ws/src/dream/worlds
if [ -f ~/work/ws/install/setup.sh ]; then
  source ~/work/ws/install/setup.sh
  echo "dream built, sourcing"
fi
if [ -f ~/work/gazebo/install/setup.sh ]; then
  source ~/work/gazebo/install/setup.sh
  echo "gazebo built, sourcing"
fi
source /usr/share/colcon_cd/function/colcon_cd.sh
source /usr/share/colcon_argcomplete/hook/colcon-argcomplete.bash
EOF
