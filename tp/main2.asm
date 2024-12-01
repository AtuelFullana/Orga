%include        "matriz.asm"
%include        "mov.asm"
extern printf,system
global main

%macro mGets 1
        mov     rdi, %1
        sub     rsp, 8
        call    gets
        add     rsp, 8
%endmacro

%macro mPuts 1
        mov     rdi, %1
        sub     rsp, 8
        call    puts
        add     rsp, 8
%endmacro

%macro mSscanf 3
        mov     rdi, %1
        mov     rsi, %2
        mov     rdx, %3
        sub     rsp, 8
        call    sscanf
        add     rsp, 8

        cmp     rax, 1
        jl      error
%endmacro

%macro mBorrarPartida 1
    mov     rdi, %1
    sub     rsp, 8
    call    system
    add     rsp, 8
%endmacro

%macro	ingresoPosicion 3
	mPuts	msgPosicion
	mGets	posicion

	;verificar si quiere cambiar de jugador
	mStrcmp	posicion, cambiar
	cmp	rax, 0
	je	pedirEntrada

	;verificar si es el de salida
	mStrcmp	posicion, salida
	cmp	rax, 0
	je	terminar_programa

	;guardo en variables separadas los indices de la posicion
	mSscanf	posicion, mFormat, %1, %2
	cmp	rax,1
	jl	%3
%endmacro
	
%macro	validarCasillaLimites 3
	;validar que este entre 1 y 7
    validarLimite	[%1], %3
	validarLimite	[%2], %3

	;casillaInvalida
	indice	%1, %2
    mov     al, [matriz + rbx]
    and     al,10000000b ; si la casilla es invalida
    cmp     al,10000000b
    je      %3
	;dependiendo desde donde se llame va a un error
%endmacro

%macro	validarLimite 2
	mov     al, %1
    cmp     al, 1
    jl      %2
    cmp     al, 7
    jg      %2
%endmacro

%macro casillaOcupada 4
	indice	%1, %2
	mov	al, [matriz + rbx]
	and	al, %3
	cmp	al, %3; si esta ocupada por el que tiene el turno
	jne	%4
%endmacro

%macro	casillaLibre	2
	indice	%1, %2
	mov	al, [matriz + rbx]
	and	al, 40h
	cmp	al, 40h
	je	errorNoLibre

	mov al, [matriz + rbx]
    and al, 20h
    cmp al, 20h
    je  errorNoLibre
%endmacro

%macro	validarCasillaAdyacente 0
	;verifico si la direccion de llegada es la misma que de salida
	calcularDiferencia
	mov	al, [difx]
	cmp al, 00h
	jne	.diferencia
	mov al, [dify]
	cmp al, 00h
	je	errorRangoDir
.diferencia:
	validarDiferncia	[difx]
	validarDiferncia	[dify]
%endmacro

%macro validarDiferncia 1
	mov al, %1			; dx - x
	inc	al				; dx - x + 1
	jl	errorRangoDir	; dx - x + 1 < 0

	mov al, %1			; dx - x
	dec	al				; dx - x - 1
	jg	errorRangoDir	; dx - x - 1 > 0
%endmacro

%macro calcularDiferencia	0
	calDif	[posicionx],[posicionxDir], [difx]
	calDif  [posiciony],[posicionyDir], [dify]
%endmacro

%macro calDif 3
	mov	al, %2
	sub	al, %1
	mov %3, al
%endmacro

%macro verificarMov 0
	cmp byte[dify], -1 ; si sube sale
	je	errorRangoDir
der:
	cmp byte[dify], 0 
	jne diagDer
	cmp byte[difx], 1 ; derecha
	je	movDer

izq:
	cmp	byte[difx], -1 ; izquierda ..... puede que no sea necesario ya que no puede tener difx = 0 y dify = 0 al mismo tiempo
	je movIzq

diagDer:
	cmp byte[difx], 1 ; diagonal derecha
	je movDDer
diagIzq:
	cmp byte[difx], -1 ; diagonal izquierda
	je movDIzq

aba:
	cmp byte[difx], 0 ; abajo ....... se supone que es la unica condicion que queda, asi que no es necesario comparar
	je movAbajo
movAbajo:
	validarMovCas	04h
	jmp continuar
movDer:
	validarMovCas	10h
	jmp continuar
movDDer:
	validarMovCas	08h
	jmp continuar
movIzq:
	validarMovCas	01h
	jmp continuar
movDIzq:
	validarMovCas	02h
	jmp continuar ;se obviar esta linea
continuar:
	;ya quiero que se acabe esto
	;si me olvido de borrar este comentario no importa xd
	;si alguien lo lee lo tiene que borrar
%endmacro

%macro validarMovCas 1
	indice	posicionx, posiciony
	mov al, [matriz + rbx]
	and al, %1
	cmp	al, %1
	jne	errorRangoDir
%endmacro

%macro mover 4
	indice %1, %2
	and	byte[matriz + rbx], 1Fh
	indice %3, %4
	mov al, [turno]
	or	byte[matriz + rbx], al
%endmacro

%macro cambiarTurno 0
	cmp byte[turno], 40h
	je	.cambTurnOfi
.cambTurnSol:
	mov byte[turno], 40h
	jmp .finTurno
.cambTurnOfi:
	mov byte[turno], 20h
.finTurno:
	;xd tengo que mejorar estas cosas
%endmacro

%macro validarSalto 0
	;sacado de chatgpt
	;no quiero pensar mas xd
	mov al, [difx]    ; Cargar dx en rax
    mov bl, [dify]    ; Cargar dy en rbx

    ; Calcular valor absoluto de dx (|dx|)
    test al, al    ; Probar si rax < 0
    jge abs_dx_done  ; Si rax >= 0, no hacer nada
    neg al          ; Si rax < 0, convertir a positivo
abs_dx_done:

    ; Calcular valor absoluto de dy (|dy|)
    test bl, bl    ; Probar si rbx < 0
    jge abs_dy_done  ; Si rbx >= 0, no hacer nada
    neg bl          ; Si rbx < 0, convertir a positivo
abs_dy_done:

    ; Comprobar la primera condición: (|dx| == 2 && |dy| == 0)
    cmp al, 2       ; Comparar |dx| con 2
    jne cond2  ; Si |dx| != 2, ir a la segunda condición
    cmp bl, 0       ; Comparar |dy| con 0
    je movSaltar ; Si ambas condiciones se cumplen, es válido

cond2:
    ; Comprobar la segunda condición: (|dx| == 0 && |dy| == 2)
    cmp al, 0       ; Comparar |dx| con 0
    jne cond3  ; Si |dx| != 0, ir a la tercera condición
    cmp bl, 2       ; Comparar |dy| con 2
    je movSaltar ; Si ambas condiciones se cumplen, es válido

cond3:
    ; Comprobar la tercera condición: (|dx| == 2 && |dy| == 2)
    cmp al, 2       ; Comparar |dx| con 2
    jne movOficial ; Si |dx| != 2, si no se cumple ninguna condicion puede ser un movimiento normal
    cmp bl, 2       ; Comparar |dy| con 2
    je movSaltar    ; Si ambas condiciones se cumplen, es válido

%endmacro

%macro casillaEnMedioOcupada 0
	casillaEnMedio [difx],saltoX, [posicionx]
	casillaEnMedio [dify],saltoY, [posiciony]
	casillaOcupada saltoX, saltoY, 40h, errorRangoDir
%endmacro

%macro casillaEnMedio 3
	sub rax,rax
	mov al,%1 ; dx

	mov bl, 02h
	idiv bl ; dx/2
	add al, %3 ; dx/2 + x
	mov byte[%2],al
%endmacro

%macro captura 2
	indice %1, %2
	and	byte[matriz + rbx], 1Fh
%endmacro

section .data

        matriz  db      80h,80h,4Ch,4Eh,46h,80h,80h
                db      80h,80h,4Ch,4Eh,46h,80h,80h
                db      4Ch,4Ch,4Ch,4Eh,46h,46h,46h
                db      4Ch,4Ch,4Ch,4Eh,46h,46h,46h
                db      50h,50h,0Ch,0Eh,06h,41h,41h ;cambiar
                db      80h,80h,2Ch,0Eh,26h,80h,80h ;cambiar
                db      80h,80h,00h,00h,00h,80h,80h


        formatoMsg                  db 		"%s", 0
        formatoMatriz               db      "%c", 0
        formatoSoldadosCapturados   db 		"Soldados capturados: %hhi",10, 0
        formato                     db 		"%hhi", 0

	tamanio						db		31h
	longitud					db		07h
	
	msgPosicion		    db          "Ingrese la posicion: x y",0
    msgDespedida                db      "Gracias por jugar", 10, 0
    
    saltoDeLineas                db "",10,0

	simbolo1			db		"O",0
	simbolo2			db		"6",0
	simbolo3			db		"0",0	
	simbolo4			db		"X",0
	simbolo5			db		"5",0
    turnoActual         		db 		"X",0
    caracterSoldado     		db 		"X",0
    caracterOficial     		db 		"O",0
	
	nombreArchivo       		db	 	"partida.txt", 0
        modoLectura         		db	 	"r", 0
        modoEscritura               dq      0666 
        
        matrizLen equ $ - matriz          ; Longitud de la matriz
        
        hexChars db "0123456789ABCDEF", 0 ; Caracteres hexadecimales

        orientacionMatriz   	db 		"N",0
        msgVer			db		"%hhi,%hhi",10,13,0
        juegoGanado             db      "N",0
        cmd_borrar_partida      db      "rm -rf partida.txt", 0
        cmd_clear					db		"clear",0


        turno	db      40h
	difx	db      0
	dify 	db      0
	saltoX	db      0
	saltoY	db      0

        msgGuardarPartida   db  "Quiere guardar la partida? S/N",0
        msgGuardado     db      "¡¡¡La partida se guardo correctamente!!!",0


        msgErrorPos     db      "Posicion invalida",10,13,0
        msgPsc          db      "Posicion ingresada: %hhi - %hhi",10,13,0
        mFormat         db      "%hhi %hhi", 0
        mVer            db      "%hhi",10,13,0
        salida		db		"quit", 0
        cambiar		db		"camb", 0
        msgErrSscanf    db      "Ingreso Invalido",0
        msgPosicionSig	db		"Ingrese la casilla de llegada: x y",0
        msgErrNoLibre	db		"La casilla esta ocupada", 0


section .bss
    buffer resb 10                   ; Buffer para el valor de fila1
    guardado        resb    1

    posicion        resb    1
    posicionx       resb    1
    posiciony       resb    1
    posicionxDir	resb	1
    posicionyDir	resb	1


section	.text
main:
printMatriz     matriz, [tamanio], [longitud]
	mPuts	msgGuardarPartida
	mGets	guardado
	mov     al, [guardado]
    cmp     al, 'S'
    je      terminar_programa
	;preguto si termino

pedirEntrada:
	ingresoPosicion 		posicionx, posiciony, errorSscanfEntrada ;guardo la entrada
	validarCasillaLimites	posicionx, posiciony, errorRangoEntrada ;verifico los limites
	casillaOcupada			posicionx, posiciony, byte[turno], errorRangoEntrada	;verifico si hay un jugador valido

pedirDir:
	mPuts	msgPosicionSig
	ingresoPosicion 		posicionxDir, posicionyDir, errorSscanfDir ;guardo casilla de llegada
	validarCasillaLimites	posicionxDir, posicionyDir, errorRangoDir ;verifico los limites
	casillaLibre			posicionxDir, posicionyDir ; verifico que la casilla destino este libre
	;pregunto el turno
	cmp	byte[turno],40h
	jne	moverOficial
moverSoldado:
	validarCasillaAdyacente	;verifica que este a una casilla de distancia
	verificarMov
	mover 					posicionx, posiciony, posicionxDir, posicionyDir ; ya casi se acaba esto
	cambiarTurno
	jmp main
moverOficial:
	validarSalto ;verifica que este a dos casillas
movSaltar:
	casillaEnMedioOcupada ; verifica que haya un soldado en medio
	captura 				saltoX, saltoY; quita la pieza en medio
	jmp movConfirmado
movOficial:
	validarCasillaAdyacente
movConfirmado:
	mover 					posicionx, posiciony, posicionxDir, posicionyDir
	cambiarTurno
	jmp main
terminar_programa:
    mPuts msgDespedida

    ; Abrir/crear el archivo
    mov rax, 2                    ; syscall: open
    lea rdi, [nombreArchivo]      ; Dirección del nombre del archivo
    mov rsi, 2 | 64               ; Flags: O_WRONLY | O_CREAT
    mov rdx, modoEscritura        ; Permisos: modoEscritura
    syscall
    mov r8, rax                   ; Guardar el descriptor de archivo

    ; Convertir la matriz a texto hexadecimal
    lea rsi, [matriz]
    lea rdi, [buffer]
    mov rcx, matrizLen
    call convertir_a_hex

    ; Escribir la matriz convertida en el archivo
    mov rax, 1                    ; syscall: write
    mov rdi, r8                   ; Descriptor de archivo
    lea rsi, [buffer]             ; Dirección del buffer
    sub rdx, rdx
    add rdx, matrizLen + 28       ; Longitud del texto (+ saltos de línea)
    syscall

    ; Escribir turnoActual con un salto de línea
    mov byte [buffer], 0Ah          ; Salto de línea antes de turnoActual
    mov al, byte [turnoActual]      ; Primer símbolo (turnoActual)
    mov byte [buffer + 1], al
    mov byte [buffer + 2], 0Ah      ; Salto de línea después de turnoActual

    ; Agregar los 5 símbolos al buffer
    mov al, byte [simbolo1]
    mov byte [buffer + 3], al
    mov byte [buffer + 4], 0Ah      ; Salto de línea después de simbolo1

    mov al, byte [simbolo2]
    mov byte [buffer + 5], al
    mov byte [buffer + 6], 0Ah      ; Salto de línea después de simbolo2

    mov al, byte [simbolo3]
    mov byte [buffer + 7], al
    mov byte [buffer + 8], 0Ah      ; Salto de línea después de simbolo3

    mov al, byte [simbolo4]
    mov byte [buffer + 9], al
    mov byte [buffer + 10], 0Ah     ; Salto de línea después de simbolo4

    mov al, byte [simbolo5]
    mov byte [buffer + 11], al
    mov byte [buffer + 12], 0Ah     ; Salto de línea después de simbolo5

    ; Escribir el buffer completo
    lea rsi, [buffer]
    mov rax, 1                      ; syscall: write
    mov rdi, r8                     ; Descriptor de archivo
    mov rdx, 13                     ; Longitud del texto: 13 bytes (1 por símbolo + 1 salto de línea cada uno)
    syscall


convertir_a_hex:
    push rbx
    mov rbx, rdi
    xor rdx, rdx

convertir_loop:
    mov al, byte [rsi]
    shr al, 4
    and al, 0Fh
    mov bl, byte [hexChars + rax]
    mov [rdi], bl
    inc rdi

    mov al, byte [rsi]
    and al, 0Fh
    mov bl, byte [hexChars + rax]
    mov [rdi], bl
    inc rdi

    mov byte [rdi], 'h'               ; Escribir la h
    inc rdi
    cmp byte [rsi], 0Ah
    je salto_de_linea


salto_de_linea:
    inc rsi
    inc rdx

    cmp rdx, 7
    jne no_nueva_linea
    mov byte [rdi], 0Ah
    inc rdi
    xor rdx, rdx

no_nueva_linea:
    mov byte [rdi], ','               ; Escribir la ','
    inc rdi
    loop convertir_loop

    pop rbx
    ret


errorSscanfEntrada:
	mPuts	msgErrSscanf
	jmp	pedirEntrada
errorRangoEntrada:
	mPuts	msgErrorPos
	jmp	pedirEntrada

errorSscanfDir:
	mPuts	msgErrSscanf
	jmp	pedirDir
errorRangoDir:
	mPuts	msgErrorPos
	jmp	pedirDir


errorNoLibre:
	mPuts	msgErrNoLibre
	jmp	pedirDir
