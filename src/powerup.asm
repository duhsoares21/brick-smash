bits 64
default rel

%include "../includes/ball.inc"
%include "../includes/ball_state_machine.inc"
%include "../includes/powerups.inc"

extern balls
extern total_balls

extern Initialize_Ball

global current_power
global previous_power
global active_extra_balls
global PowerUps

section .data
    ball_counter dd 0
    active_extra_balls dd 0

    current_power dd POWER_NONE
    previous_power dd POWER_NONE
    minus_one dd -1.0
    zero dd 0.0
    fifty dd 50.0

    ball_color:
        SDL_COLOR 255,140,0,255

    ball_color_glow:
        SDL_COLOR 255,180,50,255

section .text

PowerUps:
    call State_Machine
    ret

State_Machine:
    cmp [current_power], POWER_NONE
    je .check_powers

    mov eax, [previous_power]

    cmp [current_power], eax
    je .end

    .check_powers:

        cmp [current_power], POWER_3_BALLS
        je .power_3_balls

        cmp [current_power], POWER_STICKY_PADDLE
        je .power_stick_paddle

        cmp [current_power], POWER_LARGE_PADDLE
        je .power_large_paddle

        jmp .end

    .power_3_balls:

        mov [previous_power], POWER_3_BALLS
        mov dword [ball_counter], 0

        .check_is_extra:

            mov eax, [total_balls]
            cmp [ball_counter], eax
            je .create_new_ball

            mov eax, [ball_counter]
            lea r8, [balls]
            imul eax, BallDefinition_size

            cmp byte [r8 + rax + BallDefinition.is_extra], 1
            je .check_is_active

            jmp .next_ball

        .check_is_active:
            mov eax, [ball_counter]
            lea r8, [balls]
            imul eax, BallDefinition_size

            cmp byte [r8 + rax + BallDefinition.is_active], 0
            je .reuse_ball

            jmp .next_ball

        .reuse_ball:
            mov eax, [ball_counter]
            lea r8, [balls]
            imul eax, BallDefinition_size

            movss xmm0, [r8 + BallDefinition.x]

            cmp [active_extra_balls], 0
            je .adds_fifty

            jmp .subs_fifty

            .adds_fifty:
                addss xmm0, [fifty]
                movss xmm3, [r8 + BallDefinition.direction_x]
                jmp .define_ball

            .subs_fifty:
                subss xmm0, [fifty]
                movss xmm3, [r8 + BallDefinition.direction_x]
                mulss xmm3, [minus_one]

            .define_ball:
                movss xmm1, [r8 + BallDefinition.y]
                movss xmm2, [r8 + BallDefinition.radius]

                movss xmm4, [r8 + BallDefinition.direction_y]
                movss xmm5, [r8 + BallDefinition.speed]

                movss [r8 + rax + BallDefinition.x], xmm0
                movss [r8 + rax + BallDefinition.y], xmm1
                movss [r8 + rax + BallDefinition.radius], xmm2
                movss [r8 + rax + BallDefinition.direction_x], xmm3
                movss [r8 + rax + BallDefinition.direction_y], xmm4
                movss [r8 + rax + BallDefinition.speed], xmm5
                movss xmm6, [zero]
                movss [r8 + rax + BallDefinition.offset], xmm6
                mov [r8 + rax + BallDefinition.state], BALL_STATE_FREE

                mov byte [r8 + rax + BallDefinition.is_extra], 1
                mov byte [r8 + rax + BallDefinition.is_active], 1

                inc dword [active_extra_balls]

                jmp .next_ball

        .create_new_ball:

            cmp [active_extra_balls], 2
            je .end

            lea r8, [balls]

            mov edi, [total_balls]

            movss xmm0, [r8 + BallDefinition.x]

            cmp [active_extra_balls], 0
            je .create_adds_fifty

            jmp .create_subs_fifty

            .create_adds_fifty:
                addss xmm0, [fifty]
                movss xmm3, [r8 + BallDefinition.direction_x]
                jmp .create_define_ball

            .create_subs_fifty:
                subss xmm0, [fifty]
                movss xmm3, [r8 + BallDefinition.direction_x]
                mulss xmm3, [minus_one]

            .create_define_ball:
                movss xmm1, [r8 + BallDefinition.y]
                movss xmm2, [r8 + BallDefinition.radius]
                movss xmm4, [r8 + BallDefinition.direction_y]
                movss xmm5, [r8 + BallDefinition.speed]
                movss xmm6, [zero]

                mov esi, BALL_STATE_FREE
                mov edx, 0

                lea rcx, [ball_color]
                lea r8, [ball_color_glow]
                mov r9b, 1

                sub rsp, 16
                    mov byte [rsp + 8], 1
                    call Initialize_Ball
                add rsp, 16

                inc dword [active_extra_balls]
                jmp .create_new_ball

        .next_ball:
           inc dword [ball_counter]
           jmp .check_is_extra

        jmp .end

        .power_stick_paddle:
            ret

        .power_large_paddle:
            ret

    .end:
        ret

