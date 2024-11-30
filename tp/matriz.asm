%macro  printMatriz 3

section .data

    posx    db 00h

    msgCI    db '   ', 0
    simbolo_soldado db '|x|', 0
    simbolo_oficial db '|o|', 0
    msgSoldado      db "ingrese simbolo para  soldados ", 0
    msgOficial      db "ingrese smbolo para oficiales ", 0
    msgCD    db '| |', 0
    msgSL    db '',10,13,0
    msgDiv   db 10,13,'----------------------',10,13,0

    msgNum   db '%d  ', 0 
    msgPosX   db 'Ingrese posicion en X: ', 0

section .text
inicio:	

    mPuts msgSoldado
    mGets simbolo_soldado

    mPuts msgOficial
    mGets simbolo_oficial

    sub    rax, rax
    sub    rbx, rbx
    sub    rsi, rsi

ciclo:
    cmp     bl, %2;si es igual a 49
    je      termina

    mov     al, [%1 + rbx]
    and     al, 10000000b ;si la casilla es invalida
    cmp     al, 10000000b
    je      printCI

    mov     al, [%1 + rbx]
    and     al, 01000000b ; si tiene un soldado
    cmp     al, 01000000b
    je      printSol

    mov     al, [%1 + rbx]
    and     al, 00100000b ; si tiene un oficial
    cmp     al, 00100000b
    je      printOfi

    mov     rdi, msgCD
    mov     sil, [%1 + rbx]
    sub     rsp, 8
    call    printf
    add     rsp, 8

avanza:
    inc     bl
    inc     byte[posx]
    mov     cl, %3
    cmp     byte[posx], cl ;revisar
    je      saltoDeLinea

    jmp     ciclo

termina:

    mov     rbx, 0 

imprimir_numeros:
    cmp     rbx, 7
    je      fin 

    mov     rdi, msgNum
    mov     rsi, rbx
    sub     rsp, 8
    call    printf
    add     rsp, 8

    inc     rbx
    jmp     imprimir_numeros

    mov     rdi, msgSL
    sub     rsp, 8
    call    puts
    add     rsp, 8

    mov     rdi, msgPosX
    sub     rsp, 8
    call    printf
    add     rsp, 8

saltoDeLinea:
    mov     byte[posx], 00h
    mov     rdi, msgDiv
    sub     rsp, 8
    call    puts
    add     rsp, 8
    jmp     ciclo

printCI:
    mov     rdi, msgCI
    sub     rsp, 8
    call    printf
    add     rsp, 8
    jmp     avanza

printSol:
    mov     rdi, simbolo_soldado
    sub     rsp, 8
    call    printf
    add     rsp, 8
    jmp     avanza

printOfi:
    mov     rdi, simbolo_oficial
    sub     rsp, 8
    call    printf
    add     rsp, 8
    jmp     avanza

fin:
    sub     rax, rax

%endmacro
