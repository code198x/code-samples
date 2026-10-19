; SPDX-License-Identifier: MIT
; B=width bytes (0..32), C=height rows, DE=top-left bitmap byte, HL=buffer.
; Zero width/height: no-op. Otherwise the rectangle must fit the 256x192 bitmap.
; Buffer has B*C readable/writable bytes and does not overlap bitmap/stack/code.
; Include bitmap-addressing.inc once for pixel_down (preserves BC/DE).
; AF/BC/DE/HL change; IX/IY preserved. HL advances by B*C. No static state.
; Four temporary stack bytes beyond the caller return and any interrupt use.
save_rect:
    ld a,b
    or a
    ret z
    ld a,c
    or a
    ret z
save_rect_row:
    push bc
    push de
save_rect_byte:
    ld a,(de)
    ld (hl),a
    inc hl
    inc de
    djnz save_rect_byte
    pop de
    pop bc
    dec c
    ret z
    ex de,hl
    call pixel_down
    ex de,hl
    jr save_rect_row
restore_rect:
    ld a,b
    or a
    ret z
    ld a,c
    or a
    ret z
restore_rect_row:
    push bc
    push de
restore_rect_byte:
    ld a,(hl)
    ld (de),a
    inc hl
    inc de
    djnz restore_rect_byte
    pop de
    pop bc
    dec c
    ret z
    ex de,hl
    call pixel_down
    ex de,hl
    jr restore_rect_row
