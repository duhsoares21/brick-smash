default rel

%include "../includes/ball_state_machine.inc"
%include "../includes/ball.inc"
%include "../includes/bricks.inc"
%include "../includes/materials.inc"
%include "../includes/powerups.inc"
%include "../includes/SDL_structs.inc"

extern current_power
extern previous_power
extern active_extra_balls

extern PlayAudio

extern track_wall
extern track_brick
extern track_paddle
extern track_lose

extern bricks_hits
extern bricks_definitions
extern bricks_rectangles
extern level_brick_count
extern destroyed_bricks

extern delta_time
extern paddle_rect

extern top_screen_limit
extern left_screen_limit
extern right_screen_limit
extern bottom_screen_limit

global balls
global total_balls

global Ball
global Initialize_Ball
global Ball_Wall_Collision
global Ball_Paddle_Collision
global Ball_Brick_Collision
global Set_Ball_State
global ball_active_collision

section .bss
    brick_counter resd 1
    previous_ball_x resd 1
    previous_ball_y resd 1
    is_active resb 1

    balls: resb BallDefinition_size * MAX_BALLS

section .data
    zero dd 0.0
    two dd 2.0
    twenty dd 20.0
    minus_one dd -1.0

    index dd 0
    total_balls dd 0
    ball_counter dd 0

section .text

Ball:
    mov [index], edi
    jmp State_Machine

Initialize_Ball:

    push rbx
    push r10

    mov [index], edi

    lea r10, [balls]
    mov eax, [index]
    imul eax, BallDefinition_size

    movss [r10 + rax + BallDefinition.x_initial], xmm0
    movss [r10 + rax + BallDefinition.x], xmm0
    movss [r10 + rax + BallDefinition.y], xmm1
    movss [r10 + rax + BallDefinition.radius], xmm2
    movss [r10 + rax + BallDefinition.direction_x], xmm3
    movss [r10 + rax + BallDefinition.direction_y], xmm4
    movss [r10 + rax + BallDefinition.speed], xmm5
    movss [r10 + rax + BallDefinition.offset], xmm6
    mov dword [r10 + rax + BallDefinition.state], esi
    mov dword [r10 + rax + BallDefinition.collision], edx

    mov ebx, [rcx]
    mov [r10 + rax + BallDefinition.color], ebx

    mov ebx, [r8]
    mov [r10 + rax + BallDefinition.color_glow], ebx

    mov byte [r10 + rax + BallDefinition.is_extra], r9b

    mov bl, byte [rsp + 32]
    mov byte [r10 + rax + BallDefinition.is_active], 1

    mov eax, [total_balls]
    inc eax
    mov [total_balls], eax

    pop r10
    pop rbx

    ret

Set_Ball_State:
    lea r8, [balls]
    imul esi, BallDefinition_size

    mov [r8 + rsi + BallDefinition.state], edi
    ret

State_Machine:
    lea r8, [balls]
    mov ecx, [index]
    imul ecx, BallDefinition_size

    cmp dword [r8 + rcx + BallDefinition.state], BALL_STATE_STICKY
    je .sticky

    cmp dword [r8 + rcx + BallDefinition.state], BALL_STATE_FREE
    je .free

    jmp Continue

        .sticky:
            movss xmm0, [paddle_rect + SDL_FRect.x]

            movss xmm1, [paddle_rect + SDL_FRect.w]
            divss xmm1, [two]

            addss xmm0, xmm1 ;Paddle Center

            lea r8, [balls]
            mov ecx, [index]
            imul ecx, BallDefinition_size

            movss xmm1, [r8 + rcx + BallDefinition.offset]
            addss xmm0, xmm1

            movss [r8 + rcx + BallDefinition.x], xmm0

            movss xmm0, [paddle_rect + SDL_FRect.y]
            subss xmm0, [r8 + rcx + BallDefinition.radius]

            movss [r8 + rcx + BallDefinition.y], xmm0

            ret

        .free:

        .movement:
            lea r8, [balls]
            mov ecx, [index]
            imul ecx, BallDefinition_size

            movss xmm0, [r8 + rcx + BallDefinition.speed]
            mulss xmm0, [delta_time]
            mulss xmm0, [r8 + rcx + BallDefinition.direction_x]

            movss xmm1, [r8 + rcx + BallDefinition.x]
            movss [r8 + rcx + BallDefinition.previous_x], xmm1

            addss xmm1, xmm0

            movss [r8 + rcx + BallDefinition.x], xmm1

            movss xmm0, [r8 + rcx + BallDefinition.speed]
            mulss xmm0, [delta_time]
            mulss xmm0, [r8 + rcx + BallDefinition.direction_y]

            movss xmm1, [r8 + rcx + BallDefinition.y]
            movss [r8 + rcx + BallDefinition.previous_y], xmm1
            addss xmm1, xmm0

            movss [r8 + rcx + BallDefinition.y], xmm1

            ucomiss xmm1, [bottom_screen_limit]
            ja .change_ball_state

            jmp Continue

            .change_ball_state:
                mov rdi, [track_lose]
                call PlayAudio

                movss xmm0, [zero]

                lea r8, [balls]
                mov ecx, [index]
                imul ecx, BallDefinition_size

                cmp [r8 + rcx + BallDefinition.is_extra], 1
                je .deactivate_ball

                movss [r8 + rcx + BallDefinition.offset], xmm0

                mov edi, BALL_STATE_STICKY
                mov esi, [index]
                call Set_Ball_State

                jmp .end

                .deactivate_ball:
                    lea r8, [balls]
                    mov ecx, [index]
                    imul ecx, BallDefinition_size

                    mov byte [r8 + rcx + BallDefinition.is_active], 0

                    dec dword [active_extra_balls]

                    cmp [active_extra_balls], 0
                    je .finish_power

                    jmp .reset_ball

                    .finish_power
                        mov [current_power], POWER_NONE
                        mov [previous_power], POWER_NONE

                    .reset_ball:
                        mov edi, BALL_STATE_STICKY
                        mov esi, [index]
                        call Set_Ball_State

                .end:
                    ret


Ball_Wall_Collision:
    lea r8, [balls]
    mov ecx, [index]
    imul ecx, BallDefinition_size

    movss xmm0, [r8 + rcx + BallDefinition.x]

    movss xmm1, [r8 + rcx + BallDefinition.direction_x]
    ucomiss xmm1, [zero]
    jb .sub
    ja .add

    jmp Continue

        .sub:
            lea r8, [balls]
            mov ecx, [index]
            imul ecx, BallDefinition_size

            subss xmm0, [r8 + rcx + BallDefinition.radius]
            jmp .checks

        .add:
            lea r8, [balls]
            mov ecx, [index]
            imul ecx, BallDefinition_size

            addss xmm0, [r8 + rcx + BallDefinition.radius]

        .checks:

        ucomiss xmm0, [left_screen_limit]
        jbe .invert

        ucomiss xmm0, [right_screen_limit]
        jae .invert

        jmp .vertical_ball_collision

        .invert:
            mov rdi, [track_wall]
            call PlayAudio

            lea r8, [balls]
            mov ecx, [index]
            imul ecx, BallDefinition_size

            mov dword [r8 + rcx + BallDefinition.collision], 1

            movss xmm0, [r8 + rcx + BallDefinition.direction_x]
            movss xmm1, [minus_one]
            mulss xmm0, xmm1
            movss [r8 + rcx + BallDefinition.direction_x], xmm0

        .vertical_ball_collision:
            lea r8, [balls]
            mov ecx, [index]
            imul ecx, BallDefinition_size

            movss xmm0, [r8 + rcx + BallDefinition.y]
            subss xmm0, [r8 + rcx + BallDefinition.radius]

            ucomiss xmm0, [top_screen_limit]
            jbe .vertical_invert

            jmp Continue

        .vertical_invert:
            mov rdi, [track_wall]
            call PlayAudio

            lea r8, [balls]
            mov ecx, [index]
            imul ecx, BallDefinition_size

            mov dword [r8 + rcx + BallDefinition.collision], 1

            movss xmm0, [r8 + rcx + BallDefinition.direction_y]
            movss xmm1, [minus_one]
            mulss xmm0, xmm1
            movss [r8 + rcx + BallDefinition.direction_y], xmm0

            ret

Ball_Paddle_Collision:
        lea r8, [balls]
        mov ecx, [index]
        imul ecx, BallDefinition_size

        movss xmm0, [r8 + rcx + BallDefinition.direction_y]
        ucomiss xmm0, [zero]
        jb Continue

        movss xmm0, [r8 + rcx + BallDefinition.y]
        movss xmm1, [paddle_rect + SDL_FRect.y]
        subss xmm1, [r8 + rcx + BallDefinition.radius]

        ucomiss xmm0, xmm1
        jae .check_vertical_bottom_paddle

        jmp Continue

    .check_vertical_bottom_paddle:
        lea r8, [balls]
        mov ecx, [index]
        imul ecx, BallDefinition_size

        movss xmm0, [r8 + rcx + BallDefinition.y]
        movss xmm1, [paddle_rect + SDL_FRect.y]
        addss xmm1, [paddle_rect + SDL_FRect.h]

        subss xmm1, [r8 + rcx + BallDefinition.radius]

        ucomiss xmm0, xmm1
        jbe .check_left_side_paddle

        jmp Continue

    .check_left_side_paddle:
        lea r8, [balls]
        mov ecx, [index]
        imul ecx, BallDefinition_size

        movss xmm0, [r8 + rcx + BallDefinition.x]

        movss xmm1, [paddle_rect + SDL_FRect.x]
        subss xmm1, [r8 + rcx + BallDefinition.radius]

        ucomiss xmm0, xmm1
        ja .check_right_side_paddle

        jmp Continue

    .check_right_side_paddle:
        movss xmm1, [paddle_rect + SDL_FRect.x]
        addss xmm1, [paddle_rect + SDL_FRect.w]

        lea r8, [balls]
        mov ecx, [index]
        imul ecx, BallDefinition_size

        addss xmm1, [r8 + rcx + BallDefinition.radius]

        ucomiss xmm0, xmm1
        jbe .hit_paddle

        jmp Continue

    .hit_paddle:
        lea r8, [balls]
        mov ecx, [index]
        imul ecx, BallDefinition_size

        movss xmm0, [r8 + rcx + BallDefinition.x]

        movss xmm1, [paddle_rect + SDL_FRect.x]

        movss xmm2, [paddle_rect + SDL_FRect.w]
        divss xmm2, [two]

        addss xmm1, xmm2

        subss xmm0, xmm1
        movss dword [r8 + rcx + BallDefinition.offset], xmm0

    .check_corner_range:
        movss xmm0, [paddle_rect + SDL_FRect.x]
        addss xmm0, [twenty]

        lea r8, [balls]
        mov ecx, [index]
        imul ecx, BallDefinition_size

        movss xmm1, [r8 + rcx + BallDefinition.x]

        ucomiss xmm1, xmm0
        jb .hit_left_corner

        movss xmm0, [paddle_rect + SDL_FRect.x]
        addss xmm0, [paddle_rect + SDL_FRect.w]
        subss xmm0, [twenty]

        movss xmm1, [r8 + rcx + BallDefinition.x]

        ucomiss xmm1, xmm0
        jae .hit_right_corner

        jmp .hit_surface

    .hit_left_corner:
        lea r8, [balls]
        mov ecx, [index]
        imul ecx, BallDefinition_size

        movss xmm0, [r8 + rcx + BallDefinition.direction_x]
        ucomiss xmm0, [zero]
        ja .reverse_x

        jmp .hit_surface

    .hit_right_corner:
        lea r8, [balls]
        mov ecx, [index]
        imul ecx, BallDefinition_size

        movss xmm0, [r8 + rcx + BallDefinition.direction_x]
        ucomiss xmm0, [zero]
        jb .reverse_x

        jmp .hit_surface

    .reverse_x:
        mov rdi, [track_paddle]
        call PlayAudio

        lea r8, [balls]
        mov ecx, [index]
        imul ecx, BallDefinition_size

        cmp [current_power], POWER_STICKY_PADDLE
        je .sticky_power_corner

        jmp .proceed_reverse_x

        .sticky_power_corner:
            mov edi, BALL_STATE_STICKY
            mov esi, [index]
            sub rsp, 8
            call Set_Ball_State
            add rsp, 8

        .proceed_reverse_x:
            movss xmm0, [r8 + rcx + BallDefinition.direction_x]
            movss xmm1, [minus_one]
            mulss xmm0, xmm1
            movss [r8 + rcx + BallDefinition.direction_x], xmm0

            movss xmm0, [r8 + rcx + BallDefinition.direction_y]
            movss xmm1, [paddle_rect + SDL_FRect.y]

            movss xmm2, [paddle_rect + SDL_FRect.h]
            divss xmm2, [two]

            addss xmm1, xmm2

            subss xmm0, [r8 + rcx + BallDefinition.radius]

            ucomiss xmm0, xmm1
            jbe Continue

    .hit_surface:
        mov rdi, [track_paddle]
        call PlayAudio

        lea r8, [balls]
        mov ecx, [index]
        imul ecx, BallDefinition_size

        cmp [current_power], POWER_STICKY_PADDLE
        je .sticky_power_surface

        jmp .proceed_surface

        .sticky_power_surface:
            mov edi, BALL_STATE_STICKY
            mov esi, [index]
            sub rsp, 8
            call Set_Ball_State
            add rsp, 8

        .proceed_surface:
            movss xmm0, [r8 + rcx + BallDefinition.direction_y]
            ucomiss xmm0, [zero]

            jbe Continue

            mov DWORD [r8 + rcx + BallDefinition.collision], 1

            movss xmm0, [r8 + rcx + BallDefinition.direction_y]
            movss xmm1, [minus_one]
            mulss xmm0, xmm1
            movss [r8 + rcx + BallDefinition.direction_y], xmm0

        ret

Ball_Brick_Collision:
    .hit_brick_check:
        mov dword [brick_counter], 0

    .check_next_brick:
        mov eax, [brick_counter]
        cmp eax, [level_brick_count]
        je Continue

        lea r9, [bricks_hits]
        mov eax, [brick_counter]
        imul eax, 4

        cmp [r9 + rax], 0
        jle .increment

        lea r9, [bricks_rectangles]
        mov eax, [brick_counter]
        imul eax, SDL_FRect_size

        lea r8, [balls]
        mov ecx, [index]
        imul ecx, BallDefinition_size

        movss xmm0, [r8 + rcx + BallDefinition.direction_y]
        ucomiss xmm0, [zero]

        jbe .check_hit_bottom
        jae .check_hit_top

        .check_hit_bottom:
            movss xmm0, [r9 + rax + SDL_FRect.y]
            addss xmm0, [r9 + rax + SDL_FRect.h]

            lea r8, [balls]
            mov ecx, [index]
            imul ecx, BallDefinition_size

            movss xmm1, [r8 + rcx + BallDefinition.y]
            subss xmm1, [r8 + rcx + BallDefinition.radius]
            subss xmm1, xmm0

            ucomiss xmm1, [zero]
            jbe .check_left_side_brick

            jmp .increment

        .check_hit_top:
            movss xmm0, [r9 + rax + SDL_FRect.y]

            lea r8, [balls]
            mov ecx, [index]
            imul ecx, BallDefinition_size

            movss xmm1, [r8 + rcx + BallDefinition.y]
            addss xmm1, [r8 + rcx + BallDefinition.radius]
            subss xmm1, xmm0

            ucomiss xmm1, [zero]
            jae .check_left_side_brick

            jmp .increment

    .check_left_side_brick:
        movss xmm0, [r9 + rax + SDL_FRect.x]

        lea r8, [balls]
        mov ecx, [index]
        imul ecx, BallDefinition_size

        movss xmm1, [r8 + rcx + BallDefinition.x]
        addss xmm1, [r8 + rcx + BallDefinition.radius]

        ucomiss xmm1, xmm0
        jae .check_previous_left_side_brick

        jmp .increment

    .check_previous_left_side_brick:

        movss xmm0, [r9 + rax + SDL_FRect.x]

        lea r8, [balls]
        mov ecx, [index]
        imul ecx, BallDefinition_size

        movss xmm1, [r8 + rcx + BallDefinition.previous_x]
        subss xmm1, [r8 + rcx + BallDefinition.radius]

        subss xmm1, xmm0

        ucomiss xmm1, [zero]
        jbe .hit_brick_side

    .check_right_side_brick:
        movss xmm0, [r9 + rax + SDL_FRect.x]
        addss xmm0, [r9 + rax + SDL_FRect.w]

        lea r8, [balls]
        mov ecx, [index]
        imul ecx, BallDefinition_size

        movss xmm1, [r8 + rcx + BallDefinition.x]
        subss xmm1, [r8 + rcx + BallDefinition.radius]

        ucomiss xmm1, xmm0
        jbe .check_previous_right_side_brick

        jmp .increment

    .check_previous_right_side_brick:
        movss xmm0, [r9 + rax + SDL_FRect.x]
        addss xmm0, [r9 + rax + SDL_FRect.w]

        lea r8, [balls]
        mov ecx, [index]
        imul ecx, BallDefinition_size

        movss xmm1, [r8 + rcx + BallDefinition.previous_x]
        subss xmm1, [r8 + rcx + BallDefinition.radius]

        subss xmm1, xmm0

        ucomiss xmm1, [zero]
        jae .hit_brick_side

        movss xmm0, [r8 + rcx + BallDefinition.direction_y]
        ucomiss xmm0, [zero]

        jbe .check_previous_hit_bottom
        jae .check_previous_hit_top

    .increment:
        inc [brick_counter]
        jmp .check_next_brick


    .check_previous_hit_bottom:
        movss xmm0, [r9 + rax + SDL_FRect.y]
        addss xmm0, [r9 + rax + SDL_FRect.h]

        lea r8, [balls]
        mov ecx, [index]
        imul ecx, BallDefinition_size

        movss xmm1, [r8 + rcx + BallDefinition.previous_y]
        subss xmm1, [r8 + rcx + BallDefinition.radius]

        subss xmm1, xmm0

        ucomiss xmm1, [zero]
        jae .hit_brick

        jmp .increment

    .check_previous_hit_top:
        movss xmm0, [r9 + rax + SDL_FRect.y]

        lea r8, [balls]
        mov ecx, [index]
        imul ecx, BallDefinition_size

        movss xmm1, [r8 + rcx + BallDefinition.previous_y]
        addss xmm1, [r8 + rcx + BallDefinition.radius]

        subss xmm1, xmm0

        ucomiss xmm1, [zero]
        jbe .hit_brick

        jmp .increment

    .hit_brick:
        lea r8, [balls]
        mov ecx, [index]
        imul ecx, BallDefinition_size

        mov DWORD [r8 + rcx + BallDefinition.collision], 1

        movss xmm0, [r8 + rcx + BallDefinition.direction_y]
        movss xmm1, [minus_one]
        mulss xmm0, xmm1
        movss [r8 + rcx + BallDefinition.direction_y], xmm0

        lea r9, [bricks_hits]
        mov eax, [brick_counter]
        imul eax, 4

        cmp [r9 + rax], 0
        jg .reduce_hits

        jmp Continue

    .hit_brick_side:
        movss xmm0, [r9 + rax + SDL_FRect.y]

        lea r8, [balls]
        mov ecx, [index]
        imul ecx, BallDefinition_size

        movss xmm1, [r8 + rcx + BallDefinition.y]
        addss xmm1, [r8 + rcx + BallDefinition.radius]
        subss xmm1, xmm0

        ucomiss xmm1, [zero]

        jae .check_interlace

        jmp .increment

        .check_interlace:
            movss xmm0, [r9 + rax + SDL_FRect.y]
            addss xmm0, [r9 + rax + SDL_FRect.h]

            lea r8, [balls]
            mov ecx, [index]
            imul ecx, BallDefinition_size

            movss xmm1, [r8 + rcx + BallDefinition.y]
            subss xmm1, [r8 + rcx + BallDefinition.radius]
            subss xmm1, xmm0

            ucomiss xmm1, [zero]
            jbe .hit_side

            jmp .increment

        .hit_side:
            lea r8, [balls]
            mov ecx, [index]
            imul ecx, BallDefinition_size

            mov [r8 + rcx + BallDefinition.collision], 1

            movss xmm0, [r8 + rcx + BallDefinition.direction_x]
            movss xmm1, [minus_one]
            mulss xmm0, xmm1
            movss [r8 + rcx + BallDefinition.direction_x], xmm0

            movss xmm0, [r8 + rcx + BallDefinition.direction_y]
            ucomiss xmm0, [zero]
            jbe .reverse_y

            jmp .check_max_hits

        .reverse_y:
            lea r8, [balls]
            mov ecx, [index]
            imul ecx, BallDefinition_size

            movss xmm0, [r8 + rcx + BallDefinition.direction_y]
            movss xmm1, [minus_one]
            mulss xmm0, xmm1
            movss [r8 + rcx + BallDefinition.direction_y], xmm0

        .check_max_hits:
            lea r9, [bricks_hits]
            mov eax, [brick_counter]
            imul eax, 4

            cmp [r9 + rax], 0
            jg .reduce_hits

            jmp Continue

    .reduce_hits:
        mov rdi, [track_brick]
        call PlayAudio

        lea r9, [bricks_hits]
        mov eax, [brick_counter]
        imul eax, 4

        mov r10d, [r9 + rax]
        dec r10d

        mov dword [r9 + rax], r10d

        cmp [r9 + rax], 0
        jle destroy_brick

        cmp [r9 + rax], 1
        je .last_hit

        jmp .continue_reduce_hit

        .last_hit:
            lea r9, [bricks_definitions]
            mov eax, [brick_counter]
            imul eax, BrickDefinition_size

            mov edx, [r9 + rax + BrickDefinition.material]
            dec edx
            mov [r9 + rax + BrickDefinition.material], edx

        .continue_reduce_hit:
            jmp .increment

        destroy_brick:
            mov eax, [destroyed_bricks]
            inc eax
            mov [destroyed_bricks], eax
Continue:
    ret