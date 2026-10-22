    ld a,$7f
    out ($05),a               ; select column 7, active-low column drive
    in a,($06)                ; Space is bit 8 of the 10-bit return: high bit 0
    cpl
    and 1
    ld b,a
