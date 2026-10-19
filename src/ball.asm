bits 64
default rel

%include "../includes/ball_state_machine.inc"
%include "../includes/bricks.inc"
%include "../includes/materials.inc"
%include "../includes/SDL_structs.inc"

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

global ball_x_start
global ball_x
global ball_y
global ball_radius

global ball_color
global ball_color_glow

global offset

global Ball
global Ball_Wall_Collision
global Ball_Paddle_Collision
global Ball_Brick_Collision
global Set_Ball_State
global ball_active_collision

section .bss
    brick_counter resd 1
    previous_ball_x resd 1
    previous_ball_y resd 1

section .data
    zero dd 0.0
    two dd 2.0
    twenty dd 20.0
    minus_one dd -1.0

    ball_x_start dd 270.0
    ball_x dd 270.0
    ball_y dd 736.0
    ball_radius dd 12.0

    ball_direction_x dd 1.0
    ball_direction_y dd -1.0
    ball_speed dd 300.0

    current_state dd 1
    offset dd 0.0

    ball_active_collision dd 0

    ball_color:
        SDL_COLOR 62,164,219,255

    ball_color_glow:
        SDL_COLOR 147,209,242,255

section .text

Ball:

    jmp State_Machine

Set_Ball_State:
    mov [current_state], edi
    ret

State_Machine:
        cmp dword [current_state], BALL_STATE_STICKY
        je .sticky

        cmp dword [current_state], BALL_STATE_FREE
        je .free

        jmp Continue

        .sticky:
            movss xmm0, [paddle_rect + SDL_FRect.x]

            movss xmm1, [paddle_rect + SDL_FRect.w]
            divss xmm1, [two]

            addss xmm0, xmm1 ;Paddle Center

            movss xmm1, [offset]
            addss xmm0, xmm1

            movss [ball_x], xmm0

            movss xmm0, [paddle_rect + SDL_FRect.y]
            subss xmm0, [ball_radius]

            movss [ball_y], xmm0

            ret

        .free:

        .movement:
            movss xmm0, [ball_speed]
            mulss xmm0, [delta_time]
            mulss xmm0, [ball_direction_x]

            movss xmm1, [ball_x]
            movss [previous_ball_x], xmm1

            addss xmm1, xmm0

            movss [ball_x], xmm1

            movss xmm0, [ball_speed]
            mulss xmm0, [delta_time]
            mulss xmm0, [ball_direction_y]

            movss xmm1, [ball_y]
            movss [previous_ball_y], xmm1
            addss xmm1, xmm0

            movss [ball_y], xmm1

            ucomiss xmm1, [bottom_screen_limit]
            ja .change_ball_state

            jmp Continue

            .change_ball_state:
                push rbp
                mov rbp, rsp

                movss xmm0, [zero]
                movss [offset], xmm0

                mov rdi, 1
                call Set_Ball_State

                pop rbp


Ball_Wall_Collision:
    movss xmm0, [ball_x]

    movss xmm1, [ball_direction_x]
    ucomiss xmm1, [zero]
    jb .sub
    ja .add

    jmp Continue

        .sub:
            subss xmm0, [ball_radius]
            jmp .checks

        .add:
            addss xmm0, [ball_radius]

        .checks:

        ucomiss xmm0, [left_screen_limit]
        jbe .invert

        ucomiss xmm0, [right_screen_limit]
        jae .invert

        jmp .vertical_ball_collision

        .invert:
            mov [ball_active_collision], 1

            movss xmm0, [ball_direction_x]
            movss xmm1, [minus_one]
            mulss xmm0, xmm1
            movss [ball_direction_x], xmm0

        .vertical_ball_collision:
            movss xmm0, [ball_y]
            subss xmm0, [ball_radius]

            ucomiss xmm0, [top_screen_limit]
            jbe .vertical_invert

            jmp Continue

        .vertical_invert:
            mov [ball_active_collision], 1

            movss xmm0, [ball_direction_y]
            movss xmm1, [minus_one]
            mulss xmm0, xmm1
            movss [ball_direction_y], xmm0

            ret

    Ball_Paddle_Collision:
            movss xmm0, [ball_direction_y]
            ucomiss xmm0, [zero]
            jb Continue

            movss xmm0, [ball_y]
            movss xmm1, [paddle_rect + SDL_FRect.y]
            subss xmm1, [ball_radius]

            ucomiss xmm0, xmm1
            jae .check_vertical_bottom_paddle

            jmp Continue

        .check_vertical_bottom_paddle:

            movss xmm0, [ball_y]
            movss xmm1, [paddle_rect + SDL_FRect.y]
            addss xmm1, [paddle_rect + SDL_FRect.h]

            subss xmm1, [ball_radius]

            ucomiss xmm0, xmm1
            jbe .check_left_side_paddle

            jmp Continue

        .check_left_side_paddle:
            movss xmm0, [ball_x]

            movss xmm1, [paddle_rect + SDL_FRect.x]
            subss xmm1, [ball_radius]

            ucomiss xmm0, xmm1
            ja .check_right_side_paddle

            jmp Continue

        .check_right_side_paddle:
            movss xmm1, [paddle_rect + SDL_FRect.x]
            addss xmm1, [paddle_rect + SDL_FRect.w]
            addss xmm1, [ball_radius]

            ucomiss xmm0, xmm1
            jbe .hit_paddle

            jmp Continue

        .hit_paddle:

            movss xmm0, [ball_x]

            movss xmm1, [paddle_rect + SDL_FRect.x]

            movss xmm2, [paddle_rect + SDL_FRect.w]
            divss xmm2, [two]

            addss xmm1, xmm2

            subss xmm0, xmm1
            movss dword [offset], xmm0

        .check_corner_range:
            movss xmm0, [paddle_rect + SDL_FRect.x]
            addss xmm0, [twenty]

            movss xmm1, [ball_x]

            ucomiss xmm1, xmm0
            jb .hit_left_corner

            movss xmm0, [paddle_rect + SDL_FRect.x]
            addss xmm0, [paddle_rect + SDL_FRect.w]
            subss xmm0, [twenty]

            movss xmm1, [ball_x]

            ucomiss xmm1, xmm0
            jae .hit_right_corner

            jmp .hit_surface

        .hit_left_corner:
            movss xmm0, [ball_direction_x]
            ucomiss xmm0, [zero]
            ja .reverse_x

            jmp .hit_surface

        .hit_right_corner:
            movss xmm0, [ball_direction_x]
            ucomiss xmm0, [zero]
            jb .reverse_x

            jmp .hit_surface

        .reverse_x:
            movss xmm0, [ball_direction_x]
            movss xmm1, [minus_one]
            mulss xmm0, xmm1
            movss [ball_direction_x], xmm0

            movss xmm0, [ball_direction_y]
            movss xmm1, [paddle_rect + SDL_FRect.y]

            movss xmm2, [paddle_rect + SDL_FRect.h]
            divss xmm2, [two]

            addss xmm1, xmm2

            subss xmm0, [ball_radius]

            ucomiss xmm0, xmm1
            jbe Continue

        .hit_surface:
            movss xmm0, [ball_direction_y]
            ucomiss xmm0, [zero]

            jbe Continue

            mov [ball_active_collision], 1

            movss xmm0, [ball_direction_y]
            movss xmm1, [minus_one]
            mulss xmm0, xmm1
            movss [ball_direction_y], xmm0

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

            movss xmm0, [ball_direction_y]
            ucomiss xmm0, [zero]

            jbe .check_hit_bottom
            jae .check_hit_top

            .check_hit_bottom:
                movss xmm0, [r9 + rax + SDL_FRect.y]
                addss xmm0, [r9 + rax + SDL_FRect.h]
                movss xmm1, [ball_y]
                subss xmm1, [ball_radius]
                subss xmm1, xmm0

                ucomiss xmm1, [zero]
                jbe .check_left_side_brick

                jmp .increment

            .check_hit_top
                movss xmm0, [r9 + rax + SDL_FRect.y]
                movss xmm1, [ball_y]
                addss xmm1, [ball_radius]
                subss xmm1, xmm0

                ucomiss xmm1, [zero]
                jae .check_left_side_brick

                jmp .increment

        .check_left_side_brick:
            movss xmm0, [r9 + rax + SDL_FRect.x]
            movss xmm1, [ball_x]
            addss xmm1, [ball_radius]

            ucomiss xmm1, xmm0
            jae .check_previous_left_side_brick

            jmp .increment

        .check_previous_left_side_brick:

            movss xmm0, [r9 + rax + SDL_FRect.x]
            movss xmm1, [previous_ball_x]
            subss xmm1, [ball_radius]

            subss xmm1, xmm0

            ucomiss xmm1, [zero]
            jbe .hit_brick_side

        .check_right_side_brick:
            movss xmm0, [r9 + rax + SDL_FRect.x]
            addss xmm0, [r9 + rax + SDL_FRect.w]
            movss xmm1, [ball_x]
            subss xmm1, [ball_radius]

            ucomiss xmm1, xmm0
            jbe .check_previous_right_side_brick

            jmp .increment

        .check_previous_right_side_brick:
            movss xmm0, [r9 + rax + SDL_FRect.x]
            addss xmm0, [r9 + rax + SDL_FRect.w]
            movss xmm1, [previous_ball_x]
            subss xmm1, [ball_radius]

            subss xmm1, xmm0

            ucomiss xmm1, [zero]
            jae .hit_brick_side

            movss xmm0, [ball_direction_y]
            ucomiss xmm0, [zero]

            jbe .check_previous_hit_bottom
            jae .check_previous_hit_top

        .increment:
            inc [brick_counter]
            jmp .check_next_brick


        .check_previous_hit_bottom:
            movss xmm0, [r9 + rax + SDL_FRect.y]
            addss xmm0, [r9 + rax + SDL_FRect.h]
            movss xmm1, [previous_ball_y]
            subss xmm1, [ball_radius]

            subss xmm1, xmm0

            ucomiss xmm1, [zero]
            jae .hit_brick

            jmp .increment

        .check_previous_hit_top:
            movss xmm0, [r9 + rax + SDL_FRect.y]
            movss xmm1, [previous_ball_y]
            addss xmm1, [ball_radius]

            subss xmm1, xmm0

            ucomiss xmm1, [zero]
            jbe .hit_brick

            jmp .increment

        .hit_brick:
            mov [ball_active_collision], 1

            movss xmm0, [ball_direction_y]
            movss xmm1, [minus_one]
            mulss xmm0, xmm1
            movss [ball_direction_y], xmm0

            lea r9, [bricks_hits]
            mov eax, [brick_counter]
            imul eax, 4

            cmp [r9 + rax], 0
            jg .reduce_hits

            jmp Continue

        .hit_brick_side:

            movss xmm0, [r9 + rax + SDL_FRect.y]
            movss xmm1, [ball_y]
            addss xmm1, [ball_radius]
            subss xmm1, xmm0

            ucomiss xmm1, [zero]

            jae .check_interlace

            jmp .increment

            .check_interlace:
                movss xmm0, [r9 + rax + SDL_FRect.y]
                addss xmm0, [r9 + rax + SDL_FRect.h]

                movss xmm1, [ball_y]
                subss xmm1, [ball_radius]
                subss xmm1, xmm0

                ucomiss xmm1, [zero]
                jbe .hit_side

                jmp .increment

            .hit_side:
                mov [ball_active_collision], 1

                movss xmm0, [ball_direction_x]
                movss xmm1, [minus_one]
                mulss xmm0, xmm1
                movss [ball_direction_x], xmm0

                movss xmm0, [ball_direction_y]
                ucomiss xmm0, [zero]
                jbe .reverse_y

                jmp .check_max_hits

            .reverse_y:
                movss xmm0, [ball_direction_y]
                movss xmm1, [minus_one]
                mulss xmm0, xmm1
                movss [ball_direction_y], xmm0

            .check_max_hits:
                lea r9, [bricks_hits]
                mov eax, [brick_counter]
                imul eax, 4

                cmp [r9 + rax], 0
                jg .reduce_hits

                jmp Continue

        .reduce_hits:
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