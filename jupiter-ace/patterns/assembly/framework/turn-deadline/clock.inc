; Stock FORTH FRAMES low word; retry if interrupt carries the low byte.
; HL out, A/flags clobbered; BC/DE/IX/IY and interrupt state preserved.
clock_read:
    ld a,($3C2C)
    ld h,a
    ld a,($3C2B)
    ld l,a
    ld a,($3C2C)
    cp h
    jr nz,clock_read
    ret
