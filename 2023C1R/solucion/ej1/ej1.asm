global acumuladoPorCliente_asm
global en_blacklist_asm
global blacklistComercios_asm

extern malloc
extern realloc
extern strcmp

;########### SECCION DE TEXTO (PROGRAMA)
section .text
PAGO_MONTO EQU 0
PAGO_COMERCIO EQU 16
PAGO_CLIENTE EQU 16
PAGO_APROBADO EQU 17
PAGO_SIZE EQU 24

; rdi -> cantidadDePagos
; rsi -> arr_pagos

acumuladoPorCliente_asm:
	push rbp
	mov rbp, rsp ; alineado

	push r15
	push r14
	push r13
	push r12 ;alineado
.func:
	mov r15, rdi ; cantidadDePagos
	mov r14, rsi ; arr_pagos

	mov rdi, 4 * 10
	call malloc ; malloc(sizeof(uint32_t) * 10)

	; rax = pagosporcliente

	xor r13, r13
.setZero:
	mov dword [rax + r13 * 4], 0
	; for(uint8_t i = 0; i < 10; i++) {
     ;      pagosporcliente[i] = 0;
     ; }
.nextItSetZero:
	inc r13
	cmp r13, 10
	jne .setZero

	xor r13, r13
.loop:
	xor rsi, rsi ; 0
	add rsi, r13
	imul rsi, PAGO_SIZE ; i
	mov rdi, [r14 + rsi]; pago arr_pagos[i]

	cmp BYTE [rdi + PAGO_APROBADO], 0
	je .nextIt

	mov r12, [rdi + PAGO_CLIENTE] ; pago.cliente
	mov sil, BYTE [rdi + PAGO_MONTO] ; pago.monto
	movzx rsi, sil
	add [rax + r12 * 4], dword rsi ;  pagosporcliente[pago.cliente] += pago.monto
.nextIt:
	inc r13
	cmp r13, r15
	jne .loop

.epilogo:
	pop r12
	pop r13
	pop r14
	pop r15
	pop rbp
	ret

en_blacklist_asm:
	ret

blacklistComercios_asm:
	ret
