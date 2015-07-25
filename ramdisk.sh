#!/bin/bash
if [ "$1" = "" ]; then
	echo "Directory must be specified to mount the ramdisk in! (param 1)"
elif [ "$2" = "" ]; then
	echo "Size must be specified! (param 2)"
else
	dir=$1
	size=$2
	user=$(whoami)
	sudo mkdir $dir
	sudo mount -t ramfs -o size=$2 ext4 $dir
	sudo chown $user:$user $dir
fi
