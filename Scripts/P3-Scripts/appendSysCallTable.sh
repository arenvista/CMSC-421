echo "\n*NOTE: THIS WILL ONLY WORK ON AMD ARCHITECTURE*\n"
echo "Enter: Appending Syscall Table ----"
# Define the file path
TBL_FILE="arch/x86/entry/syscalls/syscall_64.tbl"

# Define the entry with explicit tab characters (\t)
# Format: <number> <abi> <name> <entry_point>
SYSCALL_ENTRY="548\tcommon\thello\tsys_hello"

# Use printf to handle the special characters and pipe to sudo tee to append
printf "${SYSCALL_ENTRY}\n" | sudo tee -a "$TBL_FILE" > /dev/null

echo "Added entry to $TBL_FILE"
echo "Exiting ---"
