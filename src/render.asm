bits 64
default rel

%include "../includes/SDL_structs.inc"
%include "../includes/bricks.inc"
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

extern bricks_materials
extern bricks_rectangles
extern level_brick_count
extern current_brick_count
extern current_brick_index

global Render

section .data
    counter dd 0
    render_brick_counter dd 0
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
        movzx esi, byte [paddle_color + SDL_Color.r]
        movzx edx, byte [paddle_color + SDL_Color.g]
        movzx ecx, byte [paddle_color + SDL_Color.b]
        movzx r8d, byte [paddle_color + SDL_Color.a]

        call SDL_SetRenderDrawColor

        mov rdi, [renderer]
        lea rsi, [paddle_rect]
        call SDL_RenderFillRect

        mov rdi, [renderer]

        movzx esi, byte [paddle_block_color + SDL_Color.r]
        movzx edx, byte [paddle_block_color + SDL_Color.g]
        movzx ecx, byte [paddle_block_color + SDL_Color.b]
        movzx r8d, byte [paddle_block_color + SDL_Color.a]

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

                movzx esi, byte [paddle_block_color_glow + SDL_Color.r]
                movzx edx, byte [paddle_block_color_glow + SDL_Color.g]
                movzx ecx, byte [paddle_block_color_glow + SDL_Color.b]
                movzx r8d, byte [paddle_block_color_glow + SDL_Color.a]

                call SDL_SetRenderDrawColor

                jmp .render_block

            .inactive_color:

                mov rdi, [renderer]

                movzx esi, byte [paddle_block_color + SDL_Color.r]
                movzx edx, byte [paddle_block_color + SDL_Color.g]
                movzx ecx, byte [paddle_block_color + SDL_Color.b]
                movzx r8d, byte [paddle_block_color + SDL_Color.a]

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
                movzx esi, byte [ball_color + SDL_Color.r]
                movzx edx, byte [ball_color + SDL_Color.g]
                movzx ecx, byte [ball_color + SDL_Color.b]
                movzx r8d, byte [ball_color + SDL_Color.a]

                call filledCircleRGBA

                jmp .draw_bricks

            .collision_ball:
                movzx esi, byte [ball_color_glow + SDL_Color.r]
                movzx edx, byte [ball_color_glow + SDL_Color.g]
                movzx ecx, byte [ball_color_glow + SDL_Color.b]
                movzx r8d, byte [ball_color_glow + SDL_Color.a]

                call filledCircleRGBA

        .draw_bricks:

            mov [render_brick_counter], 0

            .draw_next_brick:
                mov eax, [level_brick_count]

                cmp [render_brick_counter], eax
                je .continue_draw

                lea r9, [bricks_materials]
                mov eax, [render_brick_counter]
                imul eax, BrickMaterial_size

                cmp [r9 + rax + BrickMaterial.max_hits], 0
                jle .increment

                mov rdi, [renderer]

                movzx esi, byte [r9 + rax + BrickMaterial.color + SDL_Color.r]
                movzx edx, byte [r9 + rax + BrickMaterial.color + SDL_Color.g]
                movzx ecx, byte [r9 + rax + BrickMaterial.color + SDL_Color.b]
                movzx r8d, byte [r9 + rax + BrickMaterial.color + SDL_Color.a]

                call SDL_SetRenderDrawColor

                lea r9, [bricks_rectangles]
                mov eax, [render_brick_counter]
                imul eax, SDL_FRect_size

                mov rdi, [renderer]
                lea rsi, [r9 + rax]

                call SDL_RenderFillRect

                .increment:
                    inc [render_brick_counter]
                    jmp .draw_next_brick

            .continue_draw:

        pop rbp

        ret

    .unknown:
        ret