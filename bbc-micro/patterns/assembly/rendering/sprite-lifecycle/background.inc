; SPDX-License-Identifier: MIT
; Reuse screen_ptr=$70, pairs_ptr=$72 and draw_masked_cell from masked.inc.
; back_ptr=$74/$75 selects EIGHT caller-owned bytes, one buffer per live object.
; Whole MODE4 character cell, byte aligned. Buffer must not overlap bitmap,
; source, code or stack. Save/restore A/Y/flags change; X survives.
; No static save slot: caller retains both old screen address and buffer pointer.
back_ptr=$74
save_cell_to_buffer:
    ldy #7
save_cell_byte:
    lda (screen_ptr),y
    sta (back_ptr),y
    dey
    bpl save_cell_byte
    rts
restore_cell_from_buffer:
    ldy #7
restore_cell_byte:
    lda (back_ptr),y
    sta (screen_ptr),y
    dey
    bpl restore_cell_byte
    rts
