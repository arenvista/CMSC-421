#!/bin/bash

# --- Configuration ---
DISK_SIZE="20G"
RAM="4G"
CORES="2"

# 1. Select ISO using fzf
# find . -maxdepth 1 -name "*.iso" : Looks for .iso files in current folder only
# fzf --prompt...                  : Opens the selection menu
ISO=$(find . -maxdepth 1 -name "*.iso" | fzf --prompt="Select ISO > ")
DISK_NAME=$(find . -maxdepth 1 -name "*.qcow2" | fzf --prompt="Select Disk > ")

# 2. Check if user cancelled or no ISO was found
if [[ -z "$ISO" ]]; then
    echo "No ISO selected. Exiting."
    exit 1
fi

echo "Booting from: $ISO"

# 3. Launch QEMU
qemu-system-x86_64 \
  -enable-kvm \
  -m $RAM \
  -smp $CORES \
  -drive file="$DISK_NAME",format=qcow2 \
  -boot d \
  -vga virtio \
  -nic user,model=virtio-net-pci \
  -display default,show-cursor=on \
  -usb -device usb-tablet

# -enable-kvm: Crucial. Uses your CPU's hardware virtualization extensions.
# -m 4G: Gives the VM 4 Gigabytes of RAM.
# -smp 2: Gives the VM 2 CPU cores.
# -hda linux_vm.qcow2: Attaches the disk image as the hard drive.
# -cdrom ...: Attaches your downloaded Linux ISO installer.
# -boot d: Tells QEMU to boot from the CD-ROM (the ISO) first.

