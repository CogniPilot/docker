#!/bin/bash
set -e

source ~/.profile

if [ "$RUN_VNC" = true ] ; then
  /opt/TurboVNC/bin/vncserver -geometry 1920x1080 -name dream -xstartup /bin/openbox-session :20
fi

exec "$@"
