%include "SDL_structs.inc"
%include "bricks.inc"

section .data

material_light_green:
    istruc BrickMaterial
        at BrickMaterial.id,        dd 1
        at BrickMaterial.max_hits,  dd 1
        at BrickMaterial.breakable, dd 1
        at BrickMaterial.color,     SDL_COLOR 120, 235, 163, 255
    iend

material_medium_green:
    istruc BrickMaterial
        at BrickMaterial.id,        dd 2
        at BrickMaterial.max_hits,  dd 1
        at BrickMaterial.breakable, dd 1
        at BrickMaterial.color,     SDL_COLOR 67, 209, 125, 255
    iend

material_dark_green:
    istruc BrickMaterial
        at BrickMaterial.id,        dd 3
        at BrickMaterial.max_hits,  dd 1
        at BrickMaterial.breakable, dd 1
        at BrickMaterial.color,     SDL_COLOR 23, 77, 50, 255
    iend

material_light_blue:
    istruc BrickMaterial
        at BrickMaterial.id,        dd 4
        at BrickMaterial.max_hits,  dd 1
        at BrickMaterial.breakable, dd 1
        at BrickMaterial.color,     SDL_COLOR 138, 224, 255, 255
    iend

material_medium_blue:
    istruc BrickMaterial
        at BrickMaterial.id,        dd 5
        at BrickMaterial.max_hits,  dd 1
        at BrickMaterial.breakable, dd 1
        at BrickMaterial.color,     SDL_COLOR 67, 185, 232, 255
    iend

material_dark_blue:
    istruc BrickMaterial
        at BrickMaterial.id,        dd 6
        at BrickMaterial.max_hits,  dd 1
        at BrickMaterial.breakable, dd 1
        at BrickMaterial.color,     SDL_COLOR 23, 68, 95, 255
    iend

material_light_pink:
    istruc BrickMaterial
        at BrickMaterial.id,        dd 7
        at BrickMaterial.max_hits,  dd 1
        at BrickMaterial.breakable, dd 1
        at BrickMaterial.color,     SDL_COLOR 255, 157, 201, 255
    iend

material_medium_pink:
    istruc BrickMaterial
        at BrickMaterial.id,        dd 8
        at BrickMaterial.max_hits,  dd 1
        at BrickMaterial.breakable, dd 1
        at BrickMaterial.color,     SDL_COLOR 232, 93, 158, 255
    iend

material_dark_pink:
    istruc BrickMaterial
        at BrickMaterial.id,        dd 9
        at BrickMaterial.max_hits,  dd 1
        at BrickMaterial.breakable, dd 1
        at BrickMaterial.color,     SDL_COLOR 99, 39, 68, 255
    iend

material_light_yellow:
    istruc BrickMaterial
        at BrickMaterial.id,        dd 10
        at BrickMaterial.max_hits,  dd 1
        at BrickMaterial.breakable, dd 1
        at BrickMaterial.color,     SDL_COLOR 255, 233, 135, 255
    iend

material_medium_yellow:
    istruc BrickMaterial
        at BrickMaterial.id,        dd 11
        at BrickMaterial.max_hits,  dd 1
        at BrickMaterial.breakable, dd 1
        at BrickMaterial.color,     SDL_COLOR 232, 197, 71, 255
    iend

material_dark_yellow:
    istruc BrickMaterial
        at BrickMaterial.id,        dd 12
        at BrickMaterial.max_hits,  dd 1
        at BrickMaterial.breakable, dd 1
        at BrickMaterial.color,     SDL_COLOR 98, 82, 29, 255
    iend

material_light_purple:
    istruc BrickMaterial
        at BrickMaterial.id,        dd 13
        at BrickMaterial.max_hits,  dd 1
        at BrickMaterial.breakable, dd 1
        at BrickMaterial.color,     SDL_COLOR 199, 174, 255, 255
    iend

material_medium_purple:
    istruc BrickMaterial
        at BrickMaterial.id,        dd 14
        at BrickMaterial.max_hits,  dd 1
        at BrickMaterial.breakable, dd 1
        at BrickMaterial.color,     SDL_COLOR 154, 120, 232, 255
    iend

material_dark_purple:
    istruc BrickMaterial
        at BrickMaterial.id,        dd 15
        at BrickMaterial.max_hits,  dd 1
        at BrickMaterial.breakable, dd 1
        at BrickMaterial.color,     SDL_COLOR 64, 48, 95, 255
    iend

material_table:
    dq material_light_green
    dq material_medium_green
    dq material_dark_green
    dq material_light_blue
    dq material_medium_blue
    dq material_dark_blue
    dq material_light_pink
    dq material_medium_pink
    dq material_dark_pink
    dq material_light_yellow
    dq material_medium_yellow
    dq material_dark_yellow
    dq material_light_purple
    dq material_medium_purple
    dq material_dark_purple