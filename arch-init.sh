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

if ! cd "$dotfilesDir"; then
    echo "cannot move to $dotfilesDir"
    exit 1
fi

# run bootstrap script for configs
if ! "${dotfilesDir}/bootstrap.sh"; then
    echo "bootstrap failed!"
    exit 1
fi

echo "bootstrap completed succesfully, PABLO should now be working!"

#############################################################
source "$HOME/scripts/PABLO.sh"

downloadDir="$HOME/Downloads/"
desktopDir="$HOME/Desktop/"


syncStorage="${HOME}/.config/rslsync"
syncConfig="$syncStorage/sync.conf"

#############################################################
pStart

mkdir -p "${downloadDir}"
pCheckError $? "mkdir for $downloadDir"
mkdir -p "${desktopDir}"
pCheckError $? "mkdir for $desktopDir"

# update all packages
pLog "system update using pacman"
sudo pacman -Syyu
pCheckError $? "pacman system update"

# install locales
pLog "Generating correct locales"
sudo sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen
sudo sed -i 's/#en_GB.UTF-8 UTF-8/en_GB.UTF-8 UTF-8/g' /etc/locale.gen
sudo locale-gen
pCheckError $? "locale-gen"

# install packages
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
pCheckError $? "pacman packages install"

# yay install
pLog "installing yay package manager"
if ! cd "$downloadDir"; then
    echo "failed to cd to $downloadDir"
    exit 1
fi

git clone https://aur.archlinux.org/yay.git
pCheckError $? "git clone yay"
cd yay || exit
makepkg -si
pCheckError $? "makepkg"
yay -Y --gendb
pCheckError $? "yay gen db"
yay -Syu --devel
pCheckError $? "yay update"

pLog "installing AUR pakcages using yay"
yay -S  flavours \
        librewolf-bin \
        aur/rslsync \
        openttd-openmsx
pCheckError $? "yay package install"

# ZSH
pLog "changing default shell to zsh"
chsh -s /bin/zsh
pCheckError $? "chsh"

# dwm install
pLog "installing petes dwm"
cd "$gitDir" || exit
git clone https://github.com/PeterMaltby/petes-dwm.git
pCheckError $? "git clone dwm"
cd petes-dwm || exit
sudo make clean install
pCheckError $? "make"

# resilio sync
pLog "creating resilio sync config"
mkdir "$syncStorage"
pCheckError $? "mkdir"

cat > "$syncConfig" << EOF
{
	"device_name": "DEVICE_NAME",
	"listening_port": 8888,
	"storage_path": "STORAGE_PATH",
	"pid_file": "STORAGE_PATH/rslsync.pid",
	"use_upnp": false,

	"shared_folders" :
	[
	{
		"secret": "mysecret code",
		"dir": "/home/user/myfiles",
		"use_relay_server" : true,
		"use_tracker": false,
		"search_lan": false,
		"use_sync_trash" : false,
		"overwrite_changes": false,
		"selective_sync": false
	}
	]
}
EOF
pCheckError $? "cat config file"

sed -i "s/DEVICE_NAME/$USER@$HOSTNAME/g" "$syncConfig"
pCheckError $? "sed device name"
sed -i "s|STORAGE_PATH|${syncStorage}|g" "$syncConfig"
pCheckError $? "sed storage path"

pLog "sync template created at $syncConfig, please complete then enable the resilio user service"

pEnd
