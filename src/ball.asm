bits 64
default rel

%include "../includes/ball_state_machine.inc"
%include "../includes/SDL_structs.inc"

global ball_x
global ball_y
global ball_radius

global ball_color
global ball_color_glow

global offset

global Ball
global Set_Ball_State
global ball_active_collision

extern delta_time
extern paddle_rect

extern top_screen_limit
extern left_screen_limit
extern right_screen_limit

section .data
    zero dd 0.0
    two dd 2.0
    minus_one dd -1.0

    ball_x dd 270.0
    ball_y dd 736.0
    ball_radius dd 12.0
    half_radius dd 6.0

    ball_direction_x dd 1.5
    ball_direction_y dd -1.0
    ball_speed dd 100.0

    current_state dd 1
    const_div dd 2.0
    offset dd 0.0

    ball_active_collision dd 0

    ball_color:
        ;SDL_COLOR 155,177,85,255
        SDL_COLOR 62,164,219,255
        ;SDL_COLOR 0,0,255,255


    ball_color_glow:
        SDL_COLOR 147,209,242,255

section .text

Ball:

    jmp State_Machine

Set_Ball_State:
    mov [current_state], rdi
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

        .movement:
            movss xmm0, [ball_speed]
            mulss xmm0, [delta_time]
            mulss xmm0, [ball_direction_x]

            movss xmm1, [ball_x]
            addss xmm1, xmm0

            movss [ball_x], xmm1

            movss xmm0, [ball_speed]
            mulss xmm0, [delta_time]
            mulss xmm0, [ball_direction_y]

            movss xmm1, [ball_y]
            addss xmm1, xmm0

            movss [ball_y], xmm1

        .ball_collision:
            movss xmm0, [ball_x]

            movss xmm1, [ball_direction_x]
            ucomiss xmm1, [zero]
            jb .sub
            ja .add

            jmp .continue

            .sub:
                subss xmm0, [half_radius]
                jmp .checks

            .add:
                addss xmm0, [half_radius]

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

                jmp .ball_paddle_collision

            .vertical_invert:
                mov [ball_active_collision], 1

                movss xmm0, [ball_direction_y]
                movss xmm1, [minus_one]
                mulss xmm0, xmm1
                movss [ball_direction_y], xmm0

        .ball_paddle_collision:
            movss xmm0, [ball_y]
            movss xmm1, [paddle_rect + SDL_FRect.y]
            subss xmm1, [half_radius]

            ucomiss xmm0, xmm1
            jae .activate_collision_check

            jmp .continue

            .activate_collision_check:
            movss xmm0, [ball_x]

            movss xmm1, [paddle_rect + SDL_FRect.x]
            subss xmm1, [half_radius]

            ucomiss xmm0, xmm1
            jae .check_right_side_paddle

            jmp .continue

            .check_right_side_paddle:
                movss xmm1, [paddle_rect + SDL_FRect.x]
                addss xmm1, [paddle_rect + SDL_FRect.w]
                addss xmm1, [half_radius]

                ucomiss xmm0, xmm1
                jbe .hit_paddle

                jmp .continue

                .hit_paddle:
                    mov [ball_active_collision], 1

                    movss xmm0, [ball_direction_y]
                    movss xmm1, [minus_one]
                    mulss xmm0, xmm1
                    movss [ball_direction_y], xmm0
        ret

        .continue:
            ret