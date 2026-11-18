%include "SDL_structs.inc"

BRICK_HIT_POINTS equ 5

struc BrickDefinition
    .x:                 resd 1 ; float
    .y:                 resd 1 ; float
    .width:             resd 1 ; float
    .height:            resd 1 ; float
    .material:          resd 1 ; inteiro
endstruc

struc BrickMaterial
    .id:             resd 1
    .max_hits:       resd 1
    .breakable:      resd 1
    .score_points:   resd 1
    .color:          resb SDL_Color_size
endstruc