; SPDX-License-Identifier: MIT
; draw_clipped: IX -> 32 bytes. +0 signed X in 8-pixel byte columns,
; +14 signed Y in pixel rows, +28 pointer to 16x16 interleaved KEEP-mask/image.
; Other fields are work/output: two clip_axis blocks, +30 row counter.
; 64 source bytes remain caller-owned, separate from bitmap/code/stack/context.
; AF/BC/DE/HL change, IX/IY survive. Attributes untouched. Include clip.inc and
; bitmap-addressing.inc once. Exclusive workspace; no timing/IRQ setup here.
draw_clipped:
    ld (ix+2),2
    ld (ix+3),0
    ld (ix+4),32
    ld (ix+5),0
    call clip_axis
    ld a,(ix+10)
    or a
    ret z
    push ix
    pop hl
    ld de,14
    add hl,de
    push ix
    push hl
    pop ix
    ld (ix+2),16
    ld (ix+3),0
    ld (ix+4),192
    ld (ix+5),0
    call clip_axis
    pop ix
    ld a,(ix+24)
    or a
    ret z
    ld (ix+30),a
    ld l,(ix+22)
    ld h,0
    add hl,hl
    add hl,hl
    ld e,(ix+8)
    ld d,0
    add hl,de
    add hl,de
    ld e,(ix+28)
    ld d,(ix+29)
    add hl,de
    push hl
    ld d,(ix+20)
    ld a,(ix+6)
    add a,a
    add a,a
    add a,a
    ld e,a
    call pixel_addr
    ex de,hl
    pop hl
draw_clipped_row:
    push hl
    push de
    ld b,(ix+10)
draw_clipped_byte:
    ld c,(hl)
    inc hl
    ld a,(de)
    and c
    or (hl)
    ld (de),a
    inc hl
    inc de
    djnz draw_clipped_byte
    pop de
    pop hl
    dec (ix+30)
    ret z
    ld bc,4
    add hl,bc
    ex de,hl
    call pixel_down
    ex de,hl
    jr draw_clipped_row
