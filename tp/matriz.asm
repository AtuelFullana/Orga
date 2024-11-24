extern	printf, puts

%macro  printMatriz 3

section	.data

	posx		db	00h

	msgCI           db      '   ', 0
        msgCS           db      '|x|', 0
        msgCO           db      '|o|', 0
        msgCD           db      '| |', 0
        msgSL           db      '',10,13,0
        msgDiv          db      10,13,'----------------------',10,13,0

section .text
inicio:

	sub	rax,rax
	sub	rbx,rbx
	sub	rsi,rsi
ciclo:
	cmp	bl, %2 ; si es igual a 49
	je	termina

	mov	al, [%1 + rbx]
	and	al,10000000b ; si la casilla es invalida
	cmp	al,10000000b
	je	printCI

	mov	al,[%1 + rbx]
	and	al,01000000b ; si tiene un soldado
	cmp	al,01000000b
	je	printSol

	mov	al,[%1 + rbx]
	and	al,00100000b ; si tiene un oficial
	cmp	al,00100000b
	je	printOfi

	mov     rdi, msgCD
        mov     sil,[%1 + rbx]
        sub     rsp, 8
        call    printf
        add     rsp, 8

avanza:
	inc	bl

	inc	byte[posx]
	mov	cl,%3
	cmp	byte[posx],cl ;revisar
	je	saltoDeLinea

	jmp	ciclo

termina:
	jmp 	fin

saltoDeLinea:
	mov	byte[posx],00h

	mov	rdi, msgDiv
	sub	rsp, 8
	call	puts
	add	rsp, 8
	jmp	ciclo


printCI:
	mov	rdi, msgCI
	sub	rsp, 8
	call	printf
	add	rsp, 8

	jmp	avanza
printSol:
	mov     rdi, msgCS
        sub     rsp, 8
        call    printf
        add     rsp, 8

        jmp     avanza


printOfi:
	mov     rdi, msgCO
        sub     rsp, 8
        call    printf
        add     rsp, 8

        jmp     avanza

fin:
	sub	rax,rax

%endmacro
