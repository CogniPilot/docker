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

cat << EOF >> ~/.bashrc
source /opt/ros/humble/setup.bash
if [ -f ~/work/ws/zephyr/scripts/west_commands/completion/west-completion.bash ]; then
  echo "sourcing west completion"
  source ~/work/ws/zephyr/scripts/west_commands/completion/west-completion.bash
fi
if [ -f ~/work/gazebo/install/setup.sh ]; then
  source ~/work/gazebo/install/setup.sh
  echo "gazebo built, sourcing"
fi
if [ -f ~/work/cranium/install/setup.sh ]; then
  source ~/work/cranium/install/setup.sh
  echo "dream built, sourcing"
fi
if [ -f ~/work/ws/cerebri/install/setup.sh ]; then
  source ~/work/ws/cerebri/install/setup.sh
  echo "cerebri built, sourcing"
fi
if [ -d "~/bin" ] ; then
  PATH="~/bin/:\$PATH"
fi
if [ -d "/opt/poetry/bin" ] ; then
  PATH="/opt/poetry/bin/:\$PATH"
fi
source /usr/share/colcon_cd/function/colcon_cd.sh
source /usr/share/colcon_argcomplete/hook/colcon-argcomplete.bash
EOF

cat << EOF >> ~/.profile
export GEN_CERT=yes
export POETRY_CACHE_DIR=~/work/.cache/pypoetry
export XDG_RUNTIME_DIR=/tmp/runtime-user
export NO_AT_BRIDGE=1
export ROS_DOMAIN_ID=7
export CMAKE_EXPORT_COMPILE_COMMANDS=ON
export CCACHE_TEMPDIR=/tmp/ccache
export RMW_IMPLEMENTATION=rmw_cyclonedds_cpp
export PYTHONWARNINGS=ignore:::setuptools.installer,ignore:::setuptools.command.install,ignore:::setuptools.command.easy_install
eval \`keychain --eval --agents "gpg,ssh" \$GPG_KEYS \$SSH_KEYS\`
EOF

cat << EOF >> ~/.gdbinit
define hook-stop
  refresh
end
EOF

