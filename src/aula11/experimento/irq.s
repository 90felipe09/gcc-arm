@Esse código foi desenvolvido para a aula 10 do curso PCS3732- Laboratório de Processadores - 2020
@Feito pelos alunos:
@Felipe Kenzo Shiraishi - 10262700
@Hector Kobayashi Yassuda - 10333289
@Vitor Hugo Perles - 9285492

@Para compilar, rodar e debugar: Ler READ.ME em anexo


.global _start
.text
_start:
    b _Reset    @ posição 0x00 - Reset
    ldr pc, _undefined_instruction  @ posição 0x04 - Instrução não-definida
    ldr pc, _software_interrupt @posição 0x08 - Interrupção de software
    ldr pc, _prefetch_abort @ posição 0x0C - Prefetch Abort
    ldr pc, _data_abort @ posição 0x10 - Data Abort
    ldr pc, _not_used       @ posição 0x14 - Não utilizado
    ldr pc, _irq    @ posição 0x18 - Interrupção (IRQ) @ breakpoint aqui (ver o sp, pc, modo e etc)
    ldr pc, _fiq    @ Posição 0x1C - Interrupção (FIQ)

_undefined_instruction: .word undefined_instruction
_software_interrupt: .word software_interrupt
_prefetch_abort: .word prefetch_abort
_data_abort: .word data_abort
_not_used: .word not_used
_irq: .word irq
_fiq: .word fiq

@ Vamos operar o Vectored Interrupt Controller (VIC)
@   por isso a gente vai manipular os seguintes registradores:
@   1. VICIRQSTATUS: Status dos bits de interrupção. Usado para identificar
@       qual dispositivo gerou a interrupção. O bit 4 corresponde a inte
@       interrupções dos timers 0 e 1.
@   2. VICINTSELECT: Permite selecionar quais dispositivos utilizarão IRQs
@       ou FIQs. Um bit setado significa que o dispositivo utilizará FIQs
@   3. VICINTENABLE: Permite habilitar individualmente as interrupções de
@       de cada dispositivo.
@ Constantes
INTPND: .word 0x10140000    @ Interrupt status register VICIRQSTATUS
INTSEL: .word 0x1014000C    @ Interrupt select register (0 = irq, 1 = fiq) VICINTSELECT
INTEN: .word 0x10140010     @ Interrupt enable register VICINTENABLE
TIMEROL: .word 0x101E2000   @ Timer 0 load register
TIMEROV: .word 0x101E2004   @ Timer 0 value registers
TIMEROC: .word 0x101E2008   @ Timer 0 control register
TIMEROX: .word 0x101E200C   @ Timer 0 interrupt clear register
@ Descrição dos registradores de timer:
@ TIMEROL: Load Register. O valor para o qual resetar o timer (atualiza
@   imediatamente o TIMEROV, Registrador atual de contagem).
@   Quando 0 significa que é para gerar uma interrupção imediatamente.
@ TIMEROV: Current Value Register. Quando TIMEROL é atualizado, ele copia.
@   É este valor que será decrementado e representa a contagem do timer
@ TIMEROC: Control Register. Os bits [31:8] não são para modificar ou ler
@   Dos que restam:
@   7: Enable bit.
@   6: Timer mode. 1 = periodico. 0 = default (free running)
@   5: IntEnable. 1 = Interrupt enabled (default). 0 = Interrupt disabled
@   4: Ignorar. Reservado. Não modificar
@   3-2: Timer Pre. Prescale bits:
@       00 = 0 estágios de prescale, clock é dividido por 1 (default)
@       01 = 4 estágios de prescale, clock é dividido por 16
@       10 = 8 estágios de prescale, clock é dividido por 256
@       11 = Não definido. Não usar.
@   1: TimerSize. 0 = contador de 16 bits (default), 1 = contador de 32-bits
@   0: OneShot: 0 = wrapping mode (default), 1 = one-shot mode ???
@ TIMEROX: Interrupt Clear Register. Qualquer escrita neste registrador
@   Faz limpar a saída de interrupção do contador.

@ Interrupt handlers redirect

_Reset:
    bl initialize_stacks
    bl main
    b .

undefined_instruction:
    b .

@ Não está fazendo nada de importante na verdade
software_interrupt:
    b do_software_interrupt @ Vai para o handler de interrupções de software

prefetch_abort:
    b .

data_abort:
    b .

not_used:
    b .

irq:
    b do_irq_interrupt  @ vai para o handler de interrupções IRQ

fiq:
    b .

@ Interrupt handlers implementation:
do_software_interrupt:
    add r1, r2, r3
    mov pc, lr

do_irq_interrupt:
    @ Inicia o armazenamento em linha de rascunho
    sub lr, lr, #4              @ Corrige lr

    @ Obtenção da linha respectiva do processo
    str r0, register0_placeholder   @ Guarda r0 momentaneamente em register0_placeholder
    str r1, register1_placeholder
    str r2, register2_placeholder
    adr r0, linhaA
    ldr r1, linha_size
    ldr r2, nproc
    mla r0, r1, r2, r0
    str r0, linhaX

    ldr r0, register0_placeholder   @ recupera r0
    ldr r1, linhaX
    str r0, [r1, #4]            @ Guardar r0 em *linhaX+4
    ldr r1, register1_placeholder   @ recupera r1
    ldr r0, linhaX            @ Avançar r0 para *linhaX+8
    add r0, r0, #8
    stmia r0!,{r1-r12, lr}      @ Salvar r1-r12 e lr(PC do processo) em *linhaX+8 a *linhaX+60
    mrs r1, spsr                @ Pega o CPSR do processo que estava rodando
    ldr r2, linhaX
    str r1, [r2]              @ Guarda em *linhaX o CPSR do processo que tava rodando

    mrs r1, cpsr                @ Pega o cpsr atual
    msr cpsr_ctl, #0b11010011   @ Só pega os bits de modo do supervisor com FIQ e IRQ desabilitados
    stmia r0!, {sp, lr}         @ Guarda o sp e lr próprios do processo
    msr cpsr, r1                @ Retorna ao cpsr do modo irq
    @ Resultado: LinhaX: CPSR, R0 - R12, PC, SP, LR 

    @str r0, linha_draft  @ Armazena pelo menos o r0
    @adr r0, linha_draft  @ Usa r0 para ser o endereço de linhaA
    @add r0, r0, #4  @ Soma 4 para o endereço de linhaA
    @stmia r0!, {r1-r12}  @ armazena o resto dos registradores
    @mrs r1, cpsr
    @msr cpsr_ctl, #0b11010011   @ Supervisor (O bit 7 é o I de interrupção. setar ele garante o correto funcionamento)
    @stmia r0!, {sp, lr}  @ guarda sp e lr próprios do processo
    @msr cpsr, r1    @ recupera o cpsr
    @ldr r1, linha_draft
    @stmia r0!, {r1}  @ é o r0 do programa principal
    @mrs r1, spsr    @ pega o cpsr do supervisor
    @stmia r0!, {r1}  @ Guarda o cpsr do processo principal
    @str lr, linha_draft  @Guarda o pc na primeira posição de linhaA
    @ resultado: pc - r1 a r12 - sp - lr - r0 - cpsr
    @ Confere se linhaA ou linhaB
    @ldr r0, nproc
    @cmp r0, #0
    @adr r1, linha_draft
    @adreq r0, linhaA    @ LinhaA?
    @adrne r0, linhaB    @ Linha B?
    @ Armazena no local apropriado
    @ldmia r1!, {r2-r12} @ r0 - r10
    @stmia r0!, {r2-r12} 
    @ldmia r1!, {r2-r7} @ r11, r12, sp, lr, pc, cpsr
    @stmia r0!, {r2-r7}
    @Chaveando
    @adr r0, nproc
    @ldreq r1, =1
    @ldrne r1, =0
    @streq r1, [r0]
    @strne r1, [r0]
    @ Termina o armazenamento

    @ Chaveando o nproc:
    ldr r0, nproc
    add r0, r0, #1
    ldr r1, num_processos
    cmp r0, r1
    moveq r0, #0   @ Quando excede o número de processos, reseta pro 0.
    str r0, nproc

    @ IRQ HANDLER START ======================= @
    @bl print_interrupt Exercício da aula 10

    ldr r0, INTPND  @ Referência para o registrador de status de interrupção
    ldr r0, [r0]    @ Pega o valor

    tst r0, #0x0010 @ testa se a interrupção é do timer (0b0001 0000)
    blne handler_timer   @ Assim sendo, invoca o handler

    @ IRQ HANDLER END ========================  @

    @ Recuperando o conteúdo da linha para os registradores
    @ Obtenção da linha respectiva do processo
    adr r0, linhaA
    ldr r1, linha_size
    ldr r2, nproc
    mla r0, r1, r2, r0
    str r0, linhaX  @ Atualiza linhaX para ser a linha do próximo processo
    ldr r0, [r0]    @ Pega o cpsr do próximo processo
    msr cpsr, r0    @ atualiza o cpsr para ser o cpsr do próximo processo
    ldr r0, linhaX      @ r0 tem o endereço apontado pela linhaX
    ldr r0, [r0, #56] @ Carrega em r0 o PC dessa linhaX
    str r0, pc_placeholder  @ Armazeno este pc em pc_placeholder
    ldr r0, linhaX  
    add r0, r0, #4  @ r0 aponta para r0 - r12
    ldmia r0, {r0-r12}  @Recupera r0-r12
    ldr sp, linhaX      @recupera sp
    ldr sp, [sp, #60]
    ldr lr, linhaX
    ldr lr, [lr, #64]  @recupera lr
    ldr pc, pc_placeholder  @ Recupera pc

    @ Verifica para qual processo voltar
    @ldr r0, nproc
    @cmp r0, #0
    @ Inicia a recuperação de linhaA
    @adreq r12, linhaA  @ Carrega em r12 o endereço da linhaA
    @adrne r12, linhaB   @ Carrega em r12 o endereço de linhaB
    @add r12, r12, #4
    @ldmia r12!, {r1-r11} @ recupera os registradores r1-r11
    @mov r0, r12
    @ldmia r0!, {r12} 
    @mrs r1, cpsr
    @msr cpsr_ctl, #0b11010011   @ Supervisor
    @ldmia r0!, {sp, lr} @ r0 agora aponta para o valor de pc
    @msr cpsr, r1    @ retorna ao estado de IRQ
    @add r0, r0, #4 @ pula r0
    @ldmia r0!, {r1} @ guarda em r1 o cpsr
    @adreq r0, linhaA
    @adrne r0, linhaB
    @beq retornaA
@retornaB:
    @msr cpsr, r1    @ faz o cpsr voltar ao estado do processo em modo usuário
    @ldr r1, [r0, #4]    @ recupera o valor de r1
    @ldr r0, [r0, #60]   @ recupera o valor de r0
    @ldr pc, linhaB
@retornaA:
    @msr cpsr, r1    @ faz o cpsr voltar ao estado do processo em modo usuário
    @ldr r1, [r0, #4]    @ recupera o valor de r1
    @ldr r0, [r0, #60]   @ recupera o valor de r0
    @ldr pc, linhaA  @ Volta à execução
    @ Termina a recuperação da linhaA
    

@ Handler timer
@ Separar em handler.s
@ Depois fazer uma versão em c que tem um ponteiro para TIMEROX e atualiza o seu valor
@ Adicionar um .global handler_timer
@handler_timer:
@    stmfd sp!, {r0-r1, lr}
@    ldr r0, TIMEROX @ Referência para o registrador de clear
@    mov r1, #0x0
@    str r1, [r0] @ Ao escrever um valor arbitrário qualquer no registrador de clear, limpa a saída de interrupção.

    @ Aqui a gente inseriria um código sobre o que fazer quando o timer é acionado

@   ldmfd sp!, {r0-r1, lr} @ Mera continuação de retorno do do_irq_interrupt
@    mov pc, lr

@ CPSR_C: bits de controle 0-7. 
@   - Bits de modo (4-0),
@   - Bit de interrupção habilitada (6 para FIQ) e (7 para IRQ) (1 = desabilitado) 
@   - Bit de Thumb (5)
@ Inicializaçao do timer

@ Instrução com BIC:
@   BIC r0, r0, #0x80
@   =
@   AND r0, r0, 0b0111 1111
@   O que significa apenas os bits de controle do CPSR

@ TIMEROC: Control Register. Os bits [31:8] não são para modificar ou ler
@   Dos que restam:
@   7: Enable bit.
@   6: Timer mode. 1 = periodico. 0 = default (free running)
@   5: IntEnable. 1 = Interrupt enabled (default). 0 = Interrupt disabled
@   4: Ignorar. Reservado. Não modificar
@   3-2: Timer Pre. Prescale bits:
@       00 = 0 estágios de prescale, clock é dividido por 1 (default)
@       01 = 4 estágios de prescale, clock é dividido por 16
@       10 = 8 estágios de prescale, clock é dividido por 256
@       11 = Não definido. Não usar.
@   1: TimerSize. 0 = contador de 16 bits (default), 1 = contador de 32-bits
@   0: OneShot: 0 = wrapping mode (default), 1 = one-shot mode ???
timer_init:
    @ PRINT: Que modo e sp estamos usando aqui?

    ldr r0, INTEN   @ Referência para o registrador de enable de interrupaçõ 
    ldr r1, =0x10   @ Em binário: 0b0001 0000
    str r1, [r0]    @ O quinto bit (4) do vetor de interrupção é o dispositivo do timer. Então estamos habilitando as interrupções do timer
    ldr r0, TIMEROC @ Referência para o registrador de controle do timer
    ldr r1, [r0]    @ ??? Pensei que o bit (4) não fosse para mudar pq era reservado.
    mov r1, #0xA0   @ Em binário: 0b1010 0000
    str r1, [r0]    @ Habilita timer, default mode, habilita interrupç~ao, prescaler de 0, contador de 16 bits, wrapped mode
    ldr r0, TIMEROL @ Referêncai para o registrador de valor
    ldr r1, =0xffff   @ Em binário: 0b1111 1111
    str r1, [r0]    @ Fazer o timer contar a partir de 255 e ir decrementando

    mrs r0, cpsr
    bic r0, r0, #0x80 @ BIt Clear. Tipo a operação and mas com o complemento, Em binário: 0b1000 0000
    msr cpsr_c, r0  @ Estamos habilitando interrupções IRQ

    mov pc, lr      
@ Então depois de 255 clocks é para ocorrer uma interrupção...
@ A modificação de mitsuo:
@timer_init:
@ LDR r0, INTEN
@ LDR r1,=0x10 @bit 4 for timer 0 interrupt enable
@ STR r1,[r0]
@ LDR r0, TIMER0L
@ LDR r1, =0xffffff @setting timer value vai demorar mais até interromper
@ STR r1,[r0]
@ LDR r0, TIMER0C
@ MOV r1, #0xE0 @enable timer module 0b1110 0000 periódico? enfim, descobrir se é periódico com 0 ou 1
@ STR r1, [r0]
@ mrs r0, cpsr
@ bic r0,r0,#0x80
@ msr cpsr_c,r0 @enabling interrupts in the cpsr
@ mov pc, lr

@ main
main:
    bl timer_init @ Inicializar interrupções e o timer 0

@ Task A para printar 1
taskA:
    bl print1
    ldr r0, =0xFFFF
printA_loop:
    sub r0, r0, #1
    cmp r0, #0
    bne printA_loop

    b taskA

@ Task B para printar 2
taskB:
    bl print2
    ldr r0, =0xFFFF
printB_loop:
    sub r0, r0, #1
    cmp r0, #0
    bne printB_loop

    b taskB

@ Só para inicializar as pilhas
@ MODOS:
@   - User:         10000
@   - FIQ:          10001
@   - IRQ:          10010
@   - Supervisor:   10011
@   - Abort:        10111
@   - Undefined:    11011
@   - System:       11111
initialize_stacks:
    STMFD sp!,{r0, lr}
    LDR sp, =supervisor_stack_top
    MRS r0, cpsr
    MSR cpsr_ctl, #0b11011011 @ muda para modo undefined
    LDR sp, =undefined_stack_top
    MSR cpsr_ctl, #0b11010111 @ muda para modo abort
    LDR sp, =abort_stack_top
    MSR cpsr_ctl, #0b11011111 @ muda para modo system
    LDR sp, =system_stack_top
    MSR cpsr_ctl, #0b11010001 @ muda para modo FIQ
    LDR sp, =FIQ_stack_top
    MSR cpsr_ctl, #0b11010010 @ muda para modo IRQ
    LDR sp, =IRQ_stack_top
    MSR cpsr, r0
    LDMFD sp!,{r0,pc}


nproc: .word 0
num_processos: .word 2
linha_size: .word 68
register0_placeholder: .space 4
register1_placeholder: .space 4
register2_placeholder: .space 4
pc_placeholder: .space 4
linhaX: .word 0
linhaA: .space 68
linhaB: .word 0x13
linhaB_regs: .space 52
linhaB_pc: .word 0x1a8
linhaB_sp: .word taskB_stack_top
linhaB_lr: .space 4