bits 64
default rel

extern delta_time
extern ball_active_collision

global Ball_Animation

section .data
    ball_animation_time dd 0
    ball_animation_duration dd 25

section .text

Ball_Animation:
    cmp [ball_active_collision], 0
    je .end

    mov eax, [ball_animation_time]
    inc eax

    mov [ball_animation_time], eax

    cmp eax, [ball_animation_duration]
    je .reset

    jmp .end

    .reset:
        mov [ball_animation_time], 0
        mov [ball_active_collision], 0

    .end:
       ret