; Fill a 32-byte row buffer, one byte per loop iteration.
; 48K PAL Spectrum; code, buffer and stack are in uncontended RAM.
        org $c000
main:
        di
        ld sp,$ff00
        ld hl,$9000
        ld a,$47
        call fill_row
        halt
end_main:

; In: HL = 32-byte destination, A = value. Out: HL += 32, B = 0.
; Preserves A, flags, C, DE, IX, IY and interrupt state.
fill_row:
        ld b,32
fill_loop:
        ld (hl),a
        inc hl
        djnz fill_loop
        ret
end_fill_row:
        end main
