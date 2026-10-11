bits 64
default rel

;extern printf

global MainMenu

section .rodata
    message db "Bem-vindo ao MainMenu", 10, 0

section .text

MainMenu:
    push rbp
    mov rbp, rsp

    ;lea rdi, [message]
    ;mov al, 0
    ;call printf

    pop rbp

    ret