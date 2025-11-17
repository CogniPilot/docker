# CI Image (ci)
#
# This image contains all tools required for CI operation

FROM ubuntu:24.04

ARG USERNAME=user
ARG UID=1000
ARG GID=1000
ARG PYTHON_VENV_PATH=/opt/python/venv
ARG WGET_ARGS="-q --show-progress --progress=bar:force:noscroll"

ARG KITWARE_NINJA_VERSION=1.11.1.g95dee.kitware.jobserver-1
ENV KITWARE_NINJA_VERSION=$KITWARE_NINJA_VERSION

# Set default shell during Docker image build to bash
SHELL ["/bin/bash", "-eo", "pipefail", "-c"]

# Set non-interactive frontend for apt-get to skip any user confirmations
ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# Install APT packages
RUN <<EOF

	# Upgrade system packages
	apt-get -y update
	apt-get install --no-install-recommends -y \
		wget \
		ca-certificates \
		gnupg \
		software-properties-common

	wget -O- https://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add -
	add-apt-repository --no-update --yes "deb http://apt.llvm.org/noble/ llvm-toolchain-noble-18 main"
	apt update
	apt-get install --no-install-recommends -y \
		ccache \
		clang-format \
		clang-format-18 \
		clang-tidy \
		cmake \
		device-tree-compiler \
		dfu-util \
		file \
		gcc-multilib \
		g++-multilib \
		git \
		gperf \
		libmagic1 \
		libsdl2-dev \
		locales \
		ninja-build \
		protobuf-compiler \
		python3-dev \
		python3-poetry \
		python3-protobuf \
		python3-tk \
		python3-venv \
		python-is-python3 \
		thrift-compiler \
		sudo \
		xz-utils

	# Clean up stale packages
	apt-get autoremove --purge -y

	# Clean up local repository
	apt-get clean -y
	rm -rf /var/lib/apt/lists/*
	locale-gen en_US.UTF-8

	# Initialise virtual environment
	mkdir -p ${PYTHON_VENV_PATH}
	python3 -m venv ${PYTHON_VENV_PATH}

	# Activate virtual environment for subsequent steps
	source ${PYTHON_VENV_PATH}/bin/activate

	# Install Zephyr requirements
	pip install --no-cache-dir \
		wheel \
		west \
		typeguard \
		catkin-tools \
		grpcio-tools \
		-r https://raw.githubusercontent.com/zephyrproject-rtos/zephyr/main/scripts/requirements.txt \
		-r https://raw.githubusercontent.com/zephyrproject-rtos/mcuboot/main/scripts/requirements.txt \
		-r https://raw.githubusercontent.com/zephyrproject-rtos/trusted-firmware-m/main/tools/requirements.txt
	pip check
EOF

# Make Zephyr Python virtual environment available globally
ENV PATH=${PYTHON_VENV_PATH}/bin:$PATH

# Create user account
RUN <<EOF
	# Remove 'ubuntu' user to free UID 1000
	userdel -r ubuntu || true

	# Create user group and user account
	groupadd -g $GID -o $USERNAME
	useradd -u $UID -m -g $USERNAME -G plugdev $USERNAME

	# Add user account to sudoers
	echo $USERNAME ' ALL = NOPASSWD: ALL' > /etc/sudoers.d/$USERNAME
	chmod 0440 /etc/sudoers.d/$USERNAME
EOF

ARG ZSDK_VERSION=0.17.4
ENV ZSDK_VERSION=$ZSDK_VERSION

# Install Zephyr SDK
RUN <<EOF
	mkdir -p /opt/toolchains
	cd /opt/toolchains
	wget ${WGET_ARGS} https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v${ZSDK_VERSION}/zephyr-sdk-${ZSDK_VERSION}_linux-x86_64_minimal.tar.xz
	tar xf zephyr-sdk-${ZSDK_VERSION}_linux-x86_64_minimal.tar.xz
	cd /opt/toolchains/zephyr-sdk-${ZSDK_VERSION}
	wget ${WGET_ARGS} https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v${ZSDK_VERSION}/toolchain_linux-x86_64_arm-zephyr-eabi.tar.xz
	tar xf toolchain_linux-x86_64_arm-zephyr-eabi.tar.xz
	rm toolchain_linux-x86_64_arm-zephyr-eabi.tar.xz
	cd /opt/toolchains
	zephyr-sdk-${ZSDK_VERSION}/setup.sh -t all -h -c
	rm zephyr-sdk-${ZSDK_VERSION}_linux-x86_64_minimal.tar.xz
EOF

# Run the Zephyr SDK setup script as 'user' in order to ensure that the
# `Zephyr-sdk` CMake package is located in the package registry under the
# user's home directory.
USER $USERNAME

RUN <<EOF
	sudo -E -- bash -c '
	/opt/toolchains/zephyr-sdk-${ZSDK_VERSION}/setup.sh -c &&
	chown -R $USERNAME:$USERNAME /home/$USERNAME/.cmake
	'
EOF

USER root

# Set build environment variables
ENV ZEPHYR_TOOLCHAIN_VARIANT=zephyr
