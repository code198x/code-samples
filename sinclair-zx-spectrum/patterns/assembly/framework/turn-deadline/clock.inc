; Stock 48K ROM IM1 owns FRAMES. Atomic word instruction; IRQ between instructions.
; HL=low sixteen ticks, flags and all other registers preserved.
clock_read:
    ld hl,($5C78)
    ret
