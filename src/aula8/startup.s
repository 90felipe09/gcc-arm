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
  BL c_entry
  .word 0xFFFFFFFF
  B .

Undefined_Handler:
    LDR sp, =stack_top
    BL Undefined
    B .

undefined_stack_top: .word 0x2000
supervisor_stack_top: .word 0x1000