#!/bin/bash

# 1. Ask for input and wait
echo "Enter the absolute path where you want to create the test file (e.g., /home/student):"
read -r TARGET_DIR

# Remove trailing slash if user added one, for consistency
TARGET_DIR="${TARGET_DIR%/}"

# Check if directory exists; if NOT, exit the program
if [ ! -d "$TARGET_DIR" ]; then
    echo "Error: Directory '$TARGET_DIR' does not exist."
    exit 1
fi

# Define the target files based on user input
TEST_FILE="$TARGET_DIR/hello_test.c"
EXE_FILE="$TARGET_DIR/hello_test"

# 2. Write the C content to the file
cat << 'EOF' > "$TEST_FILE"
#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <errno.h>
#include <linux/kernel.h>
#include <sys/syscall.h>

#define __NR_hello 548

long hello_syscall(void) {
    return syscall(__NR_hello);
}

int main(int argc, char *argv[]) {
    long rv;

    rv = hello_syscall();

    if(rv < 0) {
        perror("Hello syscall failed");
    }
    else {
        printf("Hello syscall ran successfully, check dmesg output\n");
    }

    return 0;
}
EOF

echo "Success! Test file created at: $TEST_FILE"

printf "\n\nTesting syscall, expect output:\n" 
printf "\n-------------------------------------------------------------\n\n"

# Compile using the dynamic path
gcc -o "$EXE_FILE" "$TEST_FILE"

# Run the executable
"$EXE_FILE"

printf "\n\n-------------------------------------------------------------\n\n"

printf "\nPrinting Kernel Logs... --------------------------------\n\n"
dmesg | tail

printf "\n\nExiting ---\n"
