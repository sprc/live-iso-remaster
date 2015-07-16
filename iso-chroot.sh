#!/bin/bash

iso=$1
path=$PWD

if [ "$1" == "" ]; then
	echo "***Path to iso must be provided!"
	exit
fi

if ! [ -e $1 ]; then
	echo "***File doesn't exist!"
	exit
fi

#create ramdisk, move iso into it
sh ramdisk.sh
cd tmp
cp "$iso" pre.iso
sync

mkdir mnt
mkdir extract-cd
mkdir edit

#mount the iso to 'mnt', extract it to 'extract-cd'
sudo mount -o loop pre.iso mnt
sudo rsync --exclude=/casper/filesystem.squashfs -a mnt/ extract-cd
sync

#unsquash to 'edit', enter chroot

sudo unsquashfs mnt/casper/filesystem.squashfs
sync
sudo mv squashfs-root/* edit
sudo cp "$path/iso-chroot-main.sh" "$path/tmp/edit/iso-chroot-main.sh"

sudo mount --bind /dev/ edit/dev
sudo mount -o bind /run/ edit/run

echo ""
echo "   Entering chroot..."
echo ""

sudo chroot edit /bin/bash "/iso-chroot-main.sh"

echo ""
echo "   Leaving chroot..."
echo ""
echo "Do any additional stuff you want to do, then exit."
echo "When you exit, we'll repack the iso and clean everything up."
echo ""
bash

cd $path
sudo rm "./tmp/edit/iso-chroot-main.sh"
cd tmp

echo "   Regenerating manifest..."

sudo chmod +w extract-cd/casper/filesystem.manifest

sudo bash -c "chroot edit dpkg-query -W --showformat='${Package} ${Version}\n' > extract-cd/casper/filesystem.manifest"

sudo cp extract-cd/casper/filesystem.manifest extract-cd/casper/filesystem.manifest-desktop
sudo sed -i '/ubiquity/d' extract-cd/casper/filesystem.manifest-desktop
sudo sed -i '/casper/d' extract-cd/casper/filesystem.manifest-desktop

echo "   Compressing filesystem..."

sudo rm extract-cd/casper/filesystem.squashfs
#sudo mksquashfs edit extract-cd/casper/filesystem.squashfs -nolzma
sudo mksquashfs edit extract-cd/casper/filesystem.squashfs -comp lzo

#printf $(sudo du -sx --block-size=1 edit | cut -f1) > extract-cd/casper/filesystem.size

sudo nano extract-cd/README.diskdefines

echo "Recalculating md5 sums..."
cd extract-cd
sudo rm md5sum.txt
find -type f -print0 | sudo xargs -0 md5sum | grep -v isolinux/boot.cat | sudo tee md5sum.txt

echo "$IMAGE_NAME"

#sudo mkisofs -D -r -V "$IMAGE_NAME" -cache-inodes -J -l -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -o $path/tmp/custom.iso .
sudo xorriso -as mkisofs -no-emul-boot -boot-load-size 4 -boot-info-table -iso-level 4 -b isolinux/isolinux.bin -c isolinux/boot.cat -eltorito-alt-boot -e boot/grub/efi.img -no-emul-boot -o $path/tmp/custom.iso .

sudo isohybrid --uefi $path/tmp/custom.iso

echo "   Done...?"

bash

cd $path
sudo umount $path/tmp/edit/dev
sudo umount $path/tmp/edit/run
sudo umount $path/tmp/mnt
sudo umount $path/tmp
rm -r tmp
