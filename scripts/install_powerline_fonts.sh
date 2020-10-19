#!/bin/bash
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

git clone https://github.com/powerline/fonts powerline_fonts
pushd powerline_fonts
./install.sh
popd
rm -rf powerline_fonts
