show_byte:
    push af
    rrca
    rrca
    rrca
    rrca
    and 15
    call digit
    call show_char
    pop af
    and 15
    call digit
    jp show_char
digit:
    cp 10
    jr c,digit_number
    add a,7
digit_number:
    add a,48
    ret
; A=ASCII, DE=top scanline cell. CHARS points 256 bytes before glyph 32.
; AF/BC/HL clobbered; DE advances one character column.
show_char:
    push de
    ld l,a
    ld h,0
    add hl,hl
    add hl,hl
    add hl,hl
    ld bc,($5C36)
    add hl,bc
    ld b,8
show_scan:
    ld a,(hl)
    ld (de),a
    inc hl
    inc d
    djnz show_scan
    pop de
    inc e
    ret
