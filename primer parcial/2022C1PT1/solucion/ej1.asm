extern malloc
extern free
extern fprintf
extern strClone

; aux
extern strCmp
extern strClone
extern strDelete
extern strPrint
extern strLen

global strArrayNew
global strArrayGetSize
global strArrayAddLast
global strArraySwap
global strArrayDelete


;SECCION OFFSETS Y TAMANIOS
ARRAY_OFFSET_SIZE EQU 0
ARRAY_OFFSET_CAPACITY EQU 1
ARRAY_OFFSET_DATA EQU 8
ARRAY_SIZE EQU 16

;########### SECCION DE DATOS
section .data

;########### SECCION DE TEXTO (PROGRAMA)
section .text

; str_array_t* strArrayNew(uint8_t capacity)
; capacity -> dil 8 bits
strArrayNew:
     .prologo:
          push rbp
          push r15
          push r14
          ; sub rsp, 8
          
          mov rbp, rsp 
          ; alineado

          xor r15, r15
          mov r15b, dil ; r15 = capacity

          xor rdi, rdi ; rdi = 0
          mov rdi, 16  ; rdi = 16

          call malloc  ; rax = str_array_t* newArray 
          mov r14, rax ; r14 = newArray/rax

          ; seteo size 0
          mov BYTE [r14], 0 ; newArray->size = 0;

          ; seteo capacity con rsi
          mov BYTE [r14 + ARRAY_OFFSET_CAPACITY], r15b; newArray->capacity = capacity;
          ; seteo data
          xor rax, rax
          mov al, 8
          mul r15b ; 8 bytes (char*) * capacity

          mov dil, al
          call malloc

          mov [r14 + ARRAY_OFFSET_DATA], rax ; guardo puntero en data

          mov rax, r14          
     .fin:
          ; add rsp, 8
          pop r14
          pop r15
          pop rbp

          ret

; uint8_t  strArrayGetSize(str_array_t* a) rdi
strArrayGetSize:
     .prologo:
          push rbp
          mov rbp, rsp ; alineado

          mov al, BYTE [rdi + ARRAY_OFFSET_SIZE]
     .fin: 
          pop rbp
          ret


; void  strArrayAddLast(str_array_t* a, char* data)
; a -> rdi
; data -> rsi
strArrayAddLast:
     .prologo:
          push rbp
          push r15
          push r14
          ; push r13
          ; sub rsp, 8
          
          mov rbp, rsp 
          ; alineado

          xor r15, r15 ; = 0

          mov r14, rdi ; r14 = rdi = a

          call strArrayGetSize ; rax = a->size
          mov r15b, al ; r15b = aSize

          cmp r15b, BYTE [r14 + ARRAY_OFFSET_CAPACITY]
          je .fin ; if(aSize == a->capacity) return

          inc BYTE [r14 + ARRAY_OFFSET_SIZE] ; a->size++

          mov rdi, rsi ; paso data a rdi
          call strClone

          mov rsi, [r14 + ARRAY_OFFSET_DATA] 
          mov [rsi + r15 * 8], rax
     .fin:
          ; add rsp, 8
          ; pop r13
          pop r14
          pop r15
          pop rbp

          ret

; void  strArraySwap(str_array_t* a, uint8_t i, uint8_t j)
; a -> rdi
; i -> rsi
; j -> rdx
strArraySwap:
     .prologo:
          push rbp
          push r15
          push r14
          ; push r13
          ; sub rsp, 8
          
          mov rbp, rsp 
          ; alineado

          mov rcx, [rdi + ARRAY_OFFSET_DATA] ; obtengo arreglo de strings 

          mov r14, [rcx + rsi * 8] ;toSwitch = a->data[i];
          mov r15, [rcx + rdx * 8] ;toSwitch2 = a->data[j];

          mov [rcx + rsi * 8], r15 ; a->data[i] = toSwitch2;
          mov [rcx + rdx * 8], r14 ; a->data[j] = toSwitch;
     .fin:
          ; add rsp, 8
          ; pop r13
          pop r14
          pop r15
          pop rbp

          ret

; void  strArrayDelete(str_array_t* a) 
; a -> rdi
strArrayDelete:
     .prologo:
          push rbp
          push r15
          push r14
          push r13
          push r12
          
          mov rbp, rsp 
          ; alineado

          xor r14, r14
          xor r13, r13

          mov r15, rdi ; copio a

          call strArrayGetSize
          mov r14b, al ; r14b = a->size

          .ciclo:
               cmp r13b, r14b 
               je .fin ; i < a->size

               mov rsi, [r15 + ARRAY_OFFSET_DATA]; a->data
               mov rdi, [rsi + 8 * r13] ; a->data[i]
               call free ; free(a->data[i])

               inc r13 ; i ++

               jmp .ciclo ; repetimos
     .fin:
          mov rdi, [r15 + ARRAY_OFFSET_DATA]
          call free ; free(a->data)

          mov rdi, r15 ; free(a);
          call free

          pop r12
          pop r13
          pop r14
          pop r15
          pop rbp

          ret


