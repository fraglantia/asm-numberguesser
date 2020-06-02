nasm -f elf random.asm
ld -m elf_i386 -s -o random random.o