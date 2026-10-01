bits 64
default rel

%include "../includes/ball_state_machine.inc"
%include "../includes/SDL_structs.inc"

global ball_x
global ball_y
global ball_radius

global ball_color

global offset

global Ball

extern paddle_rect

section .data
    ball_x dd 270.0
    ball_y dd 736.0
    ball_radius dd 12.0

    current_state dd 1
    const_div dd 2.0
    offset dd 0.0

    ball_color:
        SDL_COLOR 255,108,95,255

section .text

Ball:

    jmp State_Machine

    .set_state:
        mov [current_state], eax
        ret

State_Machine:
        cmp dword [current_state], BALL_STATE_STICKY
        je .sticky

        cmp dword [current_state], BALL_STATE_FREE
        je .free

        jmp .continue

        .sticky:
            movss xmm0, [paddle_rect + SDL_FRect.x]

            movss xmm1, [paddle_rect + SDL_FRect.w]
            divss xmm1, [const_div]

            addss xmm0, xmm1 ;Paddle Center

            movss xmm1, [offset]
            subss xmm0, xmm1

            movss [ball_x], xmm0

            ret

        .free:
            ret

        .continue:
            ret