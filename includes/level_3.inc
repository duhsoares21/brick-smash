%include "bricks.inc"

%macro LEVEL_BRICK 5
    dd %1 ; x
    dd %2 ; y
    dd %3 ; width_blocks
    dd %4 ; height_blocks
    dd %5 ; material
%endmacro

level_3_bricks:
    ;LINHA 5
    LEVEL_BRICK 440.0, 126.0, 3, 1, 14
    LEVEL_BRICK 355.0, 126.0, 3, 1, 14
    LEVEL_BRICK 270.0, 126.0, 3, 1, 14
    LEVEL_BRICK 185.0, 126.0, 3, 1, 14
    LEVEL_BRICK 100.0, 126.0, 3, 1, 14
    LEVEL_BRICK 15.0, 126.0, 3, 1, 14

    ;LINHA 4
    LEVEL_BRICK 440.0, 97.0, 3, 1, 11
    LEVEL_BRICK 355.0, 97.0, 3, 1, 11
    LEVEL_BRICK 270.0, 97.0, 3, 1, 11
    LEVEL_BRICK 185.0, 97.0, 3, 1, 11
    LEVEL_BRICK 100.0, 97.0, 3, 1, 11
    LEVEL_BRICK 15.0, 97.0, 3, 1, 11

    ;LINHA 3
    LEVEL_BRICK 270.0, 68.0, 3, 1, 8
    LEVEL_BRICK 355.0, 68.0, 3, 1, 8
    LEVEL_BRICK 100.0, 68.0, 3, 1, 8
    LEVEL_BRICK 185.0, 68.0, 3, 1, 8
    LEVEL_BRICK 440.0, 68.0, 3, 1, 5
    LEVEL_BRICK 15.0, 68.0, 3, 1, 5

    ;LINHA 2
    LEVEL_BRICK 440.0, 39.0, 3, 1, 5
    LEVEL_BRICK 355.0, 39.0, 3, 1, 5
    LEVEL_BRICK 100.0, 39.0, 3, 1, 5
    LEVEL_BRICK 15.0, 39.0, 3, 1, 5
    LEVEL_BRICK 270.0, 39.0, 3, 1, 2
    LEVEL_BRICK 185.0, 39.0, 3, 1, 2

    ;LINHA 1
    LEVEL_BRICK 440.0, 10.0, 3, 1, 2
    LEVEL_BRICK 355.0, 10.0, 3, 1, 2
    LEVEL_BRICK 270.0, 10.0, 3, 1, 2
    LEVEL_BRICK 185.0, 10.0, 3, 1, 2
    LEVEL_BRICK 100.0, 10.0, 3, 1, 2
    LEVEL_BRICK 15.0, 10.0, 3, 1, 2

level_3_bricks_end:

level_3_brick_total equ (level_3_bricks_end - level_3_bricks) / BrickDefinition_size