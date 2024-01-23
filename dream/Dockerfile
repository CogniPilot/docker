FROM ubuntu:jammy-20240111

LABEL maintainer="James Goppert <james.goppert@gmail.com>"

#####################################################################
# Install Packages
#####################################################################

# environment
ENV PROTOCOL_BUFFERS_PYTHON_IMPLEMENTATION=python
ENV XDG_RUNTIME_DIR=/tmp/runtime-docker
ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=all
ENV GZ_PARTITION=cognipilot
ENV TERM=xterm-256color
ENV DISPLAY=:20
ENV PATH="/home/user/bin:${PATH}"

# Set default shell during Docker image build to bash
SHELL ["/bin/bash", "-l", "-c"]

# Copy docker clean script
COPY helmet/install/docker/docker_clean.sh /docker_clean.sh

# Install base packages
RUN DEBIAN_FRONTEND=noninteractive apt-get -y update && \
	apt-get install --no-install-recommends -y \
		sudo \
		locales \
		&& \
	/docker_clean.sh

# Initialise system locale
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8
RUN locale-gen en_US.UTF-8

# Create a user to make sure install works without root
ARG UID_INSTALLER=2001
RUN useradd -l -u $UID_INSTALLER installer -G sudo,plugdev && \
 echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER installer

# install dependencies using scripts in a manner that will cache build
# when one script is modified
COPY helmet/install/scripts/base.sh /tmp/install/base.sh
RUN /tmp/install/base.sh && /docker_clean.sh

COPY helmet/install/scripts/vim.sh /tmp/install/vim.sh
RUN /tmp/install/vim.sh && /docker_clean.sh

COPY helmet/install/scripts/latex.sh /tmp/install/latex.sh
RUN /tmp/install/latex.sh && /docker_clean.sh

COPY helmet/install/scripts/zephyr.sh /tmp/install/zephyr.sh
RUN /tmp/install/zephyr.sh && /docker_clean.sh

COPY helmet/install/scripts/ros.sh /tmp/install/ros.sh
RUN /tmp/install/ros.sh && /docker_clean.sh

COPY helmet/install/scripts/gazebo.sh /tmp/install/gazebo.sh
RUN /tmp/install/gazebo.sh && /docker_clean.sh

# add groups before we do anything that might add a new group
ARG GID_INPUT=107
ARG GID_RENDER=110
ARG GID_VGLUSERS=1005
RUN sudo groupadd -r -g $GID_INPUT input && \
 sudo groupadd -r -g $GID_RENDER render && \
 sudo groupadd -r -g $GID_VGLUSERS vglusers

# install virtualgl and turbovnc
COPY helmet/install/resources/virtualgl_3.0.91_amd64.deb /tmp
RUN cd /tmp && \
  wget https://sourceforge.net/projects/turbovnc/files/3.0.2/turbovnc_3.0.2_amd64.deb  && \
  sudo apt-get -y update && \
  sudo DEBIAN_FRONTEND=noninteractive  apt-get install --no-install-recommends -y \
    ./virtualgl_3.0.91_amd64.deb \
    ./turbovnc_3.0.2_amd64.deb && \
  /docker_clean.sh

# enable apt auto-completion by deleting autoclean task
RUN sudo rm /etc/apt/apt.conf.d/docker-clean

# create XDG runtime dir
RUN mkdir /tmp/runtime-docker && sudo chmod 700 /tmp/runtime-docker

# install jupyter server config
COPY helmet/install/resources/jupyter_server_config.py /etc/jupyter/

# fixes for terminator
COPY helmet/install/resources/terminator_config /etc/xdg/terminator/config

# setup zeth ethernet device
RUN sudo mkdir -p /opt/zeth
COPY helmet/install/resources/net-setup.sh /opt/zeth
COPY helmet/install/resources/zeth.conf /opt/zeth

# install jlink
COPY helmet/install/resources/JLink_Linux_V788c_x86_64.deb /tmp/
COPY helmet/install/resources/jlink.sh /tmp/jlink.sh
RUN /tmp/jlink.sh && /docker_clean.sh

#####################################################################
# Setup User
#####################################################################

ARG UID_USER=1000
RUN sudo useradd --create-home -l -u $UID_USER -G sudo,plugdev,render,input,vglusers,video,dialout user && \
 echo user: $UID_USER && \
 sudo vglserver_config +egl

USER user

ARG VNCPASSWD=cogni<3

COPY helmet/install/scripts/user_setup.sh /tmp/install/user_setup.sh
RUN /tmp/install/user_setup.sh docker && /docker_clean.sh

COPY helmet/install/scripts/user_vim.sh /tmp/install/user_vim.sh
RUN /tmp/install/user_vim.sh docker && /docker_clean.sh

COPY helmet/install/docker/user_vnc.sh /tmp/install/user_vnc.sh
RUN /tmp/install/user_vnc.sh $VNCPASSWD && /docker_clean.sh

#####################################################################
# Setup Scripts
#####################################################################
COPY helmet/install/resources/build_workspace /home/user/bin
COPY helmet/install/resources/build_foxglove /home/user/bin
COPY helmet/install/resources/cyecca /home/user/bin
COPY helmet/install/resources/docs /home/user/bin
COPY helmet/install/docker/unlock /home/user/bin

#####################################################################
# Setup Volumes
#####################################################################

# create ws, this is where the source code will be mounted
VOLUME /home/user/cognipilot
WORKDIR /home/user/cognipilot
RUN mkdir -p /home/user/cognipilot

# create setting directory for gazebo
VOLUME /home/user/.gz
RUN mkdir -p /home/user/.gz

# create setting directory for jupyter
VOLUME /home/user/.jupyter
RUN mkdir -p /home/user/.jupyter

# create .X11-unix directory
VOLUME /tmp/.X11-unix
RUN mkdir -p /tmp/.X11-unix

# create .gnupg directory
VOLUME /home/user/.gnupg
RUN mkdir -p /home/user/.gnupg

# create .ssh directory
VOLUME /home/user/.ssh
RUN mkdir -p /home/user/.ssh

# create .gitconfig file
VOLUME /home/user/.gitconfig

#####################################################################
# Entry Point
#####################################################################

# setup entry point
COPY helmet/install/docker/entrypoint.sh /
RUN sudo chsh -s /bin/bash user

USER root

CMD ["/bin/bash"]
ENTRYPOINT ["/entrypoint.sh"]

LABEL org.opencontainers.image.source = "https://github.com/CogniPilot/docker"

#####################################################################
# Exposed Ports
#####################################################################

# expose jupyterlab port
EXPOSE 8888

# expose mkdocs port
EXPOSE 8000

# vim: set et fenc=utf-8 ff=unix ft=dockerfile sts=0 sw=2 ts=2 :
