; Original glyph data and a minimal Graphics I text caller.
; Owns all 16 KiB VRAM and the VDP latch. Not part of the turn routine.
init_picture:
    in a,($bf)
    xor a
    out ($bf),a
    ld a,$81
    out ($bf),a               ; display and VDP NMI source off
    xor a
    out ($bf),a
    ld a,$40
    out ($bf),a
    ld bc,$4000
clear_vram:
    xor a
    out ($be),a
    nop
    nop
    dec bc
    ld a,b
    or c
    jr nz,clear_vram
    xor a
    out ($bf),a
    ld a,$40
    out ($bf),a
    ld hl,font
    ld bc,512
copy_font:
    ld a,(hl)
    out ($be),a
    nop
    nop
    inc hl
    dec bc
    ld a,b
    or c
    jr nz,copy_font
    xor a
    out ($bf),a
    ld a,$60
    out ($bf),a
    ld b,8
colours:
    ld a,$f1
    out ($be),a
    nop
    nop
    djnz colours
    xor a
    out ($bf),a
    ld a,$5b
    out ($bf),a
    ld a,$d0
    out ($be),a               ; end sprite list
    ld hl,registers
    ld b,8
    ld c,$80
register_loop:
    ld a,(hl)
    out ($bf),a
    ld a,c
    out ($bf),a
    inc hl
    inc c
    djnz register_loop
    ret
draw_counter:
    ld a,$8c
    out ($bf),a
    ld a,$59
    out ($bf),a               ; name row 12, col 12 ($198c)
    ld hl,label
    ld b,5
label_loop:
    ld a,(hl)
    out ($be),a
    nop
    nop
    inc hl
    djnz label_loop
    ld a,(T)
    rrca
    rrca
    rrca
    rrca
    and 15
    call hex_digit
    ld a,(T)
    and 15
hex_digit:
    add a,16
    cp 26
    jr c,write_digit
    add a,7
write_digit:
    out ($be),a
    ret
label: db 52,53,50,46,0
registers: db 0,$40,6,$80,0,$36,0,$f1
font:
    include "../../../../../cross-platform/patterns/rendering/bitmap-text/font-z80.inc"
