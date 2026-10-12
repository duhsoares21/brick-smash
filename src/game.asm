bits 64
default rel

extern Paddle
extern Ball
extern Ball_Animation

global GameLoop

global base_framerate
global target_framerate

section .data

    base_framerate dd 60
    target_framerate dd 144

section .text

GameLoop:
    call Paddle
    call Ball_Animation
    call Ball
    ret
