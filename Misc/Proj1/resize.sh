#!/bin/bash

# Dependency Check
if ! command -v fzf &> /dev/null; then
    echo "Error: 'fzf' is not installed. Please install it (sudo apt install fzf)."
    exit 1
fi
if ! command -v qemu-img &> /dev/null; then
    echo "Error: 'qemu-img' is not installed."
    exit 1
fi

# 1. Get the Image File
IMAGE_FILE="$1"

# If no file argument provided, use fzf to find .qcow2 files in current dir
if [ -z "$IMAGE_FILE" ]; then
    echo "Select a VM image to resize:"
    # find .qcow2 files in current dir (maxdepth 1), strip the leading ./ for cleaner view
    IMAGE_FILE=$(find . -maxdepth 1 -name "*.qcow2" -type f | sed 's|^\./||' | fzf --height=20% --layout=reverse --border)
fi

# If user cancelled fzf or no file selected
if [ -z "$IMAGE_FILE" ]; then
    echo "No file selected. Exiting."
    exit 1
fi

# 2. Get the Size to Add
ADD_SIZE="$2"

if [ -z "$ADD_SIZE" ]; then
    echo -n "Enter size to add (e.g., +10G, +512M): "
    read ADD_SIZE
fi

# Validate input
if [ -z "$ADD_SIZE" ]; then
    echo "No size specified. Exiting."
    exit 1
fi

echo "----------------------------------------"
echo "Target Image: $IMAGE_FILE"
echo "Adding Size:  $ADD_SIZE"
echo "----------------------------------------"

# 3. Create a backup
BACKUP_NAME="${IMAGE_FILE}.backup_$(date +%s)"
echo "[1/3] Creating backup as '$BACKUP_NAME'..."
cp "$IMAGE_FILE" "$BACKUP_NAME"

if [ $? -ne 0 ]; then
    echo "Error: Backup failed. Aborting."
    exit 1
fi

# 4. Resize the image
echo "[2/3] Resizing disk image..."
qemu-img resize "$IMAGE_FILE" "$ADD_SIZE"

if [ $? -eq 0 ]; then
    echo "[3/3] Success! Disk expanded."
    echo ""
    echo "----------------------------------------"
    echo "NEW DISK STATUS:"
    qemu-img info "$IMAGE_FILE" | grep "virtual size"
    echo "----------------------------------------"
    echo "NEXT STEPS (Inside the VM):"
    echo "1. Boot the VM."
    echo "2. Run: sudo growpart /dev/vda 1"
    echo "3. Run: sudo resize2fs /dev/vda1"
    echo "----------------------------------------"
else
    echo "Error: Resize failed."
    mv "$BACKUP_NAME" "$IMAGE_FILE"
    echo "Backup restored."
    exit 1
fi
