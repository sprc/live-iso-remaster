#!/bin/bash
sudo rm -rf /tmp/*
sudo rm ~/.bash_history

sudo rm /var/lib/dbus/machine-id
sudo rm /sbin/initctl
sudo dpkg-divert --rename --remove /sbin/initctl

sudo umount /proc
sudo umount /sys
sudo umount /dev/pts

echo ""
echo "Things cleaned up."
echo ""
