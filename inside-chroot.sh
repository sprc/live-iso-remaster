#!/bin/bash

CHROOT_CHECK=$(ls -di /)
if [ "$CHROOT_CHECK " = "2 / " ]; then
	echo "Not in chroot! Will not execute scripts."
else
	cd /chroot-scripts
	FILES="*"
	for f in $FILES
	do
		echo "Executing $f..."
		bash -c "./$f"
	done
	cd /
fi
