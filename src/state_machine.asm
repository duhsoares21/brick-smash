bits 64
default rel

%include "../includes/state_machine.inc"

extern printf

extern MainMenu
extern GameLoop

extern current_state

global set_state
global state_machine

section .rodata
    message_state db "Current State: %d", 10, 0

section .text

set_state:
    mov [current_state], edi
    ret

state_machine:
    mov eax, [current_state]

	cmp eax, STATE_MAIN_MENU
	je .menu

	cmp eax, STATE_IN_GAME
	je .game

	ret

.menu:
    push rbp
    mov rbp, rsp
	call MainMenu
	pop rbp
	ret

.game:
    push rbp
    mov rbp, rsp
    call GameLoop
    pop rbp
    ret