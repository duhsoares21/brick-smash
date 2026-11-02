bits 64
default rel

%include "../includes/ball.inc"

extern delta_time
extern balls
extern total_balls

global Ball_Animation

section .data
    ball_animation_time dd 0
    ball_animation_duration dd 25
    ball_counter dd 0

section .text

Ball_Animation:
    mov eax, [total_balls]
    cmp [ball_counter], eax

    je .loop_end

    jmp .proceed

    .loop_end:
        mov [ball_counter], 0

    .proceed:
        lea r8, [balls]
        mov ebx, [ball_counter]
        imul ebx, BallDefinition_size

        cmp [r8 + rbx + BallDefinition.collision], 0
        je .end

        mov eax, [ball_animation_time]
        inc eax

        mov [ball_animation_time], eax

        cmp eax, [ball_animation_duration]
        je .reset

        jmp .end

    .reset:
        mov [ball_animation_time], 0
        mov [r8 + rbx + BallDefinition.collision], 0

    .end:
       mov eax, [ball_counter]
       inc eax
       mov [ball_counter], eax
       ret