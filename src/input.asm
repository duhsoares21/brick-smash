bits 64
default rel

%include "../includes/SDL_structs.inc"
%include "../includes/state_machine.inc"
%include "../includes/input.inc"

%ifdef WIN32
    extern SDL_GetKeyboardState_sysv

    %define SDL_GetKeyboardState          SDL_GetKeyboardState_sysv
%else
    extern SDL_GetKeyboardState
%endif

extern set_state
extern state_machine
extern current_state

extern ball_x
extern offset

extern paddle_rect

extern speed
extern delta_time
extern left_screen_limit
extern right_screen_limit

extern Paddle
extern Ball

extern printf

global input

section .rodata
    message db "Input: %d", 10, 0

    const_div dd 2.0

section .bss
    keyboard_state resq 1

section .text

input:
    xor edi, edi
    call SDL_GetKeyboardState
    mov [keyboard_state], rax

    cmp byte [rax + SDL_SCANCODE_RETURN], 0
    jne return_pressed

    cmp byte [rax + SDL_SCANCODE_LEFT], 0
    jne left_pressed

    cmp byte [rax + SDL_SCANCODE_RIGHT], 0
    jne right_pressed

no_input:
    ret

return_pressed:
    cmp [current_state], STATE_MAIN_MENU
    je .is_main_menu

    jmp no_input

        .is_main_menu:
            push rbp
            mov rbp, rsp
                mov rdi, 2
                call set_state
                call state_machine
            pop rbp
    ret

left_pressed:
    cmp [current_state], STATE_IN_GAME
    je .is_in_game

    jmp no_input

        .is_in_game:
            movss xmm1, [speed]
            mulss xmm1, [delta_time]

            movss xmm0, [paddle_rect + SDL_FRect.x]
            subss xmm0, xmm1

            ucomiss xmm0, [left_screen_limit]
            jae .save_position

            movss xmm0, [left_screen_limit]

            .save_position:
                movss [paddle_rect + SDL_FRect.x], xmm0

            jbe no_input

            movss xmm1, [speed]
            mulss xmm1, [delta_time]

            movss xmm0, [paddle_rect + SDL_FRect.x]
            subss xmm0, xmm1
            movss [paddle_rect + SDL_FRect.x], xmm0

            jmp no_input
            ret

right_pressed:
    cmp [current_state], STATE_IN_GAME
    je .is_in_game

    jmp no_input

        .is_in_game:
            movss xmm1, [speed]
            mulss xmm1, [delta_time]

            movss xmm0, [paddle_rect + SDL_FRect.x]
            addss xmm0, xmm1

            ucomiss xmm0, [right_screen_limit]
            jbe .save_position

            movss xmm0, [right_screen_limit]

            .save_position:
                movss [paddle_rect + SDL_FRect.x], xmm0

            jae no_input

            movss xmm1, [speed]
            mulss xmm1, [delta_time]

            movss xmm0, [paddle_rect + SDL_FRect.x]
            addss xmm0, xmm1
            movss [paddle_rect + SDL_FRect.x], xmm0
            ret