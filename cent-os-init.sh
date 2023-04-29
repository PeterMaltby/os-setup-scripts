#!/bin/bash
# cent-os.sh
# author: peterm
# created: 2023-04-28
#############################################################

# update and install git and vim
dnf update -y
dnf install git vim -y
git -v

# create admin user
adduser -m -G wheel peterm
passwd peterm
sudo -u peterm mkdir -p --mode=700 /home/peterm/.ssh
mv /root/.ssh/authorized_keys /home/peterm/.ssh/.
chown peterm:peterm /home/peterm/.ssh/authorized_keys

# disable root login and password login
sed -i 's/PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config

cd /home/peterm/ || exit
sudo -u peterm mkdir gitrepos
cd gitrepos/ || exit

# bootstrap dotfiles repo
sudo -u peterm git clone https://github.com/PeterMaltby/.dotfiles.git
cd .dotfiles || exit
sudo -u peterm ./bootstrap.sh

# restart ssh daemon
systemctl reload sshd

echo "your server is ready!"
