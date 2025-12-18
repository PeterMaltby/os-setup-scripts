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

mkdir -p "$gitDir"

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


syncStorage="$HOME/.config/rslsync"
syncConfigTmp="${tmpDir}/sync.json"
syncConfigTmpWrite="${tmpDir}/syncw.json"
rawKeys="${tmpDir}/rawKeys.txt"
syncConfig="$syncStorage/rslsync.conf"
# secret name for bitwarden resilio keys
BWRSLNAME="resilio-keys"

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

# pacman configuration
sudo sed -i 's/#ParallelDownloads = 5/ParallelDownloads = 64/g' /etc/pacman.conf

# install packages
pLog "installing pacman packages"
sudo pacman -S  neofetch \
                picom \
                less \
                man-db \
                neovim \
                xorg-xsetroot \
                qbittorrent \
                ttf-liberation \
                htop \
                cronie \
                git \
                zsh \
                figlet \
                openssh \
                firefox \
                steam \
                dmenu \
                alacritty \
                thunderbird \
                vlc \
                openttd openttd-opengfx openttd-opensfx \
                npm \
                shellcheck \
                ttf-hack-nerd \
                pavucontrol \
                xfce4 \
                jq

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
        openttd-openmsx \
        bitwarden-cli
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
# add bitwarden-cli to yay installs
# add jq to installs pacman

pLog "logging into bitwarden"
while ! bw login --check; do
    bw login
done

pLog "collecting rslsync keys"
bw list items --search "$BWRSLNAME" | jq -r '.[] | .notes' > "$rawKeys"

pLog "got raw keys"
pLog "$(cat "$rawKeys")"

pLog "creating sync config using keys"
cat > "$syncConfigTmp" << EOF
{
	"device_name": "DEVICE_NAME",
	"listening_port": 8888,
	"storage_path": "STORAGE_PATH",
	"pid_file": "STORAGE_PATH/rslsync.pid",
	"use_upnp": false,
	"shared_folders" :
	[
	]
}
EOF

sed -i "s/DEVICE_NAME/$USER@$HOSTNAME/g" "$syncConfigTmp"
pCheckError $? "sed device name"
sed -i "s|STORAGE_PATH|${syncStorage}|g" "$syncConfigTmp"
pCheckError $? "sed storage path"

while read -r key; do
    dir=$(cut -d":" -f1 <<< "$key")
    key=$(cut -d":" -f2 <<< "$key")
    pLog "dir: $dir, key: $key"

    jq ".shared_folders += [{
	    \"secret\": \"$key\",
	    \"dir\": \"$HOME/$dir\",
	    \"use_relay_server\" : true,
	    \"use_tracker\": true,
	    \"search_lan\": true,
	    \"use_sync_trash\" : true,
	    \"overwrite_changes\": false
    }]" "$syncConfigTmp" >> "$syncConfigTmpWrite"

    mv "$syncConfigTmpWrite" "$syncConfigTmp"

done < "$rawKeys"

pLog "sync config generated"
pLog "$(cat "$syncConfigTmp")"

pLog "making dir $syncStorage"
mkdir -p "$syncStorage"
pCheckError $? "mkdir"

pLog "moving sync $syncConfigTmp file to $syncConfig"
mv "$syncConfigTmp" "$syncConfig"

pLog "sync config setup enable user service"
pEnd
