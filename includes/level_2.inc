%include "bricks.inc"

%macro LEVEL_BRICK 5
    dd %1 ; x
    dd %2 ; y
    dd %3 ; width_blocks
    dd %4 ; height_blocks
    dd %5 ; material
%endmacro

LEVEL_2_BALL_SPEED equ 320

level_2_bricks:
    ;GREEN LINE
    LEVEL_BRICK 15.0,  10.0, 84.0, 28.0, 2
    LEVEL_BRICK 100.0, 10.0, 84.0, 28.0, 2
    LEVEL_BRICK 185.0, 10.0, 84.0, 28.0, 2
    LEVEL_BRICK 270.0, 10.0, 84.0, 28.0, 2
    LEVEL_BRICK 355.0, 10.0, 84.0, 28.0, 2
    LEVEL_BRICK 440.0, 10.0, 84.0, 28.0, 2

    ;BLUE LINE
    LEVEL_BRICK 15.0,  39.0, 84.0, 28.0, 5
    LEVEL_BRICK 100.0, 39.0, 84.0, 28.0, 5
    LEVEL_BRICK 185.0, 39.0, 84.0, 28.0, 5
    LEVEL_BRICK 270.0, 39.0, 84.0, 28.0, 5
    LEVEL_BRICK 355.0, 39.0, 84.0, 28.0, 5
    LEVEL_BRICK 440.0, 39.0, 84.0, 28.0, 5

    ;PINK LINE
    LEVEL_BRICK 15.0,  68.0, 84.0, 28.0, 8
    LEVEL_BRICK 100.0, 68.0, 84.0, 28.0, 8
    LEVEL_BRICK 355.0, 68.0, 84.0, 28.0, 8
    LEVEL_BRICK 440.0, 68.0, 84.0, 28.0, 8

    ;YELLOW LINE
    LEVEL_BRICK 15.0,  97.0, 84.0, 28.0, 11
    LEVEL_BRICK 440.0, 97.0, 84.0, 28.0, 11

    ;PURPLE LINE
    LEVEL_BRICK 15.0,  126.0, 84.0, 28.0, 14
    LEVEL_BRICK 440.0, 126.0, 84.0, 28.0, 14
level_2_bricks_end:

level_2_brick_total equ (level_2_bricks_end - level_2_bricks) / BrickDefinition_size