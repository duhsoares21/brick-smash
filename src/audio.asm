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

    %define SDL_LoadWAV SDL_LoadWAV_sysv
    %define SDL_OpenAudioDeviceStream SDL_OpenAudioDeviceStream_sysv
    %define SDL_PutAudioStreamData SDL_PutAudioStreamData_sysv
    %define SDL_ResumeAudioStreamDevice SDL_ResumeAudioStreamDevice_sysv
    %define SDL_DestroyAudioStream SDL_DestroyAudioStream_sysv
    %define SDL_free SDL_free_sysv
    %define SDL_GetError SDL_GetError_sysv
%else
    extern SDL_LoadWAV
    extern SDL_OpenAudioDeviceStream
    extern SDL_PutAudioStreamData
    extern SDL_ResumeAudioStreamDevice
    extern SDL_DestroyAudioStream
    extern SDL_free
    extern SDL_GetError
%endif

%define AUDIO_DEVICE 0xFFFFFFFF

global audio_stream

global audio_wall_data
global audio_wall_length
global audio_wall_stream

global audio_brick_data
global audio_brick_length
global audio_brick_stream

global audio_paddle_data
global audio_paddle_length
global audio_paddle_stream

global audio_lose_data
global audio_lose_length
global audio_lose_stream

global LoadWAV
global PlayAudio
global FreeWAV

section .bss
    wav_spec    resd 3      ; format, channels, frequency
    ;wav_data    resq 1      ; Uint8*
    ;wav_length  resd 1      ; Uint32
    audio_stream resq 1     ; SDL_AudioStream*

    audio_wall_data   resq 1
    audio_wall_length resq 1
    audio_wall_stream resq 1

    audio_brick_data   resq 1
    audio_brick_length   resq 1
    audio_brick_stream resq 1

    audio_paddle_data   resq 1
    audio_paddle_length   resq 1
    audio_paddle_stream resq 1

    audio_lose_data   resq 1
    audio_lose_length   resq 1
    audio_lose_stream resq 1

section .data

section .text

LoadWAV:
    push rbp
    mov rbp, rsp

    lea rsi, [wav_spec]
    call SDL_LoadWAV

    test eax, eax
    jz .wav_error

    mov edi, AUDIO_DEVICE
    lea rsi, [wav_spec]
    xor edx, edx
    xor ecx, ecx
    call SDL_OpenAudioDeviceStream

    test rax, rax
    jz .stream_error

    mov [audio_stream], rax
    xor eax, eax
    jmp .done

.wav_error:
    call SDL_GetError
    jmp .done

.stream_error:
    call SDL_GetError

.done:
    pop rbp
    ret

PlayAudio:
        push rbp
        mov rbp, rsp

        call SDL_PutAudioStreamData
        test eax, eax
        jz .error

        call SDL_ResumeAudioStreamDevice
        test eax, eax
        jz .error

        jmp .done

       .error:
           call SDL_GetError

       .done:
           pop rbp
           ret

FreeWAV:
    push rbp
    mov rbp, rsp

    mov rdi, [audio_wall_stream]
    call SDL_DestroyAudioStream

    mov rdi, [audio_brick_stream]
    call SDL_DestroyAudioStream

    mov rdi, [audio_paddle_stream]
    call SDL_DestroyAudioStream

    mov rdi, [audio_lose_stream]
    call SDL_DestroyAudioStream

    mov rdi, [audio_wall_data]
    call SDL_free

    mov rdi, [audio_brick_data]
    call SDL_free

    mov rdi, [audio_paddle_data]
    call SDL_free

    mov rdi, [audio_lose_data]
    call SDL_free

    pop rbp
    ret
