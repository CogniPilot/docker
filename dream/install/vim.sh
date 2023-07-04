#!/bin/bash
set -e 
set -x
sudo mkdir -p /opt/vim/
echo $whoami
sudo chown -R $UID:$UID /opt/vim
git clone --recurse-submodules https://github.com/ycm-core/YouCompleteMe.git /opt/vim/YouCompleteMe
git clone https://github.com/preservim/nerdcommenter.git /opt/vim/NERDCommenter
git clone https://github.com/ciaranm/securemodelines /opt/vim/securemodelines
pushd /opt/vim/YouCompleteMe
./install.py --clangd-completer
popd
