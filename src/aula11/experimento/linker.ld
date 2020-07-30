ENTRY(_start)
SECTIONS{
    . = 0x0;
     .text : {
 *(.text)
 }
    .data : { *(.data) }
    .bss : { *(.bss COMMON) }
    . = ALIGN(8);
    . = . + 0x1000; /* 4kB of stack memory */
    system_stack_top = .;
    . = . + 0x1000; /* 4kB of stack memory */
    undefined_stack_top = .;
    . = . + 0x1000; /* 4kB of stack memory */
    abort_stack_top = .;
    . = . + 0x1000; /* 4kB of stack memory */
    supervisor_stack_top = .;
    . = . + 0x1000; /* 4kB of stack memory */
    IRQ_stack_top = .;
    . = . + 0x1000; /* 4kB of stack memory */
    FIQ_stack_top = .;
    . = . + 0x1000; /* 4kB of stack memory */
    taskA_stack_top = .;
    . = . + 0x1000; /* 4kB of stack memory */
    taskB_stack_top = .;
    . = . + 0x1000; /* 4kB of stack memory */
    taskC_stack_top = .;
}