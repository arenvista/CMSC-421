#!/bin/bash
sudo modprobe nbd max_part=8
sudo qemu-nbd --connect=/dev/nbd0 linux_vm.qcow2
sudo fdisk -l /dev/nbd0
sudo mkdir -p /mnt/qemu_disk 
sudo mount /dev/nbd0p1 /mnt/qemu_disk
