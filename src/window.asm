bits 64
default rel

%include "../includes/state_machine.inc"

%ifdef WIN32
    extern SDL_Init_sysv
    extern SDL_CreateWindowAndRenderer_sysv
    extern SDL_PollEvent_sysv
    extern SDL_SetRenderDrawColor_sysv
    extern SDL_RenderClear_sysv
    extern SDL_RenderPresent_sysv
    extern SDL_RenderLine_sysv
    extern SDL_DelayPrecise_sysv
    extern SDL_GetTicksNS_sysv
    extern SDL_DestroyRenderer_sysv
    extern SDL_DestroyWindow_sysv
    extern SDL_Quit_sysv
    extern SDL_GetError_sysv
    extern MIX_Init_sysv
    extern MIX_CreateMixerDevice_sysv
    extern MIX_CreateTrack_sysv
    extern MIX_SetTrackAudio_sysv
    extern MIX_Quit_sysv

    %define SDL_Init                      SDL_Init_sysv
    %define SDL_CreateWindowAndRenderer   SDL_CreateWindowAndRenderer_sysv
    %define SDL_PollEvent                 SDL_PollEvent_sysv
    %define SDL_SetRenderDrawColor        SDL_SetRenderDrawColor_sysv
    %define SDL_RenderClear               SDL_RenderClear_sysv
    %define SDL_RenderPresent             SDL_RenderPresent_sysv
    %define SDL_RenderLine                SDL_RenderLine_sysv
    %define SDL_DelayPrecise              SDL_DelayPrecise_sysv
    %define SDL_GetTicksNS                SDL_GetTicksNS_sysv
    %define SDL_DestroyRenderer           SDL_DestroyRenderer_sysv
    %define SDL_DestroyWindow             SDL_DestroyWindow_sysv
    %define SDL_Quit                      SDL_Quit_sysv
    %define SDL_GetError                  SDL_GetError_sysv
    %define MIX_Init                      MIX_Init_sysv
    %define MIX_CreateMixerDevice         MIX_CreateMixerDevice_sysv
    %define MIX_CreateTrack               MIX_CreateTrack_sysv
    %define MIX_SetTrackAudio             MIX_SetTrackAudio_sysv
    %define MIX_Quit                      MIX_Quit_sysv
%else
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
    extern MIX_Init
    extern MIX_CreateMixerDevice
    extern MIX_CreateTrack
    extern MIX_SetTrackAudio
    extern MIX_Quit

    extern MIX_PlayTrack
%endif

extern LoadAudio
extern LoadWAV
extern PlayAudio

extern input
extern state_machine
extern current_state
extern Render
extern GameLoop

extern target_framerate

extern mixer

extern audio_wall
extern audio_brick
extern audio_paddle
extern audio_lose

extern track_wall
extern track_brick
extern track_paddle
extern track_lose

global create_window
global window
global renderer
global delta_time

%define SDL_INIT_AUDIO 0x10
%define SDL_INIT_VIDEO 0x20
%define SDL_INIT_GAMEPAD 0x2000
%define SDL_EVENT_QUIT 0x100

%define SDL_SCANCODE_RETURN 40

%define AUDIO_DEVICE 0xFFFFFFFF

section .rodata
    title       db "Brick Smash", 0
    error_msg   db "SDL error: %s", 10, 0
    debug_msg   db "Debug: %.2f", 10, 0
    delta_msg db "Delta: %.9f", 10, 0
    success_msg db "SDL OK! Janela visivel.", 10, 0

    %ifdef WIN32
        sfx_wall   db "..\audio\wall.wav", 0
        sfx_brick  db "..\audio\brick.wav", 0
        sfx_paddle db "..\audio\paddle.wav", 0
        sfx_lose   db "..\audio\lose.wav", 0
    %else
        sfx_wall   db "../audio/wall.wav", 0
        sfx_brick  db "../audio/brick.wav", 0
        sfx_paddle db "../audio/paddle.wav", 0
        sfx_lose   db "../audio/lose.wav", 0
    %endif

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

    mov edi, SDL_INIT_AUDIO | SDL_INIT_VIDEO | SDL_INIT_GAMEPAD
    call SDL_Init

    test al, al
    jz .error

    call MIX_Init

    mov edi, AUDIO_DEVICE
    xor rsi, rsi

    call MIX_CreateMixerDevice
    mov qword [mixer], rax

    ;=================
    ;TRACK WALL
    ;=================

    mov rdi, [mixer]
    call MIX_CreateTrack

    mov [track_wall], rax

    lea rdi, [sfx_wall]
    call LoadAudio

    mov [audio_wall], rax

    mov rdi, [track_wall]
    mov rsi, [audio_wall]
    call MIX_SetTrackAudio

    ;=================
    ;TRACK BRICK
    ;=================

    mov rdi, [mixer]
    call MIX_CreateTrack

    mov [track_brick], rax

    lea rdi, [sfx_brick]
    call LoadAudio

    mov [audio_brick], rax

    mov rdi, [track_brick]
    mov rsi, [audio_brick]
    call MIX_SetTrackAudio

    ;=================
    ;TRACK PADDLE
    ;=================

    mov rdi, [mixer]
    call MIX_CreateTrack

    mov [track_paddle], rax

    lea rdi, [sfx_paddle]
    call LoadAudio

    mov [audio_paddle], rax

    mov rdi, [track_paddle]
    mov rsi, [audio_paddle]
    call MIX_SetTrackAudio

    ;=================
    ;TRACK LOSE
    ;=================

    mov rdi, [mixer]
    call MIX_CreateTrack

    mov [track_lose], rax

    lea rdi, [sfx_lose]
    call LoadAudio

    mov [audio_lose], rax

    mov rdi, [track_lose]
    mov rsi, [audio_lose]
    call MIX_SetTrackAudio

    lea rdi, [title]
    mov esi, [window_width]
    mov edx, [window_height]
    xor ecx, ecx
    lea r8,  [window]
    lea r9,  [renderer]

    call SDL_CreateWindowAndRenderer

    test al, al
    jz .error

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
    cmp [current_state], STATE_IN_GAME
    jne .window_input

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

    call MIX_Quit

    call SDL_Quit

    xor eax, eax
    pop rbp
    ret

.error:

    call SDL_GetError

    ;mov rsi, rax
    ;lea rdi, [error_msg]
    ;xor eax, eax
    ;call printf

    call SDL_Quit

    mov eax, 1
    pop rbp
    ret