echo "Enter: Appending Prototype Call to syscals.h ---"
CALL="asmlinkage long sys_hello(void);"
# Pipe the string into 'sudo tee' with the append flag (-a)
echo "$CALL" | sudo tee -a include/linux/syscalls.h 
echo "Exiting ---"
