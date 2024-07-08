#!/bin/bash
rm -f boot.bin boot.img

nasm -f bin -o boot.bin boot.asm
nasm -f bin -o loader.bin loader.asm

# dd if=boot.bin of=boot.img bs=512 count=1
# dd if=loader.bin of=boot.img bs=512 count=5 seek=1
dd if=boot.bin >> os.bin
dd if=loader.bin >> os.bin
dd if=/dev/zero bs=512 count=5 >> os.bin

qemu-system-x86_64 -hda os.bin
