/* 
Para rodar essa experiência deve fazer:
eabi-gcc print.c -o print.o
eabi-as startup.s -o startup.o
eabi-ld -T test.ld print.o startup.o -o saida.elf
eabi-bin saida.elf saida.bin
qemu saida.elf

Em outro terminal para debug fazer (na pasta do .elf):
eabi-qemu -se saida.elf

Após isso conectar em
target remote localhost:1234
Debug pronto
*/

volatile unsigned int * const UART0DR = (unsigned int *)0x101f1000;

void print_uart0(const char *s){
    while(*s != '\0'){
        *UART0DR = (unsigned int) (*s);
        s++;
    }
}

void c_entry() {
    print_uart0("Hello world!\n");
}

void Undefined() {
    print_uart0("Instrucao invalida!\n");
}