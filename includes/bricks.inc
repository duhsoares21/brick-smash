%include "SDL_structs.inc"

struc BrickDefinition
    .x:                 resd 1 ; float
    .y:                 resd 1 ; float
    .width_blocks:      resd 1 ; inteiro
    .height_blocks:     resd 1 ; inteiro
    .material:          resd 1 ; inteiro
endstruc

struc BrickMaterial
    .id:             resd 1
    .max_hits:       resd 1
    .breakable:      resd 1
    .color:          resb SDL_Color_size
endstruc