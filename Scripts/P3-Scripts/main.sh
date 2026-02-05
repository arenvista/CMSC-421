echo "Calling Main...\n"
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

echo "Exiting ---"
./createHello.sh
./updateMake.sh
./addPrototypeCall.sh
./appendSysCallTable.sh
./makeTestCall.sh
echo "All Files Ran, Complete ---\n"
