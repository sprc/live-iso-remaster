#!/bin/bash
sudo mount -t proc none /proc
sudo mount -t sysfs none /sys
sudo mount -t devpts none /dev/pts

export HOME=/root
export LC_ALL=C

dbus-uuidgen > /var/lib/dbus/machine-id
dpkg-divert --local --rename --add /sbin/initctl
ln -s /bin/true /sbin/initctl

sudo apt-add-repository -y ppa:mjblenner/ppa-hal

sudo apt-get purge -y libreoffice* empathy evolution zeitgeist totem rhythmbox
sudo apt-get purge -y aisleriot gnome-mahjongg gnome-weather gnome-maps gnome-sudoku gnome-mines
#sudo apt-get purge -y firefox
sudo apt-get purge -y ubuntu-gnome-desktop
sudo apt-get purge -y yelp transmission-* software-center* gnome-tweak-tool gnome-sushi fonts-tlwg-* evince evince-common brasero brasero-* gnome-orca*
sudo apt-get purge -y gnome-accessibility-themes fonts-guru* fonts-kacst* fonts-lao fonts-nanum fonts-lohit-guru fonts-khmeros-core fonts-sil-* fonts-takao-* fonts-tibetan-* gnome-disk-utility gnome-documents gnome-font-viewer gnome-online-* usb-creator-* cups cups-browsed cups-bsd cups-client cups-common cups-core-drivers cups-daemon cups-filters cups-filters-core-drivers cups-server-common cups-pk-helper cups-server-common gnome-keyring eog

#sudo apt-mark hold linux-image-generic linux-headers-generic linux-generic linux-signed-image-generic linux-signed-headers-generic
sudo apt-get purge -y linux-image-generic linux-headers-generic linux-generic linux-signed-image-generic linux-signed-headers-generic
cd /tmp
sudo apt-get purge -y linux-headers-3.19.0-15* linux-headers-3.19.0-15-generic* linux-image-3.19.0-15-generic* linux-image-extra-3.19.0-15-generic* linux-signed-image-3.19.0-15-generic* linux-signed-image-generic*
cd /
sudo dpkg -i *.deb

#sudo apt-get install -y linux-image-generic linux-headers-generic linux-generic linux-signed-image-generic linux-signed-headers-generic linux-headers-3.19.0-15* linux-headers-3.19.0-15-generic* linux-image-3.19.0-15-generic* linux-image-extra-3.19.0-15-generic* linux-signed-image-3.19.0-15-generic* linux-signed-image-generic*

#sudo apt-get update -y && sudo apt-get upgrade -y
#sudo apt-get install -y nano gedit xfce4-terminal firefox bash-completion gnome-system-monitor gnome-tweak-tool gnome-calculator openconnect openvpn freerdp unclutter git pulseaudio gparted gnome-screenshot xdotool pv
#sudo apt-get install -y chromium-browser
#sudo apt-get install -y ubuntu-restricted-extras
#sudo apt-get install -y pepperflashplugin-nonfree
#sudo update-pepperflashplugin-nonfree --install --verbose
#sudo apt-get install -y hal
#sudo apt-get install -y gimp

#echo ""
#echo "Inside the chroot, ready for changes."
#echo "When finished, exit this script's prompt. Additional cleanup"
#echo "will then be done and you will be exited out of the chroot."
#bash

sudo apt-get autoremove -y
sudo apt-get autoclean -y
sudo apt-get clean -y

sudo rm -rf /tmp/*
sudo rm ~/.bash_history

sudo rm /var/lib/dbus/machine-id
sudo rm /sbin/initctl
dpkg-divert --rename --remove /sbin/initctl

sudo umount /proc
sudo umount /sys
sudo umount /dev/pts

echo ""
echo "Things cleaned up."
echo ""
