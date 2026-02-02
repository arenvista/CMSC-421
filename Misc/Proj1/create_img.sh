#!/bin/bash 

while true; do
    read -p "Please enter an file size (GB): " IMG_SIZE

    # Check if the input is an integer using Regex
    # ^-?   : Optional negative sign at the start
    # [0-9]+: One or more digits
    # $     : End of line
    if [[ "$IMG_SIZE" =~ ^-?[0-9]+$ ]]; then
        echo "Success! The integer is $IMG_SIZE"
        break  # Exit the loop
    else
        echo "Error: '$IMG_SIZE' is not a valid integer. Try again."
    fi
done

qemu-img create -f qcow2 "$@".qcow2 "$IMG_SIZE"G
