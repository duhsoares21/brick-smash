cmake_minimum_required(VERSION 3.20)

project(BrickSmash LANGUAGES C ASM_NASM)

set(CMAKE_ASM_NASM_OBJECT_FORMAT elf64)

add_executable(BrickSmash
        src/main.asm
        src/window.asm
        src/main_menu.asm
        src/input.asm
        src/paddle.asm
        src/ball.asm
        src/collision.asm
        src/render.asm
        src/game.asm
        src/state_machine.asm
)

set(CMAKE_ASM_NASM_FLAGS_DEBUG "-g -F dwarf")

target_compile_options(BrickSmash PRIVATE
        $<$<COMPILE_LANGUAGE:ASM_NASM>:-I${CMAKE_SOURCE_DIR}/includes/>
)

target_link_options(BrickSmash PRIVATE
        -no-pie
        -Wl,--no-warn-execstack
)

target_link_libraries(BrickSmash PRIVATE
        SDL3
        SDL3_gfx
)

set_target_properties(BrickSmash PROPERTIES
        LINKER_LANGUAGE C
)