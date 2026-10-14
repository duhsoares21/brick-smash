bits 64
default rel

%include "../includes/SDL_structs.inc"

%define MAX_BRICKS 256

extern renderer

global bricks_colors
global bricks_rectangles

global Brick

section .bss
    width resd 1
    height resd 1
    x resd 1
    y resd 1
    index resd 1
    material resd 1
    width_in_blocks resd 1
    height_in_blocks resd 1

    bricks_colors: resb SDL_Color_size * MAX_BRICKS
    bricks_rectangles: resb SDL_FRect_size * MAX_BRICKS

section .data
    base_width dd 28.0
    base_height dd 28.0

section .text

Brick:

    ;=====================
    ; RDI = Color
    ; RSI = Material (1 - Rock, 2 - Iron, 3 - Gold; Default = 1)
    ; RDX = Width Size In Blocks (Default = 3)
    ; RCX = Height Size In Blocks (Default = 1)]
    ; XMMO = X
    ; XMM1 = Y
    ;=====================

    mov [index], r8d

    lea r9, [bricks_colors]
    mov eax, [index]
    imul eax, SDL_Color_size

    mov r10b, [rdi + SDL_Color.r]
    mov byte [r9 + rax + SDL_Color.r], r10b

    mov r10b, [rdi + SDL_Color.g]
    mov byte [r9 + rax + SDL_Color.g], r10b

    mov r10b, [rdi + SDL_Color.b]
    mov byte [r9 + rax + SDL_Color.b], r10b

    mov r10b, [rdi + SDL_Color.a]
    mov byte [r9 + rax + SDL_Color.a], r10b

    mov [width_in_blocks], edx
    mov [height_in_blocks], ecx
    movss dword [x], xmm0
    movss dword [y], xmm1

    cvtsi2ss xmm0, dword [width_in_blocks]
    mulss xmm0, [base_width]
    movss [width], xmm0

    cvtsi2ss xmm0, dword [height_in_blocks]
    mulss xmm0, [base_height]
    movss [height], xmm0

    movss xmm0, [x]

    lea r9, [bricks_rectangles]
    mov eax, [index]
    imul eax, SDL_FRect_size

    movss xmm0, [x]
    movss [r9 + rax + SDL_FRect.x], xmm0

    movss xmm0, [y]
    movss [r9 + rax + SDL_FRect.y], xmm0

    movss xmm0, [width]
    movss [r9 + rax + SDL_FRect.w], xmm0

    movss xmm0, [height]
    movss [r9 + rax + SDL_FRect.h], xmm0

    ret