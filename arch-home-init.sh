#!/bin/bash
# arch-home-init.sh
# author: peterm
# created: 2023-05-27
#############################################################
# update all packages
sudo pacman -Syu

cd /home/peterm/ || exit
mkdir /home/peterm/Downloads/
mkdir /home/peterm/gitrepos/
mkdir /home/peterm/Desktop/

# install locales
sudo -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen
sudo -i 's/#en_GB.UTF-8 UTF-8/en_GB.UTF-8 UTF-8/g' /etc/locale.gen
sudo locale-gen

sudo pacman -S  neofetch \
                neovim \
                qbittorrent \
                ttf-liberation \
                htop \
                git \
                zsh \
                figlet \
                firefox \
                steam \
                dmenu \
                alacritty \
                thunderbird \
                vlc \
                openttd openttd-opengfx openttd-opensfx openttd-openmsx \

cd /home/peterm/gitrepos/ || exit
git clone https://github.com/PeterMaltby/.dotfiles.git
cd .dotfiles || exit
.bootstrap.sh

# ZSH
chsh -s /bin/zsh

# yay install
cd /home/peterm/Downloads/ || exit
git clone https://aur.archlinux.org/yay.git
cd yay || exit
makepkg -si
yay -Y --gendb
yay -Syu --devel

yay -S  flavours \
        librewolf \
        aur/rslsync \

# dwm install
cd /home/peterm/gitrepos/ || exit
git https://github.com/PeterMaltby/petes-dwm.git
cd petes-dwm/ || exit
sudo make clean install

# TODO resilio
