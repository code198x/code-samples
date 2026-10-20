; SPDX-License-Identifier: MIT
; Spectrum 48K. BP reserves 48 bytes of RAM. Native little-endian public words:
; +0 x0,+2 y0,+4 x1,+6 y1 (exclusive ends); +8 op 0=set/1=clear/2=XOR.
; +9 accepted,+10 read value,+40 word destination-write count. +12..47 scratch.
; Inputs survive; destroys AF/BC/DE/HL, flags; stack <=8 bytes including caller.
; Requires existing pixel_addr (D=y,E=x), no attribute writes, not re-entrant.
bp_fill:
    xor a
    jr bp_enter
bp_box:
    ld a,1
    jr bp_enter
bp_pixel:
    ld a,2
    jr bp_enter
bp_read:
    ld a,3
    jr bp_enter
bp_hspan:
    ld a,4
    jr bp_enter
bp_vspan:
    ld a,5
bp_enter:
    ld (BP+12),a
    xor a
    ld (BP+9),a
    ld (BP+10),a
    ld (BP+40),a
    ld (BP+41),a
    ld hl,BP
    ld de,BP+16
    ld bc,8
    ldir
    ld a,(BP+12)
    cp 2
    jr c,bp_validate
    cp 5
    jr z,bp_unit_x
    ld hl,(BP+18)
    inc hl
    ld (BP+22),hl
    cp 4
    jr z,bp_validate
bp_unit_x:
    ld hl,(BP+16)
    inc hl
    ld (BP+20),hl
bp_validate:
    ld a,(BP+8)
    cp 3
    ret nc
    ld hl,(BP+20)
    ld de,257
    or a
    sbc hl,de
    ret nc
    ld hl,(BP+16)
    ld de,(BP+20)
    or a
    sbc hl,de
    ret nc
    ld hl,(BP+22)
    ld de,193
    or a
    sbc hl,de
    ret nc
    ld hl,(BP+18)
    ld de,(BP+22)
    or a
    sbc hl,de
    ret nc
    ld a,1
    ld (BP+9),a
    ld a,(BP+16)
    and 7
    ld e,a
    ld d,0
    ld hl,bp_right_masks
    add hl,de
    ld a,(hl)
    ld (BP+24),a
    ld hl,bp_bit_masks
    add hl,de
    ld a,(hl)
    ld (BP+26),a
    ld a,(BP+20)
    and 7
    ld e,a
    ld hl,bp_left_masks
    add hl,de
    ld a,(hl)
    ld (BP+25),a
    ld hl,(BP+20)
    dec hl
    ld a,l
    and 7
    ld e,a
    ld hl,bp_bit_masks
    add hl,de
    ld a,(hl)
    ld (BP+27),a
    ld a,(BP+16)
    srl a
    srl a
    srl a
    ld (BP+28),a
    ld hl,(BP+20)
    dec hl
    ld a,l
    srl a
    srl a
    srl a
    ld (BP+29),a
    ld a,(BP+18)
    ld (BP+32),a
    ld a,(BP+22)
    dec a
    ld (BP+42),a
bp_row:
    xor a
    ld (BP+39),a
    ld a,(BP+32)
    ld d,a
    ld a,(BP+16)
    ld e,a
    call pixel_addr
    ld (BP+34),hl
    ld a,(BP+28)
    ld (BP+30),a
    ld a,(BP+24)
    ld (BP+36),a
    ld a,(BP+25)
    ld (BP+37),a
    ld a,(BP+12)
    cp 1
    jr nz,bp_bytes
    ld a,(BP+18)
    ld b,a
    ld a,(BP+32)
    cp b
    jr z,bp_bytes
    ld a,(BP+42)
    ld b,a
    ld a,(BP+32)
    cp b
    jr z,bp_bytes
    ld a,1
    ld (BP+39),a
    ld a,(BP+26)
    ld (BP+36),a
    ld a,(BP+27)
    ld (BP+37),a
bp_bytes:
    ld c,255
    ld a,(BP+28)
    ld b,a
    ld a,(BP+30)
    cp b
    jr nz,bp_not_first
    ld a,(BP+36)
    ld c,a
bp_not_first:
    ld a,(BP+29)
    ld b,a
    ld a,(BP+30)
    cp b
    jr nz,bp_not_last
    ld a,(BP+37)
    and c
    ld c,a
    ld a,(BP+39)
    or a
    jr z,bp_not_last
    ld a,(BP+28)
    cp b
    jr nz,bp_not_last
    ld a,(BP+36)
    ld b,a
    ld a,(BP+37)
    or b
    ld c,a
bp_not_last:
    ld a,(BP+39)
    or a
    jr z,bp_apply
    ld a,(BP+30)
    ld b,a
    ld a,(BP+28)
    cp b
    jr z,bp_apply
    ld a,(BP+29)
    cp b
    jr nz,bp_advance
bp_apply:
    ld hl,(BP+34)
    ld a,(BP+12)
    cp 3
    jr nz,bp_write
    ld a,(hl)
    and c
    ret z
    ld a,1
    ld (BP+10),a
    ret
bp_write:
    ld a,(BP+8)
    or a
    jr z,bp_set
    cp 1
    jr z,bp_clear
    ld a,(hl)
    xor c
    jr bp_store
bp_clear:
    ld a,c
    cpl
    and (hl)
    jr bp_store
bp_set:
    ld a,c
    or (hl)
bp_store:
    ld (hl),a
    ld hl,(BP+40)
    inc hl
    ld (BP+40),hl
bp_advance:
    ld a,(BP+29)
    ld b,a
    ld a,(BP+30)
    cp b
    jr z,bp_next_row
    inc a
    ld (BP+30),a
    ld hl,(BP+34)
    inc hl
    ld (BP+34),hl
    jp bp_bytes
bp_next_row:
    ld a,(BP+22)
    ld b,a
    ld a,(BP+32)
    inc a
    cp b
    ret z
    ld (BP+32),a
    jp bp_row
bp_right_masks:
    db 255,127,63,31,15,7,3,1
bp_left_masks:
    db 255,128,192,224,240,248,252,254
bp_bit_masks:
    db 128,64,32,16,8,4,2,1
