bits 64
default rel

extern SDL_Init
extern SDL_CreateWindowAndRenderer
extern SDL_PollEvent
extern SDL_SetRenderDrawColor
extern SDL_RenderClear
extern SDL_RenderPresent
extern SDL_RenderLine
extern SDL_DelayPrecise
extern SDL_GetTicksNS
extern SDL_DestroyRenderer
extern SDL_DestroyWindow
extern SDL_Quit
extern SDL_GetError

extern printf

extern input
extern state_machine
extern Render
extern GameLoop

extern target_framerate

global create_window
global window
global renderer
global delta_time

%define SDL_INIT_VIDEO 0x20
%define SDL_INIT_GAMEPAD 0x2000
%define SDL_EVENT_QUIT 0x100

%define SDL_SCANCODE_RETURN 40

section .rodata
    title       db "Brick Smash", 0
    error_msg   db "SDL error: %s", 10, 0
    debug_msg   db "Debug: %.2f", 10, 0
    delta_msg db "Delta: %.9f", 10, 0
    success_msg db "SDL OK! Janela visivel.", 10, 0

    ns_per_second dd 1000000000.0

section .data
    window_width dd 540
    window_height dd 800

    grid_size_x dd 28.0
    grid_size_y dd 28.0

    grid_x dd 0.0
    grid_y dd 0.0

    float_zero dd 0.0

section .bss
    window      resq 1
    renderer    resq 1

    previous_time   resq 1
    frame_start     resq 1
    delta_time      resd 1

    event       resb 128

section .text

create_window:
    push rbp
    mov rbp, rsp

    ; --------------------------------------------------
    ; SDL_Init(SDL_INIT_VIDEO | SDL_INIT_GAMEPAD)
    ; --------------------------------------------------

    mov edi, SDL_INIT_VIDEO | SDL_INIT_GAMEPAD
    call SDL_Init

    test al, al
    jz .error

    lea rdi, [title]
    mov esi, [window_width]
    mov edx, [window_height]
    xor ecx, ecx
    lea r8,  [window]
    lea r9,  [renderer]

    call SDL_CreateWindowAndRenderer

    test al, al
    jz .error

    lea rdi, [success_msg]
    mov al, 0;Quantos Float Points foram usados

    call printf

    call state_machine

    call SDL_GetTicksNS
    mov [previous_time], rax ;Garante que exista um previous_time na primeira execução

.main_loop:
    ; --------------------------------------------------
    ; SDL_GetTicksNS -> Quantos nanosegundos se passaram
    ; desde que o SDL foi iniciado
    ;
    ; Esse código calcula a diferença entre o tempo anterior e o tempo atual em nanosegundos
    ; Ele também armazena os novos previous_time e frame_start
    ; --------------------------------------------------
    call SDL_GetTicksNS
    mov rcx, [previous_time]

    mov [previous_time], rax
    mov [frame_start], rax ;Necessário para calculo do limitador de FPS, pois previous_time será atualizado

    sub rax, rcx ;Subtraimos rcx (NS antes do Mainloop) - rax (NS após MainLoop) e temos nosso primeiro deltaTime

    cvtsi2ss xmm0, rax ;Converte o valor inteiro em rax para ponto flutuante e salva em xmm0
    divss xmm0, [ns_per_second] ;Transforma o resultado de nanosegundos para segundos

    movss [delta_time], xmm0 ;Armazena os segundos em delta_time

    cvtss2sd xmm0, xmm0

    ; --------------------------------------------------
    ; Processa eventos
    ; --------------------------------------------------

.poll_events:

    lea rdi, [event]
    call SDL_PollEvent

    test al, al
    jz .window_game_loop

    cmp dword [event], SDL_EVENT_QUIT
    je .quit

    jmp .poll_events

.window_game_loop:
    call GameLoop

.window_input:
    call input

.window_render:

    ; --------------------------------------------------
    ; Renderiza um frame
    ; --------------------------------------------------

    mov rdi, [renderer]
    mov esi, 13
    mov edx, 29
    mov ecx, 16
    mov r8d, 255
    call SDL_SetRenderDrawColor

    mov rdi, [renderer]
    call SDL_RenderClear

    mov rdi, [renderer]
    mov esi, 31
    mov edx, 63
    mov ecx, 37
    mov r8d, 255
    call SDL_SetRenderDrawColor

    movss xmm0, [grid_size_x]
    movss [grid_x], xmm0

    movss xmm0, [grid_size_y]
    movss [grid_y], xmm0

    .draw_vertical_lines:

        movss xmm0, [grid_x]

        mov eax, [window_width]
        cvtsi2ss xmm1, eax

        ucomiss xmm0, xmm1
        jae .draw_horizontal_lines

        .render_vertical_line:
            mov rdi, [renderer]
            movss xmm0, [grid_x]
            movss xmm1, [float_zero]
            movss xmm2, [grid_x]

            mov eax, [window_height]
            cvtsi2ss xmm3, eax

            call SDL_RenderLine

            movss xmm0, [grid_x]
            addss xmm0, [grid_size_x]
            movss [grid_x], xmm0

            jmp .draw_vertical_lines

    .draw_horizontal_lines:
        movss xmm0, [grid_y]

        mov eax, [window_height]
        cvtsi2ss xmm1, eax

        ucomiss xmm0, xmm1
        jae .continue_render

        .render_horizontal_line:
            mov rdi, [renderer]
            movss xmm0, [float_zero]
            movss xmm1, [grid_y]

            mov eax, [window_width]
            cvtsi2ss xmm3, eax

            movss xmm2, xmm3

            movss xmm3, [grid_y]

            call SDL_RenderLine

            movss xmm0, [grid_y]
            addss xmm0, [grid_size_y]
            movss [grid_y], xmm0

            jmp .draw_horizontal_lines

    .continue_render:
        call Render

    mov rdi, [renderer]
    call SDL_RenderPresent

    call SDL_GetTicksNS ;Retorna quantos nanosegundos se passaram desde que o SDL inicial
    sub rax, [frame_start] ; Subtrai frame_start do valor (rax - frame_start)
    mov r8, rax ; O resultado da subtração vai para R8

    ;--------------------------
    ;Esse código obtem o valor em nanosegundos
    ;que idealmente deveria ser retornado
    ;com base no target_framerate
    ;--------------------------
    mov eax, 1_000_000_000
    xor edx, edx
    mov ecx, [target_framerate]
    div ecx

    ;--------------------------
    ;Se o valor de R8 (tempo desde frame_start)
    ;For maior que rax (tempo ideal)
    ;Pulamos para .skip_delay
    ;--------------------------
    cmp r8, rax
    jae .skip_delay

    ;--------------------------
    ;Caso contrário subtraímos a diferença (rax - r8)
    ;E passamos o valor para RDI que funciona como
    ;primeiro parâmetro de SDL_DelayPrecise
    ;isso garante que
    ;o delay compense pelo tempo já passado e
    ;tente sempre manter o tempo do
    ;target_framerate ideal
    ;--------------------------
    sub rax, r8

    mov rdi, rax
    call SDL_DelayPrecise

.skip_delay:
    jmp .main_loop

.quit:

    mov rdi, [renderer]
    call SDL_DestroyRenderer

    mov rdi, [window]
    call SDL_DestroyWindow

    call SDL_Quit

    xor eax, eax
    pop rbp
    ret

.error:

    call SDL_GetError

    mov rsi, rax
    lea rdi, [error_msg]
    xor eax, eax
    call printf

    call SDL_Quit

    mov eax, 1
    pop rbp
    ret