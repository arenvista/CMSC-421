#!/bin/bash

# Usage: sudo ./mount_qcow2.sh /path/to/image.qcow2 /mnt/target
IMAGE=$1
MOUNT_POINT=$2
NBD_DEV="/dev/nbd0"

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root (use sudo)"
   exit 1
fi

if [[ -z "$IMAGE" || -z "$MOUNT_POINT" ]]; then
    echo "Usage: $0 <path_to_qcow2> <mount_point>"
    exit 1
fi

# 1. Load NBD module
echo "Loading nbd kernel module..."
modprobe nbd max_part=8

# 2. Connect the image
echo "Connecting $IMAGE to $NBD_DEV..."
qemu-nbd --connect=$NBD_DEV "$IMAGE"

# Give the system a second to register partitions
sleep 1

# 3. Detect the first partition (Change nbd0p1 if you need a different partition)
PARTITION="${NBD_DEV}p1"

if [ ! -b "$PARTITION" ]; then
    echo "Error: Partition $PARTITION not found. Check 'lsblk $NBD_DEV' manually."
    qemu-nbd --disconnect $NBD_DEV
    exit 1
fi

# 4. Mount
echo "Mounting $PARTITION to $MOUNT_POINT..."
mkdir -p "$MOUNT_POINT"
mount "$PARTITION" "$MOUNT_POINT"

if [ $? -eq 0 ]; then
    echo "Successfully mounted! Access your files at $MOUNT_POINT"
    echo "To unmount safely, run: sudo qemu-nbd --disconnect $NBD_DEV"
else
    echo "Mount failed."
    qemu-nbd --disconnect $NBD_DEV
fi
