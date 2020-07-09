@Esse código foi desenvolvido para a aula 8 do curso PCS3732- Laboratório de Processadores - 2020
@Feito pelos alunos:
@Felipe Kenzo Shiraishi - 10262700
@Hector Kobayashi Yassuda - 10333289
@Vitor Hugo Perles - 9285492

@Para compilar junto
@arm-elf-gcc -Wall -g -o programa-final.out main.c int2str.s division.s
@To run and debug:
@gdb programa-final.out
@(gdb) target sim
@(gdb) load
@(gdb) break main
@(gdb) run
@(gdb) continue

    .text
    .globl int2str
 
 @ void = int2str(r0, r1)
 @ r0 = input em número
 @ r1 = endereço do vetor de char
int2str:
    STMFD sp!, {r0-r10, fp, ip, lr}
    LDR r7, =0
    MOV r6, r1  @ r6 tem o endereço da string
    MOV r1, r0  @ r1 tem o input
    BL getOrdem
    MOV r10, r0  @ r10 tem a ordem
    MOV r4, r1  @ r4 tem o input
    MOV r9, r4  @ r9 tem o input
int2str_loop:
    CMP r10, #0
    BLT int2str_end
    LDR r1, =10    @ r1 tem a base 10
    MOV r2, r10  @ r2 tem a ordem
    BL potencia
    MOV r1, r9  @ r1 tem o input
    MOV r2, r0  @ r2 tem 10^ordem
    BL division @ r3 tem o dígito em questão.
    MLA r7, r3, r2, r7  @ Atualiza o subtrator
    ADD r8, r3, #0x30 @ converte o dígito em questão em caractere ascii
    STRB r8, [r6]   @ guarda o caractere na string
    ADD r6, r6, #1  @ Incrementa ponteiro para o próximo caractere da string
    SUB r10, r10, #1  @ Decrementou a ordem
    SUB r9, r4, r7  @ subtraiu o input pelo decrementador
    B int2str_loop
int2str_end:
    LDR r3, =0
    STRB r3, [r6]
    LDMFD sp!, {r0-r10, fp, ip, pc}

@ r0 = getOrdem(r1)
@ retorna em r0 a potência de 10 de r1.
@ e.g.: r1 = 12345 -> r0 = 4
getOrdem:
    STMFD sp!, {r1-r5, lr}
    LDR r0, =0x0
    LDR r2, =10
getOrdem_loop:
    CMP r1, #10
    BLT getOrdem_fim
    BL division
    MOV r1, r3
    ADD r0, r0, #1
    B getOrdem_loop
getOrdem_fim:
    LDMFD sp!, {r1-r5, pc}

@ r0 = potencia(r1, r2)
@ r1: base
@ r2: expoente
@ r0 = r1^r2
potencia:
    STMFD sp!, {r3, lr}
    LDR r3, =0
    LDR r0, =1
potencia_loop:
    CMP r3, r2
    BEQ potencia_end
    MUL r0, r1, r0
    ADD r3, r3, #1
    B potencia_loop
potencia_end:
    LDMFD sp!, {r3, pc}

