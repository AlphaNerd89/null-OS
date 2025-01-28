if [-e "boot.bin"]; then
rm boot.bin
fi

if [-e "kernel.bin"]; then
rm kernel.bin
fi

if [-e "byte.bin"]; then
rm byte.bin
fi

if [-e "everything.bin"]; then
rm everything.bin
fi

if [-e "null.iso"]; then
rm null.iso
fi

#Convert everything to binary
nasm "bootloader.asm" -f bin -o "boot.bin"
nasm "kernel.asm" -f bin -o "kernel.bin"
nasm "bytewriter.asm" -f bin -o "byte.bin"

#add everything into a iso
cat "boot.bin" "kernel.bin" > "everything.bin"
cat "everything.bin" "byte.bin" > "null.iso"

# Run the ISO with qemu
echo "Running the ISO in QEMU..."
qemu-system-x86_64 -drive format=raw,file="null.iso",index=0,if=floppy, -m 128M

echo "Process completed."