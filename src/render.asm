bits 64
default rel

%include "../includes/SDL_structs.inc"
%include "../includes/ball.inc"
%include "../includes/bricks.inc"
%include "../includes/materials.inc"
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

extern balls
extern total_balls

extern bricks_hits
extern bricks_definitions
extern bricks_rectangles
extern level_brick_count
extern current_brick_count
extern current_brick_index

global Render

section .bss
    render_ball_counter resd 1

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
            mov dword [render_ball_counter], 0

            .draw_next_ball:
                mov eax, [render_ball_counter]
                cmp eax, [total_balls]
                jge .draw_bricks

                lea r9, [balls]
                imul eax, BallDefinition_size

                cmp byte [r9 + rax + BallDefinition.is_active], 0
                je .next_ball

                mov rdi, [renderer]

                movss xmm0, [r9 + rax + BallDefinition.x]
                movss xmm1, [r9 + rax + BallDefinition.y]
                movss xmm2, [r9 + rax + BallDefinition.radius]

                cmp [r9 + rax + BallDefinition.collision], 1
                je .collision_ball

                .default_ball:
                    movzx esi, byte [r9 + rax + BallDefinition.color + SDL_Color.r]
                    movzx edx, byte [r9 + rax + BallDefinition.color + SDL_Color.g]
                    movzx ecx, byte [r9 + rax + BallDefinition.color + SDL_Color.b]
                    movzx r8d, byte [r9 + rax + BallDefinition.color + SDL_Color.a]

                    call filledCircleRGBA

                    jmp .next_ball

                .collision_ball:
                    movzx esi, byte [r9 + rax + BallDefinition.color_glow + SDL_Color.r]
                    movzx edx, byte [r9 + rax + BallDefinition.color_glow + SDL_Color.g]
                    movzx ecx, byte [r9 + rax + BallDefinition.color_glow + SDL_Color.b]
                    movzx r8d, byte [r9 + rax + BallDefinition.color_glow + SDL_Color.a]

                    call filledCircleRGBA

                .next_ball:
                        inc dword [render_ball_counter]
                        jmp .draw_next_ball

        .draw_bricks:

            mov [render_brick_counter], 0

            .draw_next_brick:
                mov eax, [level_brick_count]

                cmp [render_brick_counter], eax
                je .continue_draw

                lea r9, [bricks_hits]
                mov eax, [render_brick_counter]
                imul eax, 4

                cmp [r9 + rax], 0
                jle .increment

                lea r9, [bricks_definitions]
                mov eax, [render_brick_counter]
                imul eax, BrickDefinition_size

                mov r11d, [r9 + rax + BrickDefinition.material]; id do material
                dec r11d; Obtém index da tabela

                lea r9, [material_table]; acessa endereço da tabela em r9
                mov r9, [r9 + r11 * 8];

                mov rdi, [renderer]

                movzx esi, byte [r9 + BrickMaterial.color + SDL_Color.r]
                movzx edx, byte [r9 + BrickMaterial.color + SDL_Color.g]
                movzx ecx, byte [r9 + BrickMaterial.color + SDL_Color.b]
                movzx r8d, byte [r9 + BrickMaterial.color + SDL_Color.a]

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