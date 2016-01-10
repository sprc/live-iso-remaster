#!/bin/bash
cd /chroot-scripts
FILES="*"
for f in $FILES
do
	echo "Executing $f..."
	bash -c "./$f"
done
cd /
