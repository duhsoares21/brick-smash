bits 64
default rel

global InitText
global LoadFont

%ifdef WIN32
    extern SDL_GetError_sysv
    extern SDL_Log_sysv
    extern TTF_Init_sysv
    extern TTF_OpenFont_sysv
    extern TTF_RenderText_Blended_sysv
    extern SDL_CreateTextureFromSurface_sysv
    extern SDL_DestroySurface_sysv
    extern SDL_RenderTexture_sysv
    extern TTF_CloseFont_syv
    extern TTF_Quit_sysv

    %define SDL_GetError                  SDL_GetError_sysv
    %define SDL_Log                       SDL_Log_sysv
    %define TTF_Init                      TTF_Init_sysv
    %define TTF_OpenFont                  TTF_OpenFont_sysv
    %define TTF_RenderText_Blended        TTF_RenderText_Blended_sysv
    %define SDL_CreateTextureFromSurface  SDL_CreateTextureFromSurface_sysv
    %define SDL_DestroySurface            SDL_DestroySurface_sysv
    %define SDL_RenderTexture             SDL_RenderTexture_sysv
    %define TTF_CloseFont                 TTF_CloseFont_sysv
    %define TTF_Quit                      TTF_Quit_sysv
%else
    extern SDL_GetError
    extern SDL_Log
    extern TTF_Init
    extern TTF_OpenFont
    extern TTF_RenderText_Blended
    extern SDL_CreateTextureFromSurface
    extern SDL_DestroySurface
    extern SDL_RenderTexture
    extern TTF_CloseFont
    extern TTF_Quit
%endif

extern printf

section .rodata
    success_msg   db "Success", 10, 0
    error_msg   db "SDL error: %s", 10, 0

section .data
    defaultFontFace db "..\fonts\arial.ttf", 0
    defaultFontSize dd 50.0

section .text

InitText:
    call TTF_Init

    test al, al
    jz .error

    jmp .end

    .error:
        call PrintError

    .end:
        ret

LoadFont:
    sub rsp, 8
        lea rdi, [defaultFontFace]
        movss xmm0, [defaultFontSize]

        call TTF_OpenFont
    add rsp, 8

    test al, al
    jz .error

    jmp .end

    .error:
        sub rsp, 8
            call PrintError
        add rsp, 8

    .end:
        ret

PrintError:
    call SDL_GetError

    sub rsp, 8
        lea rdi, [error_msg]
        xor rsi, rax
        xor rdx, rdx

        call SDL_Log
    add rsp, 8
    ret

RenderText:
    ret

