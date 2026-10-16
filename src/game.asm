bits 64
default rel

%include "../includes/SDL_structs.inc"
%include "../includes/materials.inc"
%include "../includes/level_1.inc"

extern Paddle
extern Ball
extern Ball_Wall_Collision
extern Ball_Paddle_Collision
extern Ball_Brick_Collision
extern Ball_Animation
extern Brick

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

section .data
    current_level dd 1

    base_framerate dd 60
    target_framerate dd 144

section .text

GameStart:
    call LoadLevel
    ret

LoadLevel:

    lea rsi, [level_01_bricks]
    mov ecx, level_01_brick_count

    mov [level_brick_count], ecx
    mov [current_brick_count], ecx

    .next_brick:
        mov ecx, [current_brick_count]
        cmp ecx, 0
        jz .done

    mov eax, [level_brick_count]
    sub eax, [current_brick_count]

    mov [current_brick_index], eax

    mov eax, [rsi + BrickDefinition.material]; id do material
    dec eax; Obtém index da tabela

    lea rdx, [material_table]; acessa endereço da tabela em rdx
    mov rdx, [rdx + rax * 8]; calcula endereço com base no index

    ;=====================
    ; RDI = Color
    ; RDX = Width Size In Blocks (Default = 3)
    ; RCX = Height Size In Blocks (Default = 1)]
    ; XMMO = X
    ; XMM1 = Y
    ; R8D = Index
    ;=====================

    mov rdi, rdx
    mov rdx, [rsi + BrickDefinition.width_blocks]
    mov rcx, [rsi + BrickDefinition.height_blocks]
    movss xmm0, [rsi + BrickDefinition.x]
    movss xmm1, [rsi + BrickDefinition.y]
    mov r8d, [current_brick_index]

    call Brick

    add rsi, BrickDefinition_size
    mov ecx, [current_brick_count]
    dec ecx
    mov [current_brick_count], ecx

    jmp .next_brick

    .done
    ret

GameLoop:
    call Paddle
    call Ball_Animation
    call Ball
    call Ball_Paddle_Collision
    call Ball_Wall_Collision
    call Ball_Brick_Collision
    ret
