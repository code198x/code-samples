; JIFFY is owned by the normal BIOS VBlank ISR. HL out, no flags changed.
; One Z80 instruction loads the word; maskable IRQs occur between instructions.
clock_read:
    ld hl,($FC9E)
    ret
