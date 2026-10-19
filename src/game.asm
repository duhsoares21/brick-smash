bits 64
default rel

%include "../includes/SDL_structs.inc"
%include "../includes/materials.inc"
%include "../includes/level_1.inc"
%include "../includes/level_2.inc"
%include "../includes/level_3.inc"

extern Paddle
extern Ball
extern Ball_Wall_Collision
extern Ball_Paddle_Collision
extern Ball_Brick_Collision
extern Ball_Animation
extern Set_Ball_State
extern offset
extern Brick

extern ball_x_start
extern ball_x

extern paddle_rect
extern paddle_start_x
extern destroyed_bricks

global GameStart
global GameLoop
global LoadLevel

global base_framerate
global target_framerate
global level_brick_count
global current_brick_count
global current_brick_index

section .bss
    level_brick_count resd 1
    current_brick_count resd 1
    current_brick_index resd 1

section .data
    current_level dd 1
    total_levels dd 3

    base_framerate dd 60
    target_framerate dd 144

section .text

GameStart:
    call LoadLevel
    ret

LoadLevel:

    cmp dword [current_level], 1
    je .level_1

    cmp dword [current_level], 2
    je .level_2

    cmp dword [current_level], 3
    je .level_3

    jmp .level_1

    .level_1:
        lea rsi, [level_1_bricks]
        mov ecx, level_1_brick_total

        jmp .level_start

    .level_2:
        lea rsi, [level_2_bricks]
        mov ecx, level_2_brick_total

        jmp .level_start

    .level_3:
        lea rsi, [level_3_bricks]
        mov ecx, level_3_brick_total

        jmp .level_start

    .level_start:
        mov [level_brick_count], ecx
        mov [current_brick_count], ecx

    .next_brick:
        mov ecx, [current_brick_count]
        cmp ecx, 0
        jz .done

        mov eax, [level_brick_count]
        sub eax, [current_brick_count]

        mov [current_brick_index], eax

        ;=====================
        ; RDI = BrickDefinition
        ; RDX = Width Size In Blocks (Default = 3)
        ; RCX = Height Size In Blocks (Default = 1)]
        ; XMMO = X
        ; XMM1 = Y
        ; R8D = Index
        ;=====================

        mov rdi, rsi
        ;mov rdx, [rsi + BrickDefinition.width_blocks]
        ;mov rcx, [rsi + BrickDefinition.height_blocks]
        ;movss xmm0, [rsi + BrickDefinition.x]
        ;movss xmm1, [rsi + BrickDefinition.y]
        mov r8d, [current_brick_index]

        call Brick

        add rsi, BrickDefinition_size
        mov ecx, [current_brick_count]
        dec ecx
        mov [current_brick_count], ecx

        jmp .next_brick

    .done:
    ret

GameLoop:
    mov eax, [level_brick_count]
    cmp [destroyed_bricks], eax

    je .next_level

    jmp .main_loop

    .next_level:
        mov eax, [total_levels]

        cmp [current_level], eax
        je .go_first_level

        jmp .go_next_level

        .go_first_level:
            mov [current_level], 1
            jmp .continue_to_selected_level

        .go_next_level:
            inc [current_level]

        .continue_to_selected_level:
            movss xmm0, [paddle_start_x]
            movss [paddle_rect + SDL_FRect.x], xmm0

            movss xmm0, [ball_x_start]
            movss [ball_x], xmm0

            mov dword [destroyed_bricks], 0

            mov dword [offset], 0
            mov edi, 1
            call Set_Ball_State

            jmp LoadLevel

    .main_loop:
    call Paddle
    call Ball_Animation
    call Ball
    call Ball_Paddle_Collision
    call Ball_Wall_Collision
    call Ball_Brick_Collision
    ret
