bits 64
default rel

%include "../includes/SDL_structs.inc"
%include "../includes/state_machine.inc"

%ifdef WIN32
    extern SDL_SetRenderDrawColor_sysv
    extern SDL_RenderFillRect_sysv
    extern filledCircleRGBA_sysv

    %define SDL_SetRenderDrawColor        SDL_SetRenderDrawColor_sysv
    %define SDL_RenderFillRect            SDL_RenderFillRect_sysv
    %define filledCircleRGBA              filledCircleRGBA_sysv
%else
    extern SDL_SetRenderDrawColor
    extern SDL_RenderFillRect
    extern filledCircleRGBA
%endif

extern renderer
extern current_state

extern x
extern y
extern width
extern height

extern paddle_rect
extern paddle_color

extern paddle_block_width
extern paddle_block_height
extern paddle_block_space
extern paddle_block_quantity
extern paddle_block_y

extern paddle_block_rect
extern paddle_block_color
extern paddle_block_color_glow

extern active_block

extern ball_x
extern ball_y
extern ball_radius

extern ball_color
extern ball_color_glow
extern ball_active_collision

global Render

section .data
    counter dd 0
    zero dd 0.0

section .text

Render:

    cmp [current_state], STATE_MAIN_MENU
    je .menu

    cmp [current_state], STATE_IN_GAME
    je .game

    jmp .unknown

    .menu:
        ret

    .game:
        push rbp
        mov rbp, rsp

        mov rdi, [renderer]
        mov esi, [paddle_color + SDL_Color.r]
        mov edx, [paddle_color + SDL_Color.g]
        mov ecx, [paddle_color + SDL_Color.b]
        mov r8d, [paddle_color + SDL_Color.a]

        call SDL_SetRenderDrawColor

        mov rdi, [renderer]
        lea rsi, [paddle_rect]
        call SDL_RenderFillRect

        mov rdi, [renderer]

        mov esi, [paddle_block_color + SDL_Color.r]
        mov edx, [paddle_block_color + SDL_Color.g]
        mov ecx, [paddle_block_color + SDL_Color.b]
        mov r8d, [paddle_block_color + SDL_Color.a]

        call SDL_SetRenderDrawColor

        mov dword [counter], 0

        .add_paddle_block:
            mov eax, [counter]

            cmp eax, [paddle_block_quantity]
            jge .draw_ball

            movss xmm0, [paddle_rect + SDL_FRect.x]
            movss xmm1, [paddle_block_width]
            movss xmm2, [paddle_block_space]

            addss xmm1, xmm2

            mov eax, [counter]
            cvtsi2ss xmm3, eax
            mulss xmm1, xmm3

            addss xmm1, xmm2
            addss xmm1, xmm0

            movss [paddle_block_rect + SDL_FRect.x], xmm1

            movss xmm0, [paddle_block_y]
            addss xmm0, [paddle_block_space]
            movss [paddle_block_rect + SDL_FRect.y], xmm0

            movss xmm0, [paddle_block_width]
            movss [paddle_block_rect + SDL_FRect.w], xmm0

            movss xmm0, [paddle_block_height]
            movss [paddle_block_rect + SDL_FRect.h], xmm0

            mov eax, [counter]
            cmp eax, [active_block]
            je .active_color

            jmp .inactive_color

            .active_color:
                mov rdi, [renderer]

                mov esi, [paddle_block_color_glow + SDL_Color.r]
                mov edx, [paddle_block_color_glow + SDL_Color.g]
                mov ecx, [paddle_block_color_glow + SDL_Color.b]
                mov r8d, [paddle_block_color_glow + SDL_Color.a]

                call SDL_SetRenderDrawColor

                jmp .render_block

            .inactive_color:

                mov rdi, [renderer]

                mov esi, [paddle_block_color + SDL_Color.r]
                mov edx, [paddle_block_color + SDL_Color.g]
                mov ecx, [paddle_block_color + SDL_Color.b]
                mov r8d, [paddle_block_color + SDL_Color.a]

                call SDL_SetRenderDrawColor

        .render_block:
            mov rdi, [renderer]
            lea rsi, [paddle_block_rect]
            call SDL_RenderFillRect

            mov eax, [counter]
            inc eax
            mov [counter], eax

            jmp .add_paddle_block

        .draw_ball:

            mov rdi, [renderer]

            movss xmm0, [ball_x]
            movss xmm1, [ball_y]
            movss xmm2, [ball_radius]

            cmp [ball_active_collision], 1
            je .collision_ball

            .default_ball:
                mov esi, [ball_color + SDL_Color.r]
                mov edx, [ball_color + SDL_Color.g]
                mov ecx, [ball_color + SDL_Color.b]
                mov r8d, [ball_color + SDL_Color.a]

                call filledCircleRGBA

                jmp .continue_draw

            .collision_ball:
                mov esi, [ball_color_glow + SDL_Color.r]
                mov edx, [ball_color_glow + SDL_Color.g]
                mov ecx, [ball_color_glow + SDL_Color.b]
                mov r8d, [ball_color_glow + SDL_Color.a]

                call filledCircleRGBA

            .continue_draw:

        pop rbp

        ret

    .unknown:
        ret