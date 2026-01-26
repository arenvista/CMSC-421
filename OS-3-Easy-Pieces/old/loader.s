# problem that stack point is not set to anything post boot loader
.set MAGIC, 0x1badb002 #magic number so grub recognizes kernel.bin as a kernel; storing as a compiler var
.set FLAGS, (1<<0 | 1<<1) 
.set CHECKSUM, -(MAGIC + FLAGS)

#moving compiler vars MAGIC, FLAGS, CHECKSUM into the .o file
.section .multiboot 
    .long MAGIC 
    .long FLAGS
    .long CHECKSUM

.section .text
.extern kernelMain #telling the asm that there is something called kernelMain and we want to be able to jump into that 
.global loader

loader: 
    mov $kernel_stack, %esp
    push $eax
    push $ebx
    call kernelMain 
# implementing a second inf loop, akin to kernelMain (just ensures twice program does not exit)
_stop:
    cli 
    hlt 
    jmp _stop

.section .bss
.space 2*1024*1024 #reserve 2MB of space
kernel_stack: 

