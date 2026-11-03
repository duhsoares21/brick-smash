%include "SDL_structs.inc"

MAX_BALLS equ 10

struc BallDefinition
    .x_initial          resd 1 ; float
    .x:                 resd 1 ; float
    .y:                 resd 1 ; float
    .previous_x:        resd 1 ; float
    .previous_y:        resd 1 ; float
    .direction_x        resd 1 ; float
    .direction_y        resd 1 ; float
    .radius:            resd 1 ; float
    .speed:             resd 1 ; float
    .offset             resd 1 ; float
    .state              resd 1 ; float
    .collision          resd 1 ; float
    .color:             resb SDL_Color_size
    .color_glow:        resb SDL_Color_size
    .is_extra:          resb 1 ;
    .is_active          resb 1 ;
endstruc