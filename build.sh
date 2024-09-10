#!/bin/bash
make
cp bin/kernel.bin iso/boot
grub-mkrescue -o mykernel.iso iso
qemu-system-x86_64 -cdrom mykernel.iso