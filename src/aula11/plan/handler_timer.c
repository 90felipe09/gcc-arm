//Esse código foi desenvolvido para a aula 10 do curso PCS3732- Laboratório de Processadores - 2020
//Feito pelos alunos:
//Felipe Kenzo Shiraishi - 10262700
//Hector Kobayashi Yassuda - 10333289
//Vitor Hugo Perles - 9285492

//Para compilar, rodar e debugar: Ler READ.ME em anexo

void handler_timer() {
    unsigned int *RTIMEROX = (unsigned int *) 0x101E200C;
    *RTIMEROX = (unsigned int) 0;
}


