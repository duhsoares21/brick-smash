bits 64
default rel

%include "../includes/SDL_structs.inc"
%include "../includes/ball.inc"
%include "../includes/ball_state_machine.inc"
%include "../includes/materials.inc"
%include "../includes/level_1.inc"
%include "../includes/level_2.inc"
%include "../includes/level_3.inc"
%include "../includes/level_4.inc"

extern Initialize_Paddle
extern Paddle

extern Ball
extern Initialize_Ball
extern Ball_Wall_Collision
extern Ball_Paddle_Collision
extern Ball_Brick_Collision
extern Ball_Animation
extern Set_Ball_State
extern Brick
extern PowerUps

extern offset
extern balls
extern total_balls

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
    ball_counter resd 1

section .data
    current_level dd 1
    total_levels dd 3

    base_framerate dd 60
    target_framerate dd 144

    ;=====================
    ; MAIN BALL DATA
    ;=====================

    ball_x dd 270.0
    ball_y dd 736.0
    ball_radius dd 12.0

    ball_direction_x dd 1.0
    ball_direction_x_half dd 0.5
    ball_direction_y dd -1.0
    ball_speed dd 0.0
    ball_offset dd 0.0

    minus_one dd -1.0
    fifty dd 50.0

    ball_active_collision dd 0

    ball_color:
        SDL_COLOR 62,164,219,255

    ball_color_glow:
        SDL_COLOR 147,209,242,255

section .text

GameStart:
    call LoadLevel
    ret

SetupBalls:
    .count_ball:
        mov eax, [total_balls]
        cmp [ball_counter], eax
        jge .end

        lea r9, [balls]
        mov eax, [ball_counter]
        imul eax, BallDefinition_size

        movss [r9 + rax + BallDefinition.speed], xmm0

        sub rsp, 8
        mov edi, BALL_STATE_STICKY
        mov esi, [ball_counter]
        call Set_Ball_State
        add rsp, 8

        inc dword [ball_counter]

        jmp .count_ball
    .end:
        mov dword [ball_counter], 0
    ret

LoadLevel:
    mov edi, 0

    movss xmm0, [ball_x]
    movss xmm1, [ball_y]
    movss xmm2, [ball_radius]
    movss xmm3, [ball_direction_x]
    movss xmm4, [ball_direction_y]
    movss xmm5, [ball_speed]
    movss xmm6, [ball_offset]

    mov esi, BALL_STATE_STICKY
    mov edx, [ball_active_collision]

    lea rcx, [ball_color]
    lea r8, [ball_color_glow]

    mov r9b, 0

    sub rsp, 16
        mov byte [rsp + 8], 1
        call Initialize_Ball
    add rsp, 16

    sub rsp, 8
        call Initialize_Paddle
    add rsp, 8

    cmp dword [current_level], 1
    je .level_1

    cmp dword [current_level], 2
    je .level_2

    cmp dword [current_level], 3
    je .level_3

    cmp dword [current_level], 4
    je .level_4

    jmp .level_1

    .level_1:
        mov eax, LEVEL_1_BALL_SPEED
        cvtsi2ss xmm0, eax

        sub rsp, 8
        call SetupBalls
        add rsp, 8

        lea rsi, [level_1_bricks]
        mov ecx, level_1_brick_total

        jmp .level_start

    .level_2:
        mov eax, LEVEL_2_BALL_SPEED
        cvtsi2ss xmm0, eax

        sub rsp, 8
        call SetupBalls
        add rsp, 8

        lea rsi, [level_2_bricks]
        mov ecx, level_2_brick_total

        jmp .level_start

    .level_3:
        mov eax, LEVEL_3_BALL_SPEED
        cvtsi2ss xmm0, eax

        sub rsp, 8
        call SetupBalls
        add rsp, 8

        lea rsi, [level_3_bricks]
        mov ecx, level_3_brick_total

        jmp .level_start

    .level_4:
        mov eax, LEVEL_4_BALL_SPEED
        cvtsi2ss xmm0, eax

        sub rsp, 8
        call SetupBalls
        add rsp, 8

        lea rsi, [level_4_bricks]
        mov ecx, level_4_brick_total

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

Process_Ball:
    call Ball
    call Ball_Paddle_Collision
    call Ball_Wall_Collision
    call Ball_Brick_Collision
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

            mov dword [destroyed_bricks], 0

            mov [total_balls], 0

            sub rsp, 8
            call SetupBalls
            add rsp, 8

            jmp LoadLevel

    .main_loop:
        call Paddle
        call Ball_Animation
        call PowerUps

        mov dword [ball_counter], 0

        .ball_loop:
            mov edi, [ball_counter]
            call Process_Ball

            inc dword [ball_counter]

            mov eax, [ball_counter]
            cmp eax, [total_balls]
            jl .ball_loop

        ret
