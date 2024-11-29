extern gets, puts, sscanf, printf, strcmp

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

%macro ingreso 3
lectura:
	mPuts	msgx
	mGets   posxStr

        mPuts   msgy
        mGets   posyStr

        mSscanf posxStr, mFormat, posxEnv
        mSscanf posyStr, mFormat, posyEnv

	;validar que este entre 1 y 7
        mov     al, [posxEnv]
        cmp     al, 1
        jl      error
        cmp     al, 7
        jg      error

        mov     al, [posyEnv]
        cmp     al, 1
        jl      error
        cmp     eax, 7
        jg      error

validarCasilla:
	sub	rbx,rbx
	indice	posxEnv, posyEnv
	mov	rdi,mVer
	mov	sil,[%3 + rbx]
	sub     rsp, 8
        call    printf
        add     rsp, 8

	sub	rax,rax
	mov	al, [%3 + rbx]

	and	al,10000000b ; si la casilla es invalida
	cmp	al,10000000b
	je	error

envio:
	mov     al,[posxEnv]
        mov     [%1], al

        mov     al,[posyEnv]
        mov     [%2], al

	mov     rdi, msgPsc
        mov     sil, [posxEnv]
        mov     dl, [posyEnv]
        sub     rsp, 8
        call    printf
        add     rsp, 8

	jmp	terminaLectura
error:
	mPuts	msgError
	jmp	lectura

terminaLectura:
	sub	rax,rax
lecturaDir:
	mPuts	msgDir
	mGets	direccion
comparacion:

	lea	rdi,[direccion]
	lea	rsi,[derDir]

	sub	rsp,8
	call	strcmp
	add	rsp,8
	test	rax,rax
	jz	derecha

	lea     rdi,[direccion]
	lea	rsi,[dderDir]
	sub     rsp,8
        call    strcmp
        add     rsp,8
	test	rax,rax
        jz      diagonalDerecha

        lea     rdi,[direccion]
	lea     rsi,[abaDir]
        sub     rsp,8
        call    strcmp
        add     rsp,8
        test    rax,rax
        jz      abajo

        lea     rdi,[direccion]
	lea     rsi,[dizqDir]
        sub     rsp,8
        call    strcmp
        add     rsp,8
        test    rax,rax
        jz      diagonalIzquierda

        lea     rdi,[direccion]
        lea     rsi,[izqDir]
        sub     rsp,8
        call    strcmp
        add     rsp,8
        test    rax,rax
        jz      izquierda

entradaInvalida:
	mPuts	msgErrDir
	jmp	lecturaDir

derecha:
	mPuts	derDir
	sub     rbx,rbx
        indice  posxEnv, posyEnv
	mov	al,[%3 + rbx]
	and	al,00010000b
	cmp	al,00010000b
	jne	entradaInvalida

	and     byte[%3 + rbx],00111111b;quita al soldado
        inc     bl;avanza a la derecha
        or      byte[%3 + rbx],01000000b;añade un soldado

	jmp	finDir
diagonalDerecha:
        mPuts   dderDir

	sub     rbx,rbx
        indice  posxEnv, posyEnv
        mov     al,[%3 + rbx]
        and     al,00001000b
        cmp     al,00001000b
        jne     entradaInvalida

	and     byte[%3 + rbx],00111111b;quita al soldado
        add     bl, 08h;avanza a la siguinte fila+1
        or      byte[%3 + rbx],01000000b;añade un soldado

	jmp	finDir
abajo:
        mPuts   abaDir

	sub     rbx,rbx
        indice  posxEnv, posyEnv
        mov     al,[%3 + rbx]
        and     al,00000100b
        cmp     al,00000100b
        jne     entradaInvalida

	and	byte[%3 + rbx],00111111b;quita al soldado
	add	bl, 07h;avanza a la siguinte fila
	or	byte[%3 + rbx],01000000b;añade un soldado

	jmp	finDir
diagonalIzquierda:
	mPuts   dizqDir

	sub     rbx,rbx
        indice  posxEnv, posyEnv
        mov     al,[%3 + rbx]
        and     al,00000010b
        cmp     al,00000010b
        jne     entradaInvalida

	and     byte[%3 + rbx],00111111b;quita al soldado
        add     bl, 06h;avanza a la siguinte fila-1
        or      byte[%3 + rbx],01000000b;añade un soldado

	jmp	finDir
izquierda:
	mPuts   izqDir

	sub     rbx,rbx
        indice  posxEnv, posyEnv
        mov     al,[%3 + rbx]
        and     al,00000001b
        cmp     al,00000001b
        jne     entradaInvalida

	and     byte[%3 + rbx],00111111b;quita al soldado
        dec     bl;avanza a la izq
        or      byte[%3 + rbx],01000000b;añade un soldado

	jmp	finDir
finDir:
	sub	rax,rax

%endmacro

%macro	ganaronSoldados	1

validarFin:
	sub	rcx,rcx
	mov	cl,09h
	indice	posxFortaleza,posyFortaleza
cicloFortaleza:
	mov	al,[%1 + rbx]
	and	al,01000000b
	cmp	al,01000000b
	jne	finValidacion;si no es igual se termina la validacion
siguienteDir:
	inc	rbx
	inc	byte[contador]
	inc	byte[contAux]
	cmp	byte[contAux],03h
	je	siguienteFila
	loop	cicloFortaleza
	jmp	finValidacion
siguienteFila:
	mov	byte[contAux],00h
	add	rbx,0004h
	loop	cicloFortaleza

finValidacion:
	sub	rax,rax
	mov	al,[contador]

%endmacro

%macro  indice 2
        ;devuelve en rbx el indice
        sub     rbx,rbx
        sub     rax,rax

        movsx   rax, byte[%2]
        dec     rax
        imul    rax,01h
        imul    rax,07h

        mov     rbx,rax

        movsx   rax, byte[%1]
        dec     rax
        imul    rax,01h

        add     rbx,rax

%endmacro

%macro personalizar 0
    mPuts msgSimboloOficial
    mGets simboloOficial

    mPuts msgSimboloSoldado
    mGets simboloSoldado

    mPuts msgOrientacion
    mGets direccion
    mSscanf direccion, mFormat, orientacion
    cmp byte [orientacion], 3
    jbe valido
    mov byte [orientacion], 0
valido:
%endmacro

%macro reemplazarSimbolos 1
    mov rcx, [longitud]
    mov rbx, [tamanio]
cicloReemplazo:
    mov al, [%1 + rbx]
    and al, 01000000b
    cmp al, 01000000b
    jne oficial

    mov al, [simboloSoldado]
    mov [%1 + rbx], al
    jmp siguiente

oficial:
    mov al, [%1 + rbx]
    and al, 00100000b
    cmp al, 00100000b
    jne siguiente

    mov al, [simboloOficial]
    mov [%1 + rbx], al

siguiente:
    dec rbx
    loop cicloReemplazo
%endmacro

%macro rotarMatriz 2
    cmp byte [orientacion], 0
    je finRotar

    cmp byte [orientacion], 1
    je rotar90

    cmp byte [orientacion], 2
    je rotar180

    cmp byte [orientacion], 3
    je rotar270

rotar90:

    call transponerMatriz
    call invertirColumnas
    jmp finRotar

rotar180:

    call invertirFilas
    call invertirColumnas
    jmp finRotar

rotar270:

    call transponerMatriz
    call invertirFilas
    jmp finRotar

finRotar:
%endmacro

section		.data

         simboloOficial   db 'O', 0
        simboloSoldado   db 'S', 0
        orientacion      db 0
    
        msgSimboloOficial db "Ingrese el ssmbolo para los oficiales: ", 0
        msgSimboloSoldado db "Ingrese el simbolo para los soldados: ", 0
        msgOrientacion    db "Ingrese la orientación del tablero (0: normal, 1: 90°, 2: 180°, 3: 270°): ", 0

	msgx            db      "Ingrese posicion en x", 0
        msgy            db      "Ingrese posicion en y", 0
        msgError        db      "Posicion invalida",10,13,0
        msgPsc          db      "Posicion ingresada: %hhi - %hhi",10,13,0
        mFormat         db      "%hhi", 0
	mVer		db	"%hhi",10,13,0

	msgDir		db	"Ingrese la direccion: ",0
	derDir		db	"der",0
	dderDir		db	"dder",0
	abaDir		db	"aba",0
	izqDir		db      "izq",0
        dizqDir		db      "dizq",0
	msgErrDir	db	"Direccion no valida",10,13,0

	posxFortaleza	db	03h
	posyFortaleza	db	05h
	contador	db	00h
	contAux		db	00h
section		.bss
	posxStr		resb	10
	posyStr		resb	10

	posxEnv		resb	1
	posyEnv		resb	1

	direccion	resb	10

