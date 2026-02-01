#!/bin/bash
qemu-system-x86_64 \
  -enable-kvm \
  -m 4G \
  -smp 2 \
  -hda linux_vm.qcow2 \
  -cdrom /path/to/your-distro.iso \
  -boot d

# -enable-kvm: Crucial. Uses your CPU's hardware virtualization extensions.
# -m 2G: Gives the VM 2 Gigabytes of RAM.
# -smp 2: Gives the VM 2 CPU cores.
# -hda linux_vm.qcow2: Attaches the disk image you just created as the hard drive.
# -cdrom ...: Attaches your downloaded Linux ISO installer.
# -boot d: Tells QEMU to boot from the CD-ROM (the ISO) first.
