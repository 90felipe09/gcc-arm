	.file	"imprime5.c"
	.section	.rodata
	.align	2
.LC0:
	.ascii	"numero = %d\n\000"
	.align	2
.LC1:
	.ascii	"A = %d\n\000"
	.align	2
.LC2:
	.ascii	"B = %d\n\000"
	.align	2
.LC3:
	.ascii	"C = %d\n\000"
	.align	2
.LC4:
	.ascii	"D = %d\n\000"
	.text
	.align	2
	.global	imprime
	.type	imprime, %function
imprime:
	@ args = 4, pretend = 0, frame = 16
	@ frame_needed = 1, uses_anonymous_args = 0
	mov	ip, sp
	stmfd	sp!, {fp, ip, lr, pc}
	sub	fp, ip, #4
	sub	sp, sp, #20
	str	r0, [fp, #-16]
	str	r1, [fp, #-20]
	str	r2, [fp, #-24]
	str	r3, [fp, #-28]
	ldr	r3, [fp, #-16]
	cmp	r3, #0
	bge	.L2
	b	.L1
.L2:
	ldr	r0, .L3
	ldr	r1, [fp, #-16]
	bl	printf
	ldr	r0, .L3+4
	ldr	r1, [fp, #-20]
	bl	printf
	ldr	r0, .L3+8
	ldr	r1, [fp, #-24]
	bl	printf
	ldr	r0, .L3+12
	ldr	r1, [fp, #-28]
	bl	printf
	ldr	r0, .L3+16
	ldr	r1, [fp, #4]
	bl	printf
	ldr	r3, [fp, #-16]
	sub	r2, r3, #1
	ldr	r3, [fp, #4]
	str	r3, [sp, #0]
	mov	r0, r2
	ldr	r1, [fp, #-20]
	ldr	r2, [fp, #-24]
	ldr	r3, [fp, #-28]
	bl	imprime
.L1:
	sub	sp, fp, #12
	ldmfd	sp, {fp, sp, pc}
.L4:
	.align	2
.L3:
	.word	.LC0
	.word	.LC1
	.word	.LC2
	.word	.LC3
	.word	.LC4
	.size	imprime, .-imprime
	.align	2
	.global	main
	.type	main, %function
main:
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 1, uses_anonymous_args = 0
	mov	ip, sp
	stmfd	sp!, {fp, ip, lr, pc}
	sub	fp, ip, #4
	sub	sp, sp, #4
	mov	r3, #4
	str	r3, [sp, #0]
	mov	r0, #5
	mov	r1, #1
	mov	r2, #2
	mov	r3, #3
	bl	imprime
	mov	r0, r3
	ldmfd	sp, {r3, fp, sp, pc}
	.size	main, .-main
	.ident	"GCC: (GNU) 3.4.3"