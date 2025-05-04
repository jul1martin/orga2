global acumuladoPorCliente_asm
global en_blacklist_asm
global blacklistComercios_asm

extern malloc
extern realloc
extern strcmp

;########### SECCION DE TEXTO (PROGRAMA)
section .text
PAGO_MONTO EQU 0
PAGO_COMERCIO EQU 8
PAGO_CLIENTE EQU 16
PAGO_APROBADO EQU 17
PAGO_SIZE EQU 24

; rdi -> cantidadDePagos
; rsi -> arr_pagos

acumuladoPorCliente_asm:
	push rbp
	mov rbp, rsp ; alineado

	push r15
	push r14 ; alineado

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

		xor r13, r13 ; 
	.loop:
		mov rsi, r13
		imul rsi, PAGO_SIZE
		; add rsi, r14

		; mov rdi, rsi; pago arr_pagos[i]

		cmp BYTE [r14 + rsi + PAGO_APROBADO], 0
		je .nextIt

		mov r12b, BYTE [r14 + rsi + PAGO_CLIENTE] ; pago.cliente
		movzx r12, r12b ; extiendo clientes

		mov dil, BYTE [r14 + rsi + PAGO_MONTO] ; pago.monto
		movzx edi, dil
		add [rax + r12 * 4], edi ;  pagosporcliente[pago.cliente] += pago.monto
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

; comercio -> rdi
; lista_comercios -> rsi 
; n -> rdx
en_blacklist_asm:
	push rbp
	mov rbp, rsp ; alineado

	push r15
	push r14 ; alineado

	push r13
	push r12 ;alineado

	.func:
		mov r15, rdi ; comercio
		mov r14, rsi ; lista_comercios
		mov r13, rdx ; n

		xor rax, rax ; = 0
		xor r12, r12 ; i = 0
	.loop:
		mov rdi, r15
		mov rsi, [r14 + r12 * 8]
		call strcmp

		cmp rax, 0 ; if(strcmp(comercio, ncomercio) == 0)
		je .nextIt ; return 1
	.returnTrue:
		mov rax, 1
		jmp .epilogo

	.nextIt:
		inc r12
		cmp r12, r13 ; condicion for
		jne .loop

	.epilogo:
		pop r12
		pop r13

		pop r14
		pop r15

		pop rbp
		ret

; cantidad_pagos->dil
; arr_pagos->rsi
; arr_comercios->rdx
; size_comercios->cl rcx

blacklistComercios_asm:
	push rbp
	mov rbp, rsp ; alineado

	push r15
	push r14 ; alineado

	push r13
	push r12 ; alineado
	
	push rbx 
	sub rsp, 8; alineado

	sub rsp, 16 ; alineado

	.func:
		mov r15, rdi ; cantidad_pagos
		mov r14, rsi ; arr_pagos
		mov r13, rdx ; arr_comercios

		movzx rcx, cl ; extiendo size_comercios
		mov r12, rcx ; size_comercios

		xor rbx, rbx ; pagos = NULL

		mov qword [rbp - 0x40], 0 ; i
		mov qword [rbp - 0x48], 0 ; index pagos
	.loop:
		xor rsi, rsi
		mov rsi, qword [rbp - 0x40]
		imul rsi, PAGO_SIZE

		mov rdi, [r14 + rsi + PAGO_COMERCIO] 
		mov rsi, r13 ; arr_comercios
		mov rdx, r12 ; size_comercios
		
		call en_blacklist_asm
		; en_blacklist(pago.comercio, arr_comercios, size_comercios) == true

		cmp rax, 0 ; en_blacklist == true
		je .nextIt ; sigo

		mov rdi, rbx
		
		mov sil, BYTE [rbp - 0x48] ; index pagos
		movzx rsi, sil
		inc rsi
		imul rsi, PAGO_SIZE ; PAGO_SIZE + index_pagos + 1
		
		call realloc

		mov rbx, rax

		mov rdi, qword [rbp - 0x48] ; index_pagos
		mov rsi, qword [rbp - 0x40]  ; i
		imul rsi, 8
		add rsi, r14

		mov [rbx + rdi * 8], rsi 

		inc BYTE [rbp - 0x48] ; index_pagos++
	.nextIt:
		inc qword [rbp - 0x40] ; i++
		cmp qword [rbp - 0x40], r15 ; condicion for
		jne .loop

	.epilogo:
		mov rax, rbx
		add rsp, 16

		add rsp, 8
		pop rbx

		pop r12
		pop r13

		pop r14
		pop r15

		pop rbp

		ret
