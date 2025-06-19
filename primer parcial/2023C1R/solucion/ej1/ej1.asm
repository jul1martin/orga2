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

	sub rsp, 16 ; alineado

	push r15
	push r14 ; alineado

	push r13
	push r12 ; alineado
	
	push rbx 
	sub rsp, 8; alineado

	.func:
		mov r15, rdi ; cantidad_pagos
		mov r14, rsi ; arr_pagos
		mov r13, rdx ; arr_comercios

		movzx rcx, cl ; extiendo size_comercios
		mov r12, rcx ; size_comercios

		xor rbx, rbx ; pagos = NULL

		mov BYTE [rbp - 8], 0 ; i
		mov BYTE [rbp - 16], 0 ; index pagos
	.loop:
		mov sil, BYTE [rbp - 8]
		movzx rsi, sil
		imul rsi, PAGO_SIZE ; pago[i] 

		mov rdi, [r14 + rsi + PAGO_COMERCIO] ; pago[i].comercio
		mov rsi, r13 ; arr_comercios
		mov rdx, r12 ; size_comercios
		
		call en_blacklist_asm
		; en_blacklist(pago.comercio, arr_comercios, size_comercios) == true

		cmp rax, 0 ; en_blacklist == true
		je .nextIt ; sigo

		xor rdi, rdi ; = 0
		mov rdi, rbx ; = pagos actual
		
		mov sil, BYTE [rbp - 16] ; index pagos
		movzx rsi, sil ; extiendo
		inc rsi ; (index_pagos + 1)
		imul rsi, 8 ; sizeof(pago_t*) * (index_pagos + 1)

		call realloc

		xor rbx, rbx ; limpio
		mov rbx, rax ; pagos = realloc

		mov dil, BYTE [rbp - 16] ; index_pagos
		movzx rdi, dil
		mov sil, BYTE [rbp - 8]  ; i
		movzx rsi, sil
		imul rsi, PAGO_SIZE
		add rsi, r14 ; offset &arr_pagos[i]

		mov [rbx + rdi * 8], rsi ; pagos[index_pagos] = (pago_t*) &arr_pagos[i]; 

		inc BYTE [rbp - 16] ; index_pagos++
	.nextIt:
		inc BYTE [rbp - 8] ; i++
		cmp BYTE [rbp - 8], r15b ; condicion for
		jne .loop

	.epilogo:
		mov rax, rbx

		add rsp, 8
		pop rbx

		pop r12
		pop r13

		pop r14
		pop r15

		add rsp, 16

		pop rbp

		ret
