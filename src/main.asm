bits 64
default rel

extern create_window

global main
global current_state

section .data
    current_state dd 1

section .text

main:
    push rbp
    mov rbp, rsp

    call create_window

    xor rax, rax
    pop rbp

    ret