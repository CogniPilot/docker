#!/bin/bash
set -e

if [ "$RUN_VNC" = true ] ; then
  /opt/TurboVNC/bin/vncserver -geometry 1920x1080 -name dream -xstartup /bin/openbox-session :20
fi

if [ "$RUN_ZETH" = true ] ; then
  cd /opt/zeth &&  sudo ./net-setup.sh start
fi

exec $@
