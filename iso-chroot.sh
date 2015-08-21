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

sudo apt-get install squashfs-tools curl syslinux-utils xorriso

#create ramdisk, move iso into it
sh ramdisk.sh tmp 8g
cd tmp
sudo cp "$iso" pre.iso
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

#cd ~/src/linux-4.1-samus/build/debian
cd ~/src/linux-samus/linux-samus-ubuntu-0.2.2
sudo cp *.deb "$path/tmp/edit/"
cd $path/tmp

sudo mount --bind /dev/ edit/dev
sudo mount -o bind /run/ edit/run
sudo mount --bind /proc/ edit/proc

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

cd $path/tmp

echo "sudo cp edit/boot/vmlinuz-3.19.0-11.11+samus-1-generic extract-cd/casper/vmlinuz.efi"
sudo cp edit/boot/vmlinuz-3.19.0-11.11+samus-1-generic extract-cd/casper/vmlinuz.efi
echo "sudo cp edit/boot/initrd.img-3.19.0-11.11+samus-1-generic extract-cd/casper/initrd.lz"
sudo cp edit/boot/initrd.img-3.19.0-11.11+samus-1-generic extract-cd/casper/initrd.lz
#bash

cd $path/tmp

cd $path
sudo rm $path/tmp/edit/iso-chroot-main.sh
sudo rm $path/tmp/edit/*.deb
cd tmp
cd extract-cd
cd isolinux
sudo sed -i 's/ui gfxboot bootlogo/#ui gfxboot bootlogo/g' isolinux.cfg
sudo sed -i 's/quiet splash/toram/g' txt.cfg

cd $path/tmp

echo "   Regenerating manifest..."
sudo chmod +w extract-cd/casper/filesystem.manifest
sudo bash -c "chroot edit dpkg-query -W --showformat='${Package} ${Version}\n' > extract-cd/casper/filesystem.manifest"
sudo cp extract-cd/casper/filesystem.manifest extract-cd/casper/filesystem.manifest-desktop
sudo sed -i '/ubiquity/d' extract-cd/casper/filesystem.manifest-desktop
sudo sed -i '/casper/d' extract-cd/casper/filesystem.manifest-desktop

echo "   Unmounting dev, run, proc..."
sudo umount $path/tmp/edit/dev
sudo umount $path/tmp/edit/run
sudo umount $path/tmp/edit/proc

echo "   Compressing filesystem..."
sudo rm extract-cd/casper/filesystem.squashfs
sudo mksquashfs edit extract-cd/casper/filesystem.squashfs
sudo bash -c "printf $(sudo du -sx --block-size=1 edit | cut -f1) > extract-cd/casper/filesystem.size"

#sudo nano extract-cd/README.diskdefines

echo "   Recalculating md5 sums..."
cd extract-cd
sudo rm md5sum.txt
find -type f -print0 | sudo xargs -0 md5sum | grep -v isolinux/boot.cat | sudo tee md5sum.txt


sudo xorriso -as mkisofs -no-emul-boot -boot-load-size 4 -boot-info-table -iso-level 4 -b isolinux/isolinux.bin -c isolinux/boot.cat -eltorito-alt-boot -e boot/grub/efi.img -no-emul-boot -o $path/tmp/custom.iso .
#sudo mkisofs -D -r -V "$IMAGE_NAME" -cache-inodes -J -l -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -o $path/tmp/custom.iso .
#sudo xorriso -as mkisofs -o $path/tmp/custom.iso -isohybrid-mbr /usr/lib/syslinux/isohdpfx.bin -c isolinux/boot.cat -b isolinux/isolinux.bin -no-emul-boot -boot-load-size 4 -boot-info-table .
#sudo genisoimage -o $path/tmp/custom.iso -c isolinux/boot.cat -b isolinux/isolinux.bin -no-emul-boot -boot-load-size 4 -boot-info-table -eltorito-alt-boot -e isolinux/efiboot.img -no-emul-boot .

sudo isohybrid $path/tmp/custom.iso

#sudo isohybrid --uefi $path/tmp/custom.iso

echo "cp custom.iso ~/Downloads/custom.iso ..."
cd $path/tmp
cp custom.iso ~/Downloads/custom.iso

usbcheck=$(sudo fdisk -l | grep "Disk /dev/sdc: 1.9 GiB")

echo $usbcheck

if [ "$usbcheck" != "" ]; then
        echo "sh $path/burn-usb.sh $path/tmp/custom.iso /dev/sdc ..."
        sh $path/burn-usb.sh $path/tmp/custom.iso /dev/sdc
else
        echo "Couldn't find USB"
	bash
fi

echo "Syncing..."
sync

echo "Cleaning things up..."

cd $path
sudo umount $path/tmp/mnt
sudo umount $path/tmp
sudo rm -r tmp
