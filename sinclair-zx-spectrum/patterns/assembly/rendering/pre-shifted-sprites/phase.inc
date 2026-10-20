; SPDX-License-Identifier: MIT
; draw_pixel_sprite: IX -> 32 bytes, +0 signed PIXEL X, +14 signed Y,
; +28 pointer to an 8-entry phase pointer table (generated KEEP/image rows).
; Consumes X/table fields: they become byte X/source pointer. Reload each call.
; AF/BC/DE/HL change, IX/IY survive. Ownership: same as phase_draw_clipped.
; Include qualified clip_axis, bitmap addressing and this folder's draw.inc once.
draw_pixel_sprite:
    ld l,(ix+0)
    ld h,(ix+1)
    ld a,l
    and 7
    ; Arithmetic division rounds toward -infinity, including negative X.
    sra h
    rr l
    sra h
    rr l
    sra h
    rr l
    ld (ix+0),l
    ld (ix+1),h
    ld l,(ix+28)
    ld h,(ix+29)
    ld e,a
    ld d,0
    add hl,de
    add hl,de
    ld e,(hl)
    inc hl
    ld d,(hl)
    ld (ix+28),e
    ld (ix+29),d
    jp phase_draw_clipped
