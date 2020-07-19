Como compilar e depurar:

eabi-gcc print.c -o print.o
eabi-as startup.s -o startup.o
eabi-ld -T test.ld print.o startup.o -o saida.elf
eabi-bin saida.elf saida.bin
qemu saida.elf

Em outro terminal:
eabi-qemu -se saida.elf