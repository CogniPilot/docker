FROM ubuntu:22.04

ENV TERM=xterm-256color

# Set default shell during Docker image build to bash
SHELL ["/bin/bash", "-l", "-c"]

# Copy docker clean script
COPY install/docker_clean.sh /docker_clean.sh
RUN chmod +x /docker_clean.sh

# Install base packages
RUN DEBIAN_FRONTEND=noninteractive apt-get -y update && \
  apt-get -y upgrade && \
  apt-get install --no-install-recommends -y \
    sudo \
    bash-completion \
    locales \
    git \
    texlive-latex-extra \
    texlive-bibtex-extra \
    texlive-fonts-recommended \
    texlive-xetex \
    latexmk \
    python3-pip \
    python3-venv \
    virtualenvwrapper \
    graphviz \
    wget \
    && \
  /docker_clean.sh

# Initialise system locale
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8
RUN locale-gen en_US.UTF-8

# create a user for running the container
ARG UID_USER=1000
RUN sudo useradd --create-home -l -u $UID_USER -G sudo,plugdev user && \
  echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER user

RUN wget https://raw.githubusercontent.com/CogniPilot/pyecca/main/requirements.txt -O /tmp/requirements.txt && \
  source /usr/share/virtualenvwrapper/virtualenvwrapper.sh  && \
  mkvirtualenv -r /tmp/requirements.txt pyecca

# setup entry point
COPY install/user_setup.sh /tmp
RUN sudo chmod +x /tmp/user_setup.sh && \
  /tmp/user_setup.sh

# enable apt auto-completion by deleting autoclean task
RUN sudo rm /etc/apt/apt.conf.d/docker-clean

# create workdir, this is where the source code will be mounted
VOLUME /workdir
WORKDIR /workdir
RUN sudo mkdir -p /workdir && sudo chown -R user:user /workdir

# setup entry point
COPY install/entrypoint.sh /
RUN sudo chmod +x /entrypoint.sh

CMD ["/bin/bash" , "-l"]
