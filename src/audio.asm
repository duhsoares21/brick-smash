bits 64
default rel

%ifdef WIN32
    extern SDL_LoadWAV_sysv
    extern SDL_OpenAudioDeviceStream_sysv
    extern SDL_PutAudioStreamData_sysv
    extern SDL_ResumeAudioStreamDevice_sysv
    extern SDL_DestroyAudioStream_sysv
    extern SDL_free_sysv
    extern SDL_GetError_sysv
    extern SDL_GetBasePath_sysv
    extern SDL_asprintf_sysv
    extern SDL_Log_sysv

    extern MIX_LoadAudio_sysv
    extern MIX_PlayTrack_sysv

    %define SDL_LoadWAV SDL_LoadWAV_sysv
    %define SDL_OpenAudioDeviceStream SDL_OpenAudioDeviceStream_sysv
    %define SDL_PutAudioStreamData SDL_PutAudioStreamData_sysv
    %define SDL_ResumeAudioStreamDevice SDL_ResumeAudioStreamDevice_sysv
    %define SDL_DestroyAudioStream SDL_DestroyAudioStream_sysv
    %define SDL_free SDL_free_sysv
    %define SDL_GetError SDL_GetError_sysv
    %define SDL_GetBasePath SDL_GetBasePath_sysv
    %define SDL_asprintf SDL_asprintf_sysv
    %define SDL_Log SDL_Log_sysv

    %define MIX_LoadAudio MIX_LoadAudio_sysv
    %define MIX_PlayTrack MIX_PlayTrack_sysv
%else
    extern SDL_LoadWAV
    extern SDL_OpenAudioDeviceStream
    extern SDL_PutAudioStreamData
    extern SDL_ResumeAudioStreamDevice
    extern SDL_DestroyAudioStream
    extern SDL_free
    extern SDL_GetError
    extern SDL_GetBasePath
    extern SDL_asprintf
    extern SDL_Log

    extern MIX_LoadAudio
    extern MIX_PlayTrack
%endif


global mixer

global audio_wall
global audio_brick
global audio_paddle
global audio_lose

global track_wall
global track_brick
global track_paddle
global track_lose

global LoadAudio
global LoadWAV
global PlayAudio
global FreeWAV

section .bss
    mixer resq 1

    audio_wall   resq 1
    audio_brick  resq 1
    audio_paddle resq 1
    audio_lose   resq 1

    track_wall resq 1
    track_brick resq 1
    track_paddle resq 1
    track_lose resq 1

    fname resq 1
    path resq 1
    audio resq 1

section .rodata
    fname_string db "%s%s", 0
    error_message db "Couldn't load %s: %s", 0

section .text

;=========================
; RDI = address filename
;=========================
LoadAudio:
    push rbp
    mov rbp, rsp

    mov qword [fname], rdi

    lea rdi, [path]
    lea rsi, [fname_string]

    call SDL_GetBasePath
    mov rdx, rax

    mov rcx, [fname]
    call SDL_asprintf

    cmp eax, 0
    jl .error

    ;audio = MIX_LoadAudio(mixer, path, false);

    mov rdi, [mixer]
    mov rsi, [path]
    xor rdx, rdx
    call MIX_LoadAudio

    test rax, rax
    jz .error

    mov qword [audio], rax

    mov rdi, [path]
    call SDL_free

    mov rax, [audio]

    jmp .done

    .error:
        lea rdi, [error_message]
        mov rsi, [path]

        call SDL_GetError
        mov rdx, rax

        call SDL_Log

    .done:
    pop rbp

    ret

;=========================
; RDI = Track
;=========================
PlayAudio:
    push rbp
    mov rbp, rsp
    sub rsp, 8

    xor rsi, rsi
    call MIX_PlayTrack

    jmp .done

   .error:
       call SDL_GetError

   .done:
       add rsp, 8
       pop rbp
       ret