struc SDL_FRect
    .x: resd 1
    .y: resd 1
    .w: resd 1
    .h: resd 1
endstruc

%macro SDL_FRECT 4
    dd %1, %2, %3, %4
%endmacro

struc SDL_Color
    .r: resb 1
    .g: resb 1
    .b: resb 1
    .a: resb 1
endstruc

%macro SDL_COLOR 4
    db %1, %2, %3, %4
%endmacro