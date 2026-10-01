bits 64
default rel

%include "../includes/SDL_structs.inc"

extern base_framerate
extern target_framerate

extern delta_time

global speed

global paddle_rect
global paddle_color

global paddle_block_width
global paddle_block_height
global paddle_block_space
global paddle_block_quantity
global paddle_block_y

global paddle_block_rect
global paddle_block_color
global paddle_block_color_glow

global active_block

global Paddle

section .data
    base_speed dd 300.0
    speed dd 300.0

    paddle_block_width dd 16.0
    paddle_block_height dd 16.0
    paddle_block_space dd 2.0
    paddle_block_y dd 752.0

    paddle_block_quantity dd 11

    paddle_animation_timer dd 0.0
    paddle_animation_speed dd 0.25
    active_block dd 0

    paddle_rect:
        SDL_FRECT 170.0, 750.0, 200.0, 24.0

    paddle_color:
        SDL_COLOR 31,63,37,255

    paddle_block_color:
        SDL_COLOR 155,177,85,255

    paddle_block_color_glow:
        SDL_COLOR 200,240,74,255

section .bss
    paddle_block_rect resb SDL_FRect_size

section .text

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
        cmp eax, [paddle_block_quantity]
        jge .reset

        .end:
        ret

        .reset:
            mov [active_block], 0