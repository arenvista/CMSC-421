#!/bin/bash

# 0. Check if running as root/sudo
if [ "$EUID" -ne 0 ]; then
  echo "Error: This script must be run with sudo."
  echo "Usage: sudo ./update_makefile.sh"
  exit 1
fi

echo "Enter: Updating Krn Root Makefile ----"

# Ensure Makefile actually exists before trying to edit it
if [ ! -f "Makefile" ]; then
    echo "Error: Makefile not found in current directory!"
    exit 1
fi

HELLO_DIR="hello_syscall"

echo "Making Backup Makefile => Makefile.bk"
# 1. Create the backup
cp Makefile Makefile.bk

# 2. Define the new string
# Note: Using the specific spacing/paths you provided
NEW_STR="core-y    += kernel/ certs/ mm/ fs/ ipc/ security/ crypto/ block/ $HELLO_DIR/"

echo "Replacing Str..."
# 3. Use sed with pipe delimiter to handle paths cleanly
sed -i "s|core-y.*+= ker.*|$NEW_STR|" Makefile

printf "\n\nVerify Changes w/ Diff:"
printf "\n__________________________________________________________________________\n\n"
# 4. Verify the changes
diff Makefile.bk Makefile

printf "\n__________________________________________________________________________\n\n"

echo "Exiting ---"
