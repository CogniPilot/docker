#!/bin/bash
set -e
set -x

VNCPASSWD="$1"
ZSDK_VERSION="0.16.1"

# vim setup
mkdir -p ~/.vim/pack/plugins/opt
ln -s /opt/vim/YouCompleteMe ~/.vim/pack/plugins/opt/YouCompleteMe
ln -s /opt/vim/NERDCommenter ~/.vim/pack/plugins/opt/NERDCommenter
ln -s /opt/vim/securemodelines ~/.vim/pack/plugins/opt/securemodelines

cat << EOF >> ~/.vimrc
packadd YouCompleteMe
packadd NERDCommenter
packadd securemodelines

filetype plugin indent on

" Vim5 and later versions support syntax highlighting. Uncommenting the next
" line enables syntax highlighting by default.
if has("syntax")
  syntax on
endif

" If using a dark background within the editing area and syntax highlighting
" turn on this option as well
set background=dark

" Uncomment the following to have Vim jump to the last position when
" reopening a file
au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif

" The following are commented out as they cause vim to behave a lot
" differently from regular Vi. They are highly recommended though.
set showcmd		" Show (partial) command in status line.
set showmatch		" Show matching brackets.
set ignorecase		" Do case insensitive matching
set smartcase		" Do smart case matching
set incsearch		" Incremental search
set autowrite		" Automatically save before commands like :next and :make
set hidden		" Hide buffers when they are abandoned
set mouse=a		" Enable mouse usage (all modes)

hi YcmWarningSection ctermbg=52
EOF

# zephyr
sudo -E /opt/toolchains/zephyr-sdk-${ZSDK_VERSION}/setup.sh -c
sudo chown -R user:user /home/user/.cmake

sudo rosdep init

# create symlink to west in ~/bin
mkdir -p ~/bin
cd ~/bin
ln -s /opt/.venv-zephyr/bin/west .

# setup vnc
mkdir ~/.vnc && echo "$VNCPASSWD" | /opt/TurboVNC/bin/vncpasswd -f > ~/.vnc/passwd && \
  chmod 600 ~/.vnc/passwd && \
  openssl req -x509 -nodes -newkey rsa:3702 -keyout ~/.vnc/x509_private.pem -out ~/.vnc/x509_cert.pem -days 3650 -subj '/CN=www.mydom.com/O=My Company Name LTD./C=US'

# no need to modify .bashrc
cat << EOF >> ~/.bashrc
#echo sourcing ros
source /opt/ros/humble/setup.bash
if [ -f \$HOME/work/ws/zephyr/scripts/west_commands/completion/west-completion.bash ]; then
  #echo sourcing west completion
  source \$HOME/work/ws/zephyr/scripts/west_commands/completion/west-completion.bash
fi
if [ -f \$HOME/work/gazebo/install/setup.sh ]; then
  source \$HOME/work/gazebo/install/setup.sh
  #echo gazebo built, sourcing
fi
if [ -f \$HOME/work/cranium/install/setup.sh ]; then
  #echo dream built, sourcing
  source \$HOME/work/cranium/install/setup.sh
fi
if [ -f \$HOME/work/ws/cerebri/install/setup.sh ]; then
  #echo cerebri built, sourcing
  source \$HOME/work/ws/cerebri/install/setup.sh
fi
source /usr/share/colcon_cd/function/colcon_cd.sh
source /usr/share/colcon_argcomplete/hook/colcon-argcomplete.bash
EOF

# modify .profile
cat << EOF >> ~/.profile
if [ -d \$HOME/bin ] ; then
  PATH="\$HOME/bin/:\$PATH"
fi
if [ -d /opt/poetry/bin ] ; then
  PATH="/opt/poetry/bin:\$PATH"
fi
export GEN_CERT=yes
export SHELL=/bin/bash
export POETRY_VIRTUALENVS_PATH=~/work/.poetry
export XDG_RUNTIME_DIR=/tmp/runtime-user
export NO_AT_BRIDGE=1
export ROS_DOMAIN_ID=7
export CMAKE_EXPORT_COMPILE_COMMANDS=ON
export CCACHE_TEMPDIR=/tmp/ccache
export RMW_IMPLEMENTATION=rmw_cyclonedds_cpp
export PYTHONWARNINGS=ignore:::setuptools.installer,ignore:::setuptools.command.install,ignore:::setuptools.command.easy_install
eval \`keychain -q --eval --agents "gpg,ssh"\`
EOF

# add gdb fixes
cat << EOF >> ~/.gdbinit
define hook-stop
  refresh
end
EOF

# add script to unlock ssh/gpg keys
cat << EOF > ~/bin/unlock
#!/bin/bash
set -e
eval \`keychain --eval --agents "gpg,ssh" \$GPG_KEYS \$SSH_KEYS\`
EOF
chmod +x ~/bin/unlock

# add script to build/run cyecca
cat << EOF > ~/bin/cyecca
#!/bin/bash
set -e
set -x
if [ ! -d "\$HOME/work/cyecca" ] ; then
  git clone git@github.com:cognipilot/cyecca ~/work/cyecca
fi
cd ~/work/cyecca
poetry install
poetry run jupyter lab
EOF
chmod +x ~/bin/cyecca

# add script to build mrbuggy3_sitl
cat << EOF > ~/bin/build_mrbuggy3_sitl
#!/bin/bash
set -e
set -x

echo "Setup Helmet for MRBuggy3 SITL"
cd ~/work
if [ ! -d "\$HOME/work/helmet" ] ; then
  git clone git@github.com:CogniPilot/helmet
fi
vcs import < helmet/dream/base.yaml
vcs import < helmet/dream/mrbuggy3.yaml

echo "Build Cranium"
cd ~/work/cranium
colcon build --symlink-install
. ./install/setup.sh

echo "Build Cerebri for MRBuggy3 SITL"
cd ~/work/ws/cerebri
west init -l .
west update
west build app/mrbuggy3/ -b native_posix -t install -p
. ./install/setup.sh
EOF
chmod +x ~/bin/build_mrbuggy3_sitl

# add script to build and serve docs
cat << EOF > ~/bin/docs
#!/bin/bash
set -e
set -x

echo "Build CogniPilot Docs"
cd ~/work
if [ ! -d "\$HOME/work/docs" ] ; then
  git clone https://github.com/CogniPilot/cognipilot_docs ~/work/docs
fi
cd ~/work/docs
poetry install --no-root
poetry run mkdocs serve -a 0.0.0.0:8000
EOF
chmod +x ~/bin/docs
