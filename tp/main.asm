%include	"matriz.asm"
%include	"macros.asm"
extern printf,system
global main

section	.data

	matriz		db      80h,80h,4Ch,4Eh,46h,80h,80h
                        db      80h,80h,4Ch,4Eh,46h,80h,80h
                        db      4Ch,4Ch,4Ch,4Eh,46h,46h,46h
                        db      4Ch,4Ch,4Ch,4Eh,46h,46h,46h
                        db      50h,50h,0Ch,0Eh,06h,41h,41h ;cambiar
                        db      80h,80h,0Ch,0Eh,06h,80h,80h ;cambiar
                        db      80h,80h,00h,00h,00h,80h,80h

	tamanio		db	31h
	longitud	db	07h
	msgVer		db	"%hhi,%hhi",10,13,0
	cmd_clear	db	"clear",0

section	.bss
	posicionx	resb	1
	posiciony	resb	1

section	.text
main:
	personalizar
    rotarMatriz matriz
    reemplazarSimbolos matriz
        printMatriz     matriz, [tamanio], [longitud]
	ganaronSoldados	matriz
	cmp	al,09h
	je	finMain

	ingreso		posicionx, posiciony, matriz
	mov		rdi,msgVer
	mov		sil,[posicionx]
	mov		dl,[posiciony]
	sub		rsp,8
	call		printf
	add		rsp,8

	mov	rdi,cmd_clear
	sub	rsp,8
	call	system
	add	rsp,8

	jmp	main
finMain:
	ret
