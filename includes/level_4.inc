%include "bricks.inc"

%macro LEVEL_BRICK 5
    dd %1 ; x
    dd %2 ; y
    dd %3 ; width
    dd %4 ; height
    dd %5 ; material
%endmacro

LEVEL_4_BALL_SPEED equ 375

level_4_bricks:
    ;LINHA 1
    LEVEL_BRICK 13.5, 10.0, 84.0, 28.0, 2
    LEVEL_BRICK 98.5, 10.0, 86.0, 28.0, 2
    LEVEL_BRICK 185.5, 10.0, 84.0, 28.0, 8
    LEVEL_BRICK 270.5, 10.0, 256.0, 57.0, 3

    ;LINHA 2
    LEVEL_BRICK 13.5, 39.0, 84.0, 28.0, 8
    LEVEL_BRICK 98.5, 39.0, 86.0, 28.0, 8
    LEVEL_BRICK 185.5, 39.0, 84.0, 28.0, 8

    ;LINHA 3
    LEVEL_BRICK 13.5, 68.0, 84.0, 28.0, 14
    LEVEL_BRICK 98.5, 68.0, 86.0, 28.0, 14
    LEVEL_BRICK 185.5, 68.0, 84.0, 28.0, 14
    LEVEL_BRICK 270.5, 68.0, 84.0, 28.0, 3
    LEVEL_BRICK 355.5, 68.0, 86.0, 28.0, 3
    LEVEL_BRICK 442.5, 68.0, 84.0, 28.0, 3

    ;LINHA 4
    LEVEL_BRICK 13.5, 97.0, 84.0, 28.0, 14
    LEVEL_BRICK 98.5, 97.0, 86.0, 28.0, 14
    LEVEL_BRICK 185.5, 97.0, 84.0, 86.0, 6
    LEVEL_BRICK 270.5, 97.0, 84.0, 86.0, 6
    LEVEL_BRICK 355.5, 97.0, 86.0, 28.0, 5
    LEVEL_BRICK 442.5, 97.0, 84.0, 28.0, 5

    ;LINHA 5
    LEVEL_BRICK 13.5, 126.0, 28.0, 28.0, 8
    LEVEL_BRICK 42.5, 126.0, 28.0, 28.0, 8
    LEVEL_BRICK 71.5, 126.0, 84.0, 28.0, 9
    LEVEL_BRICK 156.5, 126.0, 28.0, 28.0, 8
    LEVEL_BRICK 355.5, 126.0, 28.0, 28.0, 8
    LEVEL_BRICK 384.5, 126.0, 84.0, 28.0, 9
    LEVEL_BRICK 469.5, 126.0, 28.0, 28.0, 8
    LEVEL_BRICK 498.5, 126.0, 28.0, 28.0, 8

    ;LINHA 6
    LEVEL_BRICK 13.5, 155.0, 84.0, 28.0, 2
    LEVEL_BRICK 98.5, 155.0, 86.0, 28.0, 2
    LEVEL_BRICK 355.5, 155.0, 86.0, 28.0, 2
    LEVEL_BRICK 442.5, 155.0, 84.0, 28.0, 2

    ;LINHA 7
    LEVEL_BRICK 13.5, 184.0, 28.0, 28.0, 5
    LEVEL_BRICK 42.5, 184.0, 84.0, 28.0, 2
    LEVEL_BRICK 127.5, 184.0, 28.0, 28.0, 5
    LEVEL_BRICK 156.5, 184.0, 28.0, 28.0, 5
    LEVEL_BRICK 185.5, 184.0, 84.0, 28.0, 3
    LEVEL_BRICK 270.5, 184.0, 84.0, 28.0, 3
    LEVEL_BRICK 355.5, 184.0, 28.0, 28.0, 2
    LEVEL_BRICK 384.5, 184.0, 28.0, 28.0, 5
    LEVEL_BRICK 413.5, 184.0, 28.0, 28.0, 2
    LEVEL_BRICK 442.5, 184.0, 84.0, 28.0, 8

level_4_bricks_end:

level_4_brick_total equ (level_4_bricks_end - level_4_bricks) / BrickDefinition_size
