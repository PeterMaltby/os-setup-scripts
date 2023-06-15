#!/bin/bash
# arch-home-init.sh
# author: peterm
# created: 2023-05-27
#############################################################
dotfilesRepo="https://github.com/PeterMaltby/.dotfiles.git"

gitDir="${HOME}/gitrepos"
dotfilesDir="${gitDir}/.dotfiles"

#############################################################
# bootstrap
if ! cd "$HOME"; then
    echo "cannot move to ${HOME}, user is likely incorrect"
    exit 1
fi

mkdir "$gitDir"

if ! cd "$gitDir"; then
    echo "cannot move to ${gitDir}"
    exit 1
fi

if ! git clone $dotfilesRepo "$dotfilesDir"; then
    echo "cannot clone $dotfilesRepo"
    exit 1
fi

if ! cd $dotfilesRepo; then
    echo "cannot move to $dotfilesRepo"
    exit 1
fi

# run bootstrap script for configs
if ! $dotfilesRepo/bootstrap.sh; then
    echo "bootstrap failed!"
    exit 1
fi

echo "bootstrap completed succesfully, PABLO should now be working!"

#############################################################
source "$HOME/scripts/PABLO.sh"

downloadDir="$HOME/Downloads/"
desktopDir="$HOME/Desktop/"

#############################################################
pStart

mkdir -p "${downloadDir}"
pCheckError $? "mkdir for $downloadDir"
mkdir -p "${desktopDir}"
pCheckError $? "mkdir for $desktopDir"

# update all packages
pLog "system update"
sudo pacman -Syyu
pCheckError $? "pacman system update"

# install locales
pLog "Generating correct locales"
sudo -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen
sudo -i 's/#en_GB.UTF-8 UTF-8/en_GB.UTF-8 UTF-8/g' /etc/locale.gen
sudo locale-gen
pCheckError $? "locale-gen"

pLog "installing pacman packages"
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
                openttd openttd-opengfx openttd-opensfx \
                npm \
                shellcheck
pCheckError $? "pacman packages installed"

# ZSH
chsh -s /bin/zsh
pCheckError $? "change shell"

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
