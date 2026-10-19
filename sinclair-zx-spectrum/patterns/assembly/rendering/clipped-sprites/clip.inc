; SPDX-License-Identifier: MIT
; clip_axis: IX -> 14 caller-owned bytes, little-endian words:
; +0 signed position (-32768..32767), +2 extent (0..256), +4 limit (1..256).
; Outputs +6 destination, +8 source skip, +10 visible count; +12 scratch.
; Empty output has all three result words zero. Inputs survive.
; AF/BC/DE/HL change, IX/IY survive. No hardware or interrupt ownership.
clip_axis:
    xor a
    ld (ix+6),a
    ld (ix+7),a
    ld (ix+8),a
    ld (ix+9),a
    ld (ix+10),a
    ld (ix+11),a
    ld c,(ix+2)
    ld b,(ix+3)
    ld a,b
    or c
    ret z
    ld l,(ix+0)
    ld h,(ix+1)
    bit 7,h
    jr z,clip_positive
    ; Unsigned magnitude also handles -32768 without signed negation overflow.
    xor a
    sub l
    ld e,a
    sbc a,a
    sub h
    ld d,a
    ld h,b
    ld l,c
    or a
    sbc hl,de
    ret c
    ret z
    ld (ix+8),e
    ld (ix+9),d
    jr clip_capacity
clip_positive:
    ld e,(ix+4)
    ld d,(ix+5)
    push hl
    or a
    sbc hl,de
    pop hl
    ret nc
    ld (ix+6),l
    ld (ix+7),h
    ld h,b
    ld l,c
clip_capacity:
    ; HL remaining source count; DE = viewport capacity at destination.
    ld e,(ix+4)
    ld d,(ix+5)
    ld c,(ix+6)
    ld b,(ix+7)
    ex de,hl
    or a
    sbc hl,bc
    ex de,hl
    push hl
    or a
    sbc hl,de
    pop hl
    jr c,clip_store
    ex de,hl
clip_store:
    ld (ix+10),l
    ld (ix+11),h
    ret
