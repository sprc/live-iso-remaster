#!/bin/bash
sudo mount -t proc none /proc
sudo mount -t sysfs none /sys
sudo mount -t devpts none /dev/pts

export HOME=/root
export LC_ALL=C

dbus-uuidgen > /var/lib/dbus/machine-id
dpkg-divert --local --rename --add /sbin/initctl
ln -s /bin/true /sbin/initctl

echo ""
echo "Ready for changes!"
echo "When finished, exit this script's prompt. Additional cleanup"
echo "will then be done, whereupon you can exit the chroot."

bash

sudo apt-get autoclean
sudo apt-get clean

rm -rf /tmp/*
rm ~/.bash_history

rm /var/lib/dbus/machine-id
rm /sbin/initctl
dpkg-divert --rename --remove /sbin/initctl

sudo umount /proc
sudo umount /sys
sudo umount /dev/pts

echo ""
echo "Things cleaned up."
echo ""
