; /** defines bool y puntero **/
%define NULL 0
%define TRUE 1
%define FALSE 0

extern malloc
; extern strlen
; extern strcpy
extern free
extern str_concat

section .data

section .text


NODE_NEXT EQU 0
NODE_PREVIOUS EQU 8
NODE_TYPE EQU 16
NODE_HASH EQU 24 
NODE_SIZE EQU 32

LIST_FIRST EQU 0
LIST_LAST EQU 8
LIST_SIZE EQU 16

global string_proc_list_create_asm
global string_proc_node_create_asm
global string_proc_list_add_node_asm
global string_proc_list_concat_asm


; FUNCIONES auxiliares que pueden llegar a necesitar:


string_proc_list_create_asm:
     push rbp
     mov rbp, rsp

     mov rdi, LIST_SIZE
     call malloc ; rax = nuevo = malloc(16)

     xor rdi, rdi ; NULL

     mov [rax + LIST_FIRST], rdi ; ->first = NULL
     mov [rax + LIST_LAST], rdi ; ->last = NULL

     pop rbp

     ret ; return nuevo

; type -> rdi
; hash -> sil -> rsi
string_proc_node_create_asm:
     push rbp
     mov rbp, rsp ; alineado

     push r15
     push r14 ; alineado

     movzx rdi, dil ; 1 byte limpio

     mov r14, rdi ; type
     mov r15, rsi ; hash

     mov rdi, NODE_SIZE
     call malloc ; rax = nuevo = malloc(32)

     mov [rax + NODE_TYPE], r14 ; ->type = type
     mov [rax + NODE_HASH], r15 ; ->hash = hash

     xor rdi, rdi ; NULL

     mov [rax + NODE_NEXT], rdi ; ->next = NULL
     mov [rax + NODE_PREVIOUS], rdi ; ->previous = NULL

     pop r14
     pop r15
     pop rbp
     ret ; return nuevo

; list -> rdi
; type -> sil
; hash -> rdx
string_proc_list_add_node_asm:
     push rbp
     mov rbp, rsp ; alineado

     push r15
     push r14 ; alineado

     push r13 
     push r12 ; alineado

     movzx rsi, sil ; 1 byte limpio
     
     mov r13, rdi ; list
     mov r14, rsi ; type
     mov r15, rdx ; hash

     mov rdi, rsi 
     mov rsi, rdx

     call string_proc_node_create_asm ; rax = nuevo = string_proc_node_create(type,hash);

     xor rdi, rdi

     cmp [r13 + LIST_LAST], rdi
     jne .lastIsNotEmpty

     .continueIf:
          mov [r13 + LIST_LAST], rax  ; list->last = nuevo

          xor rdi, rdi ; null

          cmp [r13 + LIST_FIRST], rdi
          jne .epilogo
     .firstIsEmpty:
          mov [r13 + LIST_FIRST], rax ; list->last

          jmp .epilogo
     .lastIsNotEmpty:
          mov r12, [r13 + LIST_LAST] ; list->last
          mov [r12 + NODE_NEXT], rax ;list->last->next
          mov [rax + NODE_PREVIOUS], r12

          jmp .continueIf
     .epilogo:
          pop r12
          pop r13

          pop r14
          pop r15

          pop rbp
          ret ; return nuevo

; list -> rdi
; type -> sil
; hash -> rdx
string_proc_list_concat_asm:
     .prologo:
          push rbp
          mov rbp, rsp ; alineado

          push r15
          push r14 ; alineado

          push r13 
          push r12 ; alineado

          push rbx
          sub rsp, 8 ; alineado

          movzx rsi, sil ; 1 byte limpio
          
          mov r13, rdi ; list
          mov r14, rsi ; type
          mov r15, rdx ; hash

          ; mov rdi, r15 ; hash
          ; call strlen
          ; inc rax ; strlen(hash) + 1

          mov rdi, 1
          call malloc ; malloc(strlen(hash) + 1)

          mov BYTE[RAX], 0

          mov r12, rax ; old
          mov rdi, rax ; rdi = resultado
          mov rsi, r15 ; rsi = hash
          call str_concat ; strcpy(resultado, hash)
          ; rax = resultado
          
          mov rbx, rax ; resultado

          mov rdi, r12
          call free

          mov r12, [r13] ; actual = list->first
     .loop:
          cmp [r12 + NODE_TYPE], r14
          jne .nextIteration ; actual->type == type

          mov rdi, rbx ; resultado
          mov rsi, [r12 + NODE_HASH] ; actual->hash

          call str_concat ; str_concat(resultado,actual->hash)

          mov rdi, rbx ; old_resultado
          mov rbx, rax ; nuevo_resultado = str_concat(resultado,actual->hash)

          call free ; free(resultado)
     .nextIteration:
          mov r15, [r12 + NODE_NEXT] ; actual = actual->next
          mov r12, r15

          cmp r12, 0
          jne .loop ; while(actual != NULL)
     .epilogo:
          mov rax, rbx ; return resultado

          add rsp, 8
          pop rbx

          pop r12
          pop r13

          pop r14
          pop r15

          pop rbp
          ret ; return nuevo
