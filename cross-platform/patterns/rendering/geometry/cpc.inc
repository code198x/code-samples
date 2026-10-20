; SPDX-License-Identifier: MIT
; CPC 464 MODE 1, 320x200, display base $C000. Caller owns Gate Array,
; CRTC, palette, ROM/RAM mapping and interrupt policy. BP reserves 48 RAM bytes.
; +0/+2 x0/y0, +4/+6 exclusive x1/y1 (little-endian); +8 op, +11 pen 0..3.
; Op 0 replaces selected pixels with pen; 1 clears to pen 0; 2 XORs pen bits.
; +9 accepted, +10 read pen, +40 word write count; inputs +0..8/+11 survive.
; Same bp_pixel/read/hspan/vspan/box/fill entries as the monochrome backends.
; Whole invalid requests reject before writes. AF/BC/DE/HL/flags clobbered.
; Non-re-entrant; stack <=10 bytes including direct caller, plus interrupts.
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
    ld a,(BP+11)
    cp 4
    ret nc
    ld a,(BP+8)
    cp 3
    ret nc
    ld hl,(BP+20)
    ld de,321
    or a
    sbc hl,de
    ret nc
    ld hl,(BP+16)
    ld de,(BP+20)
    or a
    sbc hl,de
    ret nc
    ld hl,(BP+22)
    ld de,201
    or a
    sbc hl,de
    ret nc
    ld hl,(BP+18)
    ld de,(BP+22)
    or a
    sbc hl,de
    ret nc
    ld a,(BP+11)
    ld e,a
    ld d,0
    ld hl,bp_pens
    add hl,de
    ld a,(hl)
    ld (BP+43),a
    ld a,1
    ld (BP+9),a
    ld a,(BP+16)
    and 3
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
    and 3
    ld e,a
    ld hl,bp_left_masks
    add hl,de
    ld a,(hl)
    ld (BP+25),a
    ld hl,(BP+20)
    dec hl
    ld a,l
    and 3
    ld e,a
    ld hl,bp_bit_masks
    add hl,de
    ld a,(hl)
    ld (BP+27),a
    ld hl,(BP+16)
    srl h
    rr l
    srl h
    rr l
    ld a,l
    ld (BP+28),a
    ld hl,(BP+20)
    dec hl
    srl h
    rr l
    srl h
    rr l
    ld a,l
    ld (BP+29),a
    ld a,(BP+18)
    ld (BP+32),a
    ld a,(BP+22)
    dec a
    ld (BP+42),a
bp_row:
    xor a
    ld (BP+39),a
    call bp_cpc_address
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
    ; Align the selected two-bit pixel with bits 7 and 3.
    ld a,(BP+16)
    and 3
    ld b,a
    inc b
    ld a,(hl)
    jr bp_read_test
bp_read_shift:
    add a,a
bp_read_test:
    djnz bp_read_shift
    ld c,a
    and $80
    ld a,0
    jr z,bp_read_low
    inc a
bp_read_low:
    ld b,a
    ld a,c
    and 8
    ld a,b
    jr z,bp_read_done
    or 2
bp_read_done:
    ld (BP+10),a
    ret
bp_write:
    ld a,(BP+8)
    or a
    jr z,bp_set
    cp 1
    jr z,bp_clear
    ld a,(BP+43)
    and c
    xor (hl)
    jr bp_store
bp_clear:
    ld a,c
    cpl
    and (hl)
    jr bp_store
bp_set:
    ld a,c
    cpl
    and (hl)
    ld b,a
    ld a,(BP+43)
    and c
    or b
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
bp_cpc_address:
    ; $C000 + (y AND 7)*2048 + (y DIV 8)*80 + byte column.
    ld a,(BP+32)
    and 7
    add a,a
    add a,a
    add a,a
    or $c0
    ld h,a
    ld l,0
    push hl
    ld a,(BP+32)
    srl a
    srl a
    srl a
    ld l,a
    ld h,0
    add hl,hl
    add hl,hl
    add hl,hl
    add hl,hl
    ld d,h
    ld e,l
    add hl,hl
    add hl,hl
    add hl,de
    pop de
    add hl,de
    ld a,(BP+28)
    ld e,a
    ld d,0
    add hl,de
    ret
bp_right_masks:
    db $ff,$77,$33,$11
bp_left_masks:
    db $ff,$88,$cc,$ee
bp_bit_masks:
    db $88,$44,$22,$11
bp_pens:
    db $00,$f0,$0f,$ff
