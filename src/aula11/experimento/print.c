//Esse código foi desenvolvido para a aula 10 do curso PCS3732- Laboratório de Processadores - 2020
//Feito pelos alunos:
//Felipe Kenzo Shiraishi - 10262700
//Hector Kobayashi Yassuda - 10333289
//Vitor Hugo Perles - 9285492

//Para compilar, rodar e debugar: Ler READ.ME em anexo

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

void print1(){
    print_uart0("1");
}

void print2(){
    print_uart0("2");
}