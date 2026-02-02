#!/bin/bash

# --- Defaults ---
DEFAULT_RAM="8G"
DEFAULT_CORES="4"

# --- 1. Detect Host Resources ---
# nproc gets total processing units
HOST_CORES=$(nproc)
# free -h gets human readable memory, awk extracts the total column
HOST_RAM=$(free -h | awk '/^Mem:/{print $2}')

# --- 2. Select Disk using fzf ---
DISK_NAME=$(find . -maxdepth 1 -name "*.qcow2" | fzf --prompt="Select Disk Image > ")

# Exit if no file was selected
if [[ -z "$DISK_NAME" ]]; then
    echo "No disk selected. Exiting."
    exit 1
fi

# --- 3. Resource Allocation Prompts ---
clear
echo "------------------------------------------"
echo "🔧 VM Configuration"
echo "------------------------------------------"
echo "Host Resources Available:"
echo "   🧠 System RAM:   $HOST_RAM"
echo "   🔢 System Cores: $HOST_CORES"
echo "------------------------------------------"

# Ask for Cores (Default to 2 if input is empty)
read -p "Enter Cores to allocate [Default: $DEFAULT_CORES]: " INPUT_CORES
CORES=${INPUT_CORES:-$DEFAULT_CORES}

# Ask for RAM (Default to 4G if input is empty)
read -p "Enter RAM (e.g., 2G, 4096M) [Default: $DEFAULT_RAM]: " INPUT_RAM
RAM=${INPUT_RAM:-$DEFAULT_RAM}

# --- 4. Display Status Output ---
echo ""
echo "------------------------------------------"
echo "🚀 Launching Virtual Machine..."
echo "📂 Disk:  $DISK_NAME"
echo "🧠 RAM:   $RAM"
echo "🔢 Cores: $CORES"
echo "🖥️  Video: virtio with cursor enabled"
echo "------------------------------------------"


# 3. Launch QEMU
qemu-system-x86_64 \
  -enable-kvm \
  -m $RAM \
  -smp $CORES \
  -drive file="$DISK_NAME",format=qcow2 \
  -vga virtio \
  -nic user,model=virtio-net-pci \
  -display gtk,show-cursor=on \
  -usb -device usb-tablet

echo "✅ VM process has terminated."
