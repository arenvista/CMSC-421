#!/bin/bash

# Function to show the menu
show_menu() {
    echo "============================="
    echo "   System Information Menu   "
    echo "============================="
    echo "1. Show GPU Information (lspci)"
    echo "2. Show GPU Details (lshw - requires sudo)"
    echo "3. Show RAM Usage (free)"
    echo "4. Show Physical RAM Details (dmidecode - requires sudo)"
    echo "5. Show CPU Core Count"
    echo "6. Proceed to VM Configuration"
    echo "7. Exit Script"
    echo "============================="
}

# --- Part 1: System Info Loop ---
while true; do
    show_menu
    read -p "Please select an integer [1-7]: " user_input

    # Validate input range
    if [[ "$user_input" =~ ^[1-7]$ ]]; then
        echo "" 
        case $user_input in
            1)
                echo "--- GPU Information ---"
                lspci | grep -i vga
                ;;
            2)
                echo "--- Detailed GPU Info ---"
                sudo lshw -C display
                ;;
            3)
                echo "--- RAM Usage ---"
                free -h
                ;;
            4)
                echo "--- Physical RAM Details ---"
                sudo dmidecode --type memory | grep -E "Size:|Speed:|Type:" | grep -v "No Module"
                ;;
            5)
                echo "--- CPU Core Information ---"
                echo "Total Logical Cores: $(nproc)"
                lscpu | grep -E '^CPU\(s\):|Core\(s\) per socket:|Socket\(s\):'
                ;;
            6)
                echo "Proceeding to configuration..."
                break # Breaks the loop to continue the script
                ;;
            7)
                echo "Exiting..."
                exit 0
                ;;
        esac
        echo ""
        if [ "$user_input" -ne 6 ]; then
            read -p "Press Enter to return to menu..."
        fi
    else
        echo "Error: Invalid option. Please enter 1-7."
        sleep 1
    fi
done

echo "------------------------------------------------"
echo "           VM Configuration Setup               "
echo "------------------------------------------------"

# --- Part 2: Validate and Set CPU Cores ---
MAX_CORES=$(nproc)
while true; do
    read -p "Enter number of CPU Cores to assign (Max available: $MAX_CORES): " input_cores
    
    # Check if input is an integer
    if [[ "$input_cores" =~ ^[0-9]+$ ]]; then
        # Check if input is within valid range (1 to Max)
        if (( input_cores >= 1 && input_cores <= MAX_CORES )); then
            CORES=$input_cores
            break
        else
            echo "Error: Cores must be between 1 and $MAX_CORES."
        fi
    else
        echo "Error: Please enter a valid integer."
    fi
done

# --- Part 3: Validate and Set RAM ---
while true; do
    read -p "Enter RAM amount (e.g., 2G, 4096M): " input_ram
    
    # Regex to check for a number followed optionally by G, g, M, or m
    if [[ "$input_ram" =~ ^[0-9]+[GgMm]?$ ]]; then
        RAM=$input_ram
        break
    else
        echo "Error: Invalid format. Use 'G' for Gigabytes or 'M' for Megabytes (e.g., 4G, 2048M)."
    fi
done

echo ""
echo "Configuration set: Cores=$CORES, RAM=$RAM"
echo ""

# --- Part 4: Disk Selection (Requires fzf) ---
# Note: Ensure fzf is installed (sudo apt install fzf)
echo "Scanning for .qcow2 files..."
DISK_NAME=$(find . -maxdepth 1 -name "*.qcow2" | fzf --prompt="Select Disk > ")

# Check if a disk was actually selected
if [[ -z "$DISK_NAME" ]]; then
    echo "No disk selected or found. Exiting."
    exit 1
fi

echo "Booting VM with Disk: $DISK_NAME"

# --- Part 5: Run QEMU ---
# Note: I fixed the variable check (ISO -> DISK_NAME) to match your find command logic.
qemu-system-x86_64 \
  -enable-kvm \
  -m $RAM \
  -smp $CORES \
  -drive file="$DISK_NAME",format=qcow2 \
  -vga virtio \
  -display default,show-cursor=on \
  -nic user,model=virtio-net-pci \
  -usb -device usb-tablet

