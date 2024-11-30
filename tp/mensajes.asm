; mensajes.asm
%ifndef MSGS_DEFINED
%define MSGS_DEFINED

section .data
posx  dd 0 
    msgCI           db '   ', 0
    msgCS           db '|S|', 0  ; Suponiendo que 'S' es el símbolo del soldado
    msgCO           db '|O|', 0  ; Suponiendo que 'O' es el símbolo del oficial
    msgCD           db '| |', 0
    msgSL           db '', 10, 13, 0
    msgDiv          db 10, 13, '----------------------', 10, 13, 0
    msgSimbolosPersonalizados    db "Personalizando símbolos...", 0
    msgIngresarSimboloOficial    db "Ingrese el símbolo para los oficiales: ", 0
    msgIngresarSimboloSoldado    db "Ingrese el símbolo para los soldados: ", 0

%endif
