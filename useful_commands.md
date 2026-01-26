# Tips and Tricks

## Compilation 
It seems for this course they are using an older version of gcc
## Clean Dir
It is good practice to ensure the source directory is clean before starting, especially if you have tried building before.
`make mrproper`

## Configure Kernel 
The Makefile needs a .config file to know which drivers to compile. You have two main options:
`make defconfig` or `make menuconfig` 
## Compile With All Available Cores 
To speed it up, we tell `make` to use all your CPU cores using the `-j` flag.
`make -j$(nproc)`


## GDB w/ QEMU
Since this is for "Project 1," you likely need to debug your code. You can pause the kernel and inspect it using GDB.

    Run QEMU with the -s -S flags:
    Bash

    qemu-system-x86_64 -kernel arch/x86/boot/bzImage -nographic -s -S

        -s: Opens a debugger port on localhost:1234.

        -S: Freezes the CPU at startup.

    Open a second terminal window, go to your kernel source folder, and run:
    Bash

    gdb vmlinux

    (Note: Here we use vmlinux because GDB needs the uncompressed file to read the symbols/variable names).

    Inside GDB, connect to QEMU:
    Code snippet

    target remote :1234
    continue

Now your kernel runs, and you can hit Ctrl+C in GDB to pause it, set breakpoints, and inspect variables.

## Run bzImage
```bash
qemu-system-x86_64 \
  -kernel arch/x86/boot/bzImage \
  -append "root=/dev/sda console=ttyS0" \
  -nographic \
  -enable-kvm
```
