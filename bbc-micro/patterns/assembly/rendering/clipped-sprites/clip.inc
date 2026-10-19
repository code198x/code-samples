; SPDX-License-Identifier: MIT
; clip_ptr=$70/$71 -> 14 caller-owned bytes, little-endian words:
; +0 signed position, +2 extent 0..256, +4 limit 1..256.
; +6 destination, +8 source skip, +10 count; +12 scratch capacity.
; All three result words zero when empty. Inputs survive. A/X/Y/P change.
; NMOS 6502: D must be clear. Pointer and workspace exclusively owned;
; interrupt users must preserve them. No hardware access or static save slot.
clip_ptr=$70
clip_axis:
    lda #0
    ldy #6
clip_clear:
    sta (clip_ptr),y
    iny
    cpy #12
    bne clip_clear
    ldy #2
    lda (clip_ptr),y
    iny
    ora (clip_ptr),y
    bne clip_nonzero
    rts
clip_nonzero:
    ldy #1
    lda (clip_ptr),y
    bpl clip_positive
    ; Compute unsigned magnitude into skip (including $8000).
    ldy #0
    sec
    lda #0
    sbc (clip_ptr),y
    ldy #8
    sta (clip_ptr),y
    ldy #1
    lda #0
    sbc (clip_ptr),y
    ldy #9
    sta (clip_ptr),y
    ; count = extent - skip; <=0 means fully outside.
    ldy #2
    lda (clip_ptr),y
    ldy #8
    sec
    sbc (clip_ptr),y
    ldy #10
    sta (clip_ptr),y
    ldy #3
    lda (clip_ptr),y
    ldy #9
    sbc (clip_ptr),y
    ldy #11
    sta (clip_ptr),y
    bcc clip_empty
    dey
    ora (clip_ptr),y
    beq clip_empty
    jmp clip_capacity
clip_positive:
    ; Copy positive position to destination, extent to count.
    ldy #0
    lda (clip_ptr),y
    ldy #6
    sta (clip_ptr),y
    ldy #1
    lda (clip_ptr),y
    ldy #7
    sta (clip_ptr),y
    ldy #2
    lda (clip_ptr),y
    ldy #10
    sta (clip_ptr),y
    ldy #3
    lda (clip_ptr),y
    ldy #11
    sta (clip_ptr),y
clip_capacity:
    ; capacity = limit - destination; <=0 means fully outside.
    ldy #4
    lda (clip_ptr),y
    ldy #6
    sec
    sbc (clip_ptr),y
    ldy #12
    sta (clip_ptr),y
    ldy #5
    lda (clip_ptr),y
    ldy #7
    sbc (clip_ptr),y
    ldy #13
    sta (clip_ptr),y
    bcc clip_empty
    dey
    ora (clip_ptr),y
    beq clip_empty
    ; Compare count with capacity, high then low (unsigned).
    ldy #11
    lda (clip_ptr),y
    ldy #13
    cmp (clip_ptr),y
    bcc clip_return
    bne clip_trim
    ldy #10
    lda (clip_ptr),y
    ldy #12
    cmp (clip_ptr),y
    bcc clip_return
clip_trim:
    ldy #12
    lda (clip_ptr),y
    ldy #10
    sta (clip_ptr),y
    ldy #13
    lda (clip_ptr),y
    ldy #11
    sta (clip_ptr),y
clip_return:
    rts
clip_empty:
    lda #0
    ldy #6
clip_clear_empty:
    sta (clip_ptr),y
    iny
    cpy #12
    bne clip_clear_empty
    rts
