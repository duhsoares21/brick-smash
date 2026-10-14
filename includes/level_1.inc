%include "bricks.inc"

%macro LEVEL_BRICK 5
    dd %1 ; x
    dd %2 ; y
    dd %3 ; width_blocks
    dd %4 ; height_blocks
    dd %5 ; material
%endmacro

level_01_bricks:
    ;GREEN LINE
    LEVEL_BRICK 15.0,  10.0, 3, 1, 2
    LEVEL_BRICK 100.0, 10.0, 3, 1, 2
    LEVEL_BRICK 185.0, 10.0, 3, 1, 2
    LEVEL_BRICK 270.0, 10.0, 3, 1, 2
    LEVEL_BRICK 355.0, 10.0, 3, 1, 2
    LEVEL_BRICK 440.0, 10.0, 3, 1, 2

    ;BLUE LINE
    LEVEL_BRICK 15.0,  39.0, 3, 1, 5
    LEVEL_BRICK 100.0, 39.0, 3, 1, 5
    LEVEL_BRICK 185.0, 39.0, 3, 1, 5
    LEVEL_BRICK 270.0, 39.0, 3, 1, 5
    LEVEL_BRICK 355.0, 39.0, 3, 1, 5
    LEVEL_BRICK 440.0, 39.0, 3, 1, 5

    ;PINK LINE
    LEVEL_BRICK 15.0,  68.0, 3, 1, 8
    LEVEL_BRICK 100.0, 68.0, 3, 1, 8
    LEVEL_BRICK 185.0, 68.0, 3, 1, 8
    LEVEL_BRICK 270.0, 68.0, 3, 1, 8
    LEVEL_BRICK 355.0, 68.0, 3, 1, 8
    LEVEL_BRICK 440.0, 68.0, 3, 1, 8

    ;YELLOW LINE
    LEVEL_BRICK 15.0,  97.0, 3, 1, 11
    LEVEL_BRICK 100.0, 97.0, 3, 1, 11
    LEVEL_BRICK 185.0, 97.0, 3, 1, 11
    LEVEL_BRICK 270.0, 97.0, 3, 1, 11
    LEVEL_BRICK 355.0, 97.0, 3, 1, 11
    LEVEL_BRICK 440.0, 97.0, 3, 1, 11

    ;PURPLE LINE
    LEVEL_BRICK 15.0,  126.0, 3, 1, 14
    LEVEL_BRICK 100.0, 126.0, 3, 1, 14
    LEVEL_BRICK 185.0, 126.0, 3, 1, 14
    LEVEL_BRICK 270.0, 126.0, 3, 1, 14
    LEVEL_BRICK 355.0, 126.0, 3, 1, 14
    LEVEL_BRICK 440.0, 126.0, 3, 1, 14
level_01_bricks_end:

level_01_brick_count equ (level_01_bricks_end - level_01_bricks) / BrickDefinition_size