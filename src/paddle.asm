bits 64
default rel

%include "../includes/SDL_structs.inc"

extern base_framerate
extern target_framerate

extern delta_time

extern right_screen_limit

global speed

global paddle_rect
global paddle_color

global paddle_start_x

global paddle_block_width
global paddle_block_height
global paddle_block_space
global default_paddle_blocks_quantity
global paddle_current_blocks_quantity
global paddle_block_y

global paddle_block_rect
global paddle_block_color
global paddle_block_color_glow

global active_block

global Initialize_Paddle
global Resize_Paddle
global Paddle

section .data
    base_speed dd 300.0
    speed dd 300.0

    paddle_block_width dd 16.0
    paddle_block_height dd 16.0
    paddle_block_space dd 2.0
    paddle_block_y dd 752.0

    default_paddle_blocks_quantity dd 7
    paddle_current_blocks_quantity dd 7

    paddle_animation_timer dd 0.0
    paddle_animation_speed dd 0.25
    active_block dd 0

    paddle_start_x dd 170.0
    paddle_start_y dd 750.0
    paddle_start_h dd 24.0

    two dd 2.0

    paddle_color:
        SDL_COLOR 31,63,37,255

    paddle_block_color:
        SDL_COLOR 155,177,85,255

    paddle_block_color_glow:
        SDL_COLOR 200,240,74,255

section .bss
    paddle_block_rect resb SDL_FRect_size
    paddle_rect resb SDL_FRect_size

section .text

Initialize_Paddle:
    movss xmm0, [paddle_start_y]
    movss [paddle_rect + SDL_FRect.y], xmm0

    movss xmm0, [paddle_block_width]
    addss xmm0, [paddle_block_space]
    mov eax, [paddle_current_blocks_quantity]
    cvtsi2ss xmm1, eax
    mulss xmm0, xmm1
    addss xmm0, [paddle_block_space]

    movss [paddle_rect + SDL_FRect.w], xmm0

    movss xmm1, [right_screen_limit]
    subss xmm1, xmm0
    divss xmm1, [two]

    movss [paddle_rect + SDL_FRect.x], xmm1

    movss xmm0, [paddle_start_h]
    movss [paddle_rect + SDL_FRect.h], xmm0
    ret

Resize_Paddle:
    movss xmm0, [paddle_block_width]
    addss xmm0, [paddle_block_space]
    mov eax, [paddle_current_blocks_quantity]
    cvtsi2ss xmm1, eax
    mulss xmm0, xmm1
    addss xmm0, [paddle_block_space]

    movss [paddle_rect + SDL_FRect.w], xmm0

    ret

Paddle:

    .animation:
        movss xmm0, [paddle_animation_timer]
        addss xmm0, [delta_time]
        movss [paddle_animation_timer], xmm0

        ucomiss xmm0, [paddle_animation_speed]
        jb .end

        mov dword [paddle_animation_timer], 0

        inc dword [active_block]

        mov eax, [active_block]
        cmp eax, [paddle_current_blocks_quantity]
        jge .reset

        jmp .end

        .reset:
            mov [active_block], 0

        .end:
            ret