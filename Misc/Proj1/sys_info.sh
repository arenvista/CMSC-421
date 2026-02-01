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
    echo "5. Exit"
    echo "============================="
}

# Loop until the user chooses to exit
while true; do
    show_menu
    read -p "Please select an integer [1-5]: " user_input

    # Validate that input is an integer and within the 1-5 range
    if [[ "$user_input" =~ ^[1-5]$ ]]; then
        echo "" # Print a blank line for formatting
        case $user_input in
            1)
                echo "--- GPU Information ---"
                lspci | grep -i vga
                ;;
            2)
                echo "--- Detailed GPU Info ---"
                # Check if user has sudo rights for lshw
                sudo lshw -C display
                ;;
            3)
                echo "--- RAM Usage ---"
                free -h
                ;;
            4)
                echo "--- Physical RAM Details ---"
                # Check if user has sudo rights for dmidecode
                sudo dmidecode --type memory | grep -E "Size:|Speed:|Type:" | grep -v "No Module"
                ;;
            5)
                echo "Exiting..."
                exit 0
                ;;
        esac
        echo ""
        read -p "Press Enter to return to menu..."
    else
        echo ""
        echo "Error: '$user_input' is not a valid option. Please enter a number between 1 and 5."
        echo ""
        sleep 1
    fi
done
