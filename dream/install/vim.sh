#!/bin/bash
cp /opt/vim/vimrc ~/.vimrc
sudo chown $CURRENT_USER:$CURRENT_USER ~/.vimrc
git clone --recurse-submodules https://github.com/ycm-core/YouCompleteMe.git ~/.vim/pack/YouCompleteMe/opt/YouCompleteMe
git clone https://github.com/preservim/nerdcommenter.git ~/.vim/pack/NERDCommenter/opt/NERDCommenter
git clone https://github.com/ciaranm/securemodelines ~/.vim/pack/securemodelines/opt/securemodelines
pushd ~/.vim/pack/YouCompleteMe/opt/YouCompleteMe
./install.py --clangd-completer
popd
