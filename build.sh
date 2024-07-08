#!/bin/bash
rm -f boot.bin loader.bin os.bin

nasm -f bin -o boot.bin boot.asm
nasm -f bin -o loader.bin loader.asm

dd if=boot.bin >> os.bin
dd if=loader.bin >> os.bin
dd if=/dev/zero bs=512 count=5 >> os.bin

qemu-system-x86_64 -hda os.bin -cpu host -enable-kvm
