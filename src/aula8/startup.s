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

