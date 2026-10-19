bits 64
default rel

%include "../includes/SDL_structs.inc"
%include "../includes/bricks.inc"
%include "../includes/materials.inc"

%define MAX_BRICKS 256

extern renderer

global bricks_rectangles
global bricks_definitions
global bricks_hits
global destroyed_bricks

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
    destroyed_bricks resd 1

    bricks_rectangles: resb SDL_FRect_size * MAX_BRICKS
    bricks_definitions: resb BrickDefinition_size * MAX_BRICKS
    bricks_hits: resd 1 * MAX_BRICKS

section .data
    base_width dd 28.0
    base_height dd 28.0

section .text

Brick:

    ;=====================
    ; RDI = Color
    ; RSI = Material
    ; RDX = Width Size In Blocks (Default = 3)
    ; RCX = Height Size In Blocks (Default = 1)]
    ; XMMO = X
    ; XMM1 = Y
    ;=====================

    mov [index], r8d

    lea r9, [bricks_definitions]
    mov eax, [index]
    imul eax, BrickDefinition_size

    ;.x:                 resd 1 ; float
    ;.y:                 resd 1 ; float
    ;.width_blocks:      resd 1 ; inteiro
    ;.height_blocks:     resd 1 ; inteiro
    ;.material:          resd 1 ; inteiro

    movss xmm0, [rdi + BrickDefinition.x]
    movss dword [r9 + rax + BrickDefinition.x], xmm0

    movss xmm0, [rdi + BrickDefinition.y]
    movss dword [r9 + rax + BrickDefinition.y], xmm0

    mov r10d, [rdi + BrickDefinition.width_blocks]
    mov dword [r9 + rax + BrickDefinition.width_blocks], r10d

    mov r10d, [rdi + BrickDefinition.height_blocks]
    mov dword [r9 + rax + BrickDefinition.height_blocks], r10d

    mov r10d, [rdi + BrickDefinition.material]
    mov dword [r9 + rax + BrickDefinition.material], r10d

    dec r10d; Obtém index da tabela

    lea r12, [material_table]; acessa endereço da tabela em rdx
    mov r12, [r12 + r10 * 8]; calcula endereço com base no index

    lea r9, [bricks_hits]
    mov eax, [index]
    imul eax, 4

    mov edx, [r12 + BrickMaterial.max_hits]
    mov [r9 + rax], edx

    lea r9, [bricks_definitions]
    mov eax, [index]
    imul eax, BrickDefinition_size

    mov edx, [r9 + rax + BrickDefinition.width_blocks]
    mov [width_in_blocks], edx

    mov edx, [r9 + rax + BrickDefinition.height_blocks]
    mov [height_in_blocks], edx

    movss xmm0, [r9 + rax + BrickDefinition.x]
    movss dword [x], xmm0

    movss xmm0, [r9 + rax + BrickDefinition.y]
    movss dword [y], xmm0

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