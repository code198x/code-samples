; SPDX-License-Identifier: MIT
; Caller owns scroll_x, scroll_y (0..239), nametable (0..3), ppu_ctrl_shadow.
; Set_scroll: call in vblank AFTER all $2006/$2007 writes. Changes A and flags.
; Hardware mirroring decides which logical tables have distinct physical RAM.
set_scroll:
    bit $2002
    lda scroll_x
    sta $2005
    lda scroll_y
    sta $2005
    lda ppu_ctrl_shadow
    and #$fc
    ora nametable
    sta $2000
    rts
; Move right by one pixel; preserves vertical table bit. A/flags change.
; Update a private snapshot; do not call concurrently with set_scroll.
scroll_right:
    inc scroll_x
    bne scroll_right_done
    lda nametable
    eor #1
    sta nametable
scroll_right_done:
    rts
