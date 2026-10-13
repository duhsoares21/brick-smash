cmake_minimum_required(VERSION 3.20)

# Windows: usar o compilador de recursos da mesma toolchain MinGW.
if(CMAKE_HOST_WIN32)
    set(CMAKE_RC_COMPILER
            "C:/Program Files/JetBrains/CLion 2026.2.3.1/bin/mingw/bin/windres.exe"
            CACHE FILEPATH "MinGW resource compiler"
    )
endif()

project(BrickSmash LANGUAGES C ASM_NASM)

if(WIN32)
    set(CMAKE_ASM_NASM_OBJECT_FORMAT win64)
    enable_language(RC)
    add_subdirectory(external/SDL EXCLUDE_FROM_ALL)
else()
    set(CMAKE_ASM_NASM_OBJECT_FORMAT elf64)
endif()

# ============================================================
# Wrappers System V
# ============================================================
add_library(sysv_wrappers STATIC
        wrapper/wrapper_sysv.c
)

target_include_directories(sysv_wrappers PRIVATE
        "${CMAKE_SOURCE_DIR}/external/SDL/include"
        "${CMAKE_SOURCE_DIR}/external/SDL3_gfx"
)

# ============================================================
# Executável
# ============================================================
add_executable(BrickSmash
        src/main.asm
        src/window.asm
        src/main_menu.asm
        src/input.asm
        src/paddle.asm
        src/ball.asm
        src/ball_animation.asm
        src/collision.asm
        src/render.asm
        src/game.asm
        src/state_machine.asm
)

target_compile_options(BrickSmash PRIVATE
        $<$<COMPILE_LANGUAGE:ASM_NASM>:-g>
        $<$<AND:$<COMPILE_LANGUAGE:ASM_NASM>,$<BOOL:${WIN32}>>:-Fcv8>
        $<$<AND:$<COMPILE_LANGUAGE:ASM_NASM>,$<BOOL:${UNIX}>>:-Fdwarf>
        $<$<COMPILE_LANGUAGE:ASM_NASM>:-I${CMAKE_SOURCE_DIR}/includes/>
        $<$<AND:$<COMPILE_LANGUAGE:ASM_NASM>,$<BOOL:${WIN32}>>:-DWIN32>
)

if(WIN32)
    set(CMAKE_ASM_NASM_FLAGS_DEBUG "-g -F cv8")
elseif(UNIX AND NOT APPLE)
    set(CMAKE_ASM_NASM_FLAGS_DEBUG "-g -F dwarf")

    target_link_options(BrickSmash PRIVATE
            -no-pie
            -Wl,--no-warn-execstack
    )
endif()

# ============================================================
# Linkagem
# ============================================================
if(WIN32)
    set(SDL3_GFX_LIB
            "${CMAKE_SOURCE_DIR}/external/SDL3_gfx/x64/Debug/SDL3_gfx.lib"
    )

    target_include_directories(BrickSmash PRIVATE
            "${CMAKE_SOURCE_DIR}/external/SDL/include"
            "${CMAKE_SOURCE_DIR}/external/SDL3_gfx"
    )

    # Ordem importante: wrappers depois das libs do SDL
    target_link_libraries(BrickSmash PRIVATE
            sysv_wrappers
            SDL3::SDL3
            "${SDL3_GFX_LIB}"
    )

    add_custom_command(TARGET BrickSmash POST_BUILD
            COMMAND ${CMAKE_COMMAND} -E copy_if_different
            "$<TARGET_FILE:SDL3::SDL3>"
            "$<TARGET_FILE_DIR:BrickSmash>"
            COMMAND ${CMAKE_COMMAND} -E copy_if_different
            "${CMAKE_SOURCE_DIR}/external/SDL3_gfx/x64/Debug/SDL3_gfx.dll"
            "$<TARGET_FILE_DIR:BrickSmash>"
            VERBATIM
    )
else()
    target_link_libraries(BrickSmash PRIVATE
            SDL3
            SDL3_gfx
    )
endif()

set_target_properties(BrickSmash PROPERTIES
        LINKER_LANGUAGE C
)