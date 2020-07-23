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


.section INTERRUPT_VECTOR, "x"
.global _Reset
_Reset:
  B Reset_Handler /* Reset */
  B Undefined_Handler /* Undefined */
  B . /* SWI */
  B . /* Prefetch Abort */
  B . /* Data Abort */
  B . /* reserved */
  B . /* IRQ */
  B . /* FIQ */
 
Reset_Handler:
  LDR sp, =supervisor_stack_top
  MRS r0, cpsr
  MSR cpsr_ctl, #0b11011011 @ muda para modo undefined
  LDR sp, =undefined_stack_top
  MSR cpsr, r0
  .word 0xFFFFFFFF
  BL c_entry
  MRS r0, cpsr
  MSR cpsr_ctl, #0b11010000
  MSR cpsr, r0
  B .

Undefined_Handler:
  STMFD sp!,{r0-r12,lr}
  BL Undefined
  LDMFD sp!,{r0-r12,pc}^ 

