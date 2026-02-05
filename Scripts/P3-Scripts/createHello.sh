HELLO_DIR="hello_syscall"
HELLO_C_FNAME="hello.c"


echo "Enter: Starting createHello.sh ---"
echo "Creating Directory $HELLO_DIR"
# 1. Create directory (using -p to avoid errors if it already exists)
sudo mkdir -p "$HELLO_DIR"
echo "Writing hello.c"
cat << 'EOF' | sudo tee "$HELLO_DIR/$HELLO_C_FNAME" > /dev/null
#include <linux/kernel.h>
#include <linux/syscalls.h>

SYSCALL_DEFINE0(hello) {
    printk("Hello World!\n");
    return 0;
}
EOF
echo "File created at $HELLO_DIR/$HELLO_C_FNAME"
echo "Creating makefile at $HELLO_DIR/Makefile"
printf "obj-y := hello.o" | sudo tee "$HELLO_DIR/Makefile"
echo "Hello Obj Files/Dir Initalized \n Exiting ---"
