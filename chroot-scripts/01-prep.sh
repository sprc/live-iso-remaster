#!/bin/bash
sudo mount -t proc none /proc
sudo mount -t sysfs none /sys
sudo mount -t devpts none /dev/pts

export HOME=/root
export LC_ALL=C

sudo dbus-uuidgen > /var/lib/dbus/machine-id
sudo dpkg-divert --local --rename --add /sbin/initctl
sudo ln -s /bin/true /sbin/initctl
