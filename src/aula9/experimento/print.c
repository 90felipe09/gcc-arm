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

void print() {
    print_uart0(" ");
}

void print_interrupt() {
    print_uart0("#");
}