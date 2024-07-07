#!/bin/bash
rm -f boot.bin boot.img

nasm -f bin boot.asm -o boot.bin
dd if=boot.bin of=boot.img bs=512 count=1 conv=notrunc

qemu-system-x86_64 -hda ./boot.bin
