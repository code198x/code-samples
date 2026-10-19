; SPDX-License-Identifier: MIT
; Input HL = one edge byte per scanline (only bit 0 is used), D=top y, B=height.
; Full 256-pixel width; top+height <=192. Height 0 is a no-op.
; Bitmap only: attributes do not move. Readable edge data must not overlap screen.
; Output HL advances by height. AF/BC/DE change; IX/IY preserved. No static state.
; Include bitmap-addressing.inc once. Stack: 8 temporary bytes plus CALL/IRQ needs.
scroll_band_left:
    ld a,b
    or a
    ret z
scroll_band_row:
    push bc
    push hl
    ld a,(hl)
    push af
    ld e,0
    call pixel_addr
    ld a,l
    or 31
    ld l,a
    pop af
    rra                  ; incoming edge pixel -> carry
    ld c,32
scroll_band_byte:
    rl (hl)              ; rightmost byte first: carry travels towards the left
    dec hl
    dec c
    jr nz,scroll_band_byte
    pop hl
    inc hl
    inc d
    pop bc
    djnz scroll_band_row
    ret
