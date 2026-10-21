; SPDX-License-Identifier: MIT
; Sega Mode 4, 448 owned four-plane patterns ($0000..37ff), names $3800..3dff.
; Hardware has 512 slots; the top 64 overlap this allocation's name/sprite data.
; P reserves 32 private RAM bytes: LE source +0, first word +2, count word +4,
; selected pattern word +6, cell word +8, attributes byte +10; outputs status +11,
; data-write count word +12; write-data/control ports +14/+15; scratch +16..31.
; Inputs +0..10 and ports survive. AF/BC/DE/HL/flags clobbered, non-reentrant.
; Own VDP latch for whole call; no DI/EI or banking here. Source must be readable,
; stable, non-wrapping and disjoint from P. Attributes allow bits 1..4 only:
; H flip, V flip, palette 1, priority. Index bit 8 comes from the pattern word.
pattern_init:
    call pattern_reset_result
    ld hl,0
    call pattern_address
    ld de,$3800
    call pattern_zero
    ld hl,$3800
    call pattern_address
    ld de,1536
    call pattern_zero
    jp pattern_accept
pattern_zero:
    xor a
    call pattern_out
    dec de
    ld a,d
    or e
    jr nz,pattern_zero
    ret
pattern_replace:
    ld bc,1
    jr pattern_begin
pattern_install:
    ld bc,(P+4)
pattern_begin:
    call pattern_reset_result
    ld a,b
    or c
    ret z
    ld (P+16),bc
    ld hl,(P+2)
    ld d,b
    ld e,c
    add hl,de
    ret c
    ld de,449
    or a
    sbc hl,de
    ret nc
    ld hl,(P+2)
    add hl,hl
    add hl,hl
    add hl,hl
    add hl,hl
    add hl,hl
    call pattern_address
    ld hl,(P+16)
    add hl,hl
    add hl,hl
    add hl,hl
    add hl,hl
    add hl,hl
    ld d,h
    ld e,l
    ld hl,(P)
pattern_copy:
    ld a,(hl)
    call pattern_out
    inc hl
    dec de
    ld a,d
    or e
    jr nz,pattern_copy
pattern_accept:
    ld a,1
    ld (P+11),a
    ret
pattern_select:
    call pattern_reset_result
    ld a,(P+10)
    and $e1
    ret nz
    ld hl,(P+6)
    ld de,448
    or a
    sbc hl,de
    ret nc
    ld hl,(P+8)
    ld de,768
    or a
    sbc hl,de
    ret nc
    ld hl,(P+8)
    add hl,hl
    ld de,$3800
    add hl,de
    call pattern_address
    ld a,(P+6)
    call pattern_out
    ld a,(P+7)
    ld b,a
    ld a,(P+10)
    or b
    call pattern_out
    jp pattern_accept
pattern_reset_result:
    xor a
    ld (P+11),a
    ld (P+12),a
    ld (P+13),a
    ret
pattern_address:
    ld a,l
    call pattern_control
    ld a,h
    or $40
    call pattern_control
    ret
pattern_control:
    push af
    ld a,(P+15)
    ld c,a
    pop af
    out (c),a
    nop
    nop
    nop
    nop
    ret
pattern_out:
    push af
    ld a,(P+14)
    ld c,a
    pop af
    out (c),a
    nop
    nop
    nop
    nop
    push af
    ld a,(P+12)
    inc a
    ld (P+12),a
    jr nz,pattern_count_ok
    ld a,(P+13)
    inc a
    ld (P+13),a
pattern_count_ok:
    pop af
    ret
