    ld a,14
    out ($02),a               ; AY port A: row select
    ld a,$fe
    out ($03),a               ; select keyboard row 0
    ld a,15
    out ($02),a               ; AY port B: column return
    in a,($02)
    cpl
    and $40                   ; Space, row 0 bit 6
    ld b,a
