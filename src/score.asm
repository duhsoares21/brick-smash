bits 64
default rel

global score
global hiscore

global AddScore
global UpdateHiScore

section .data
    score dd 0
    hiscore dd 0

section .text
    AddScore:
        add [score], rdi
        ret

    UpdateHiScore:
        mov eax, [hiscore]
        add eax, [score]
        mov [hiscore], eax
        ret