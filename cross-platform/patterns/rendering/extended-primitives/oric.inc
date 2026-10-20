; SPDX-License-Identifier: MIT
; Oric HIRES, six pixel bits. Content width 228 excludes two serial-attribute columns.
; bit 6 must already mark pixel data; bit 7 (inverse) survives every operation. BP reserves 48 zero-page bytes; decimal mode must be off.
; Public words: +0 x0, +2 y0, +4 x1, +6 y1 (little-endian, exclusive ends).
; +8 operation 0=set,1=clear,2=XOR. +9 accepted, +10 read value.
; +40 word counts destination-byte writes for the most recent call.
; Calls destroy A/X/Y/flags, +12..47; inputs +0..8 survive. Not re-entrant.
; bitmap_lo/hi[y] names the selected content viewport; horizontal byte step is 1.
; All entries reject the whole request before writing; empty/reversed is rejected.
bp_fill:
    lda #0
    beq bp_enter
bp_box:
    lda #1
    bne bp_enter
bp_pixel:
    lda #2
    bne bp_enter
bp_read:
    lda #3
    bne bp_enter
bp_hspan:
    lda #4
    bne bp_enter
bp_vspan:
    lda #5
bp_enter:
    sta BP+12
    lda #0
    sta BP+9
    sta BP+10
    sta BP+40
    sta BP+41
    ldx #7
bp_copy:
    lda BP,x
    sta BP+16,x
    dex
    bpl bp_copy
    lda BP+12
    cmp #2
    bcc bp_validate
    cmp #5
    beq bp_unit_x
    ; Pixel/read/hspan have height 1.
    lda BP+18
    clc
    adc #1
    sta BP+22
    lda BP+19
    adc #0
    sta BP+23
    lda BP+12
    cmp #4
    beq bp_validate
bp_unit_x:
    lda BP+16
    clc
    adc #1
    sta BP+20
    lda BP+17
    adc #0
    sta BP+21
bp_validate:
    lda BP+12
    cmp #3
    bne bp_operation_check
    lda BP+8
    beq bp_operation_check
    rts
bp_operation_check:
    lda BP+8
    cmp #3
    bcs bp_invalid
    ; x0 < x1 <= 320; y0 < y1 <= 256.
    lda BP+17
    cmp BP+21
    bcc bp_x_ordered
    bne bp_invalid
    lda BP+16
    cmp BP+20
    bcs bp_invalid
bp_x_ordered:
    lda BP+21
    cmp #>PIXEL_WIDTH
    bcc bp_y_check
    bne bp_invalid
    lda BP+20
    cmp #<PIXEL_WIDTH
    bcc bp_y_check
    bne bp_invalid
bp_y_check:
    lda BP+19
    cmp BP+23
    bcc bp_y_ordered
    bne bp_invalid
    lda BP+18
    cmp BP+22
    bcs bp_invalid
bp_y_ordered:
    lda BP+23
    cmp #>PIXEL_HEIGHT
    bcc bp_valid
    bne bp_invalid
    lda BP+22
    cmp #<PIXEL_HEIGHT
    bcc bp_valid
    beq bp_valid
bp_invalid:
    rts
bp_valid:
    lda #1
    sta BP+9
    ; x0/6 and x0 mod 6; bounds ensure x < 228 and one-byte division.
    lda BP+16
    ldx #0
bp_div_first:
    cmp #6
    bcc bp_first_remainder
    sec
    sbc #6
    inx
    bne bp_div_first
bp_first_remainder:
    stx BP+28
    tax
    lda bp_right_masks,x
    sta BP+24
    lda bp_bit_masks,x
    sta BP+26
    lda BP+20
    sec
    sbc #1
    ldx #0
bp_div_last:
    cmp #6
    bcc bp_last_remainder
    sec
    sbc #6
    inx
    bne bp_div_last
bp_last_remainder:
    stx BP+29
    tax
    lda bp_bit_masks,x
    sta BP+27
    inx
    cpx #6
    bne bp_last_phase
    ldx #0
bp_last_phase:
    lda bp_left_masks,x
    sta BP+25
    lda BP+18
    sta BP+32
    lda BP+19
    sta BP+33
    lda BP+22
    sec
    sbc #1
    sta BP+42
    lda BP+23
    sbc #0
    sta BP+43
    ; Validate every byte in the request's bounding rectangle before storing.
    ; A control/attribute byte inside the content window is not a drawable pixel.
    lda BP+18
    sta BP+44
bp_preflight_row:
    ldx BP+44
    lda bitmap_lo,x
    sta BP+46
    lda bitmap_hi,x
    sta BP+47
    ldy BP+28
bp_preflight_byte:
    lda (BP+46),y
    and #64
    bne bp_preflight_next
    lda #0
    sta BP+9
    rts
bp_preflight_next:
    cpy BP+29
    beq bp_preflight_end_row
    iny
    bne bp_preflight_byte
bp_preflight_end_row:
    inc BP+44
    lda BP+44
    cmp BP+22
    bne bp_preflight_row
bp_row:
    lda #0
    sta BP+39
    ldx BP+32
    lda bitmap_lo,x
    sta BP+34
    lda bitmap_hi,x
    sta BP+35
    ; Add byte column to the configured row start.
    lda BP+28
    ldx #0
    stx BP+31
    clc
    adc BP+34
    sta BP+34
    lda BP+31
    adc BP+35
    sta BP+35
    lda BP+28
    sta BP+30
    lda BP+24
    sta BP+36
    lda BP+25
    sta BP+37
    lda BP+12
    cmp #1
    bne bp_bytes
    ; Middle rows of an outline contain only its left and right pixels.
    lda BP+32
    cmp BP+18
    beq bp_bytes
    cmp BP+42
    bne bp_sides
    lda BP+33
    cmp BP+43
    beq bp_bytes
bp_sides:
    lda #1
    sta BP+39
    lda BP+26
    sta BP+36
    lda BP+27
    sta BP+37
bp_bytes:
    lda #63
    sta BP+38
    lda BP+30
    cmp BP+28
    bne bp_not_first
    lda BP+36
    sta BP+38
bp_not_first:
    lda BP+30
    cmp BP+29
    bne bp_not_last
    lda BP+38
    and BP+37
    sta BP+38
    ; Same-byte outline sides need OR, not intersection.
    lda BP+39
    beq bp_not_last
    lda BP+30
    cmp BP+28
    bne bp_not_last
    lda BP+36
    ora BP+37
    sta BP+38
bp_not_last:
    ; For outline middle rows, skip bytes between the sides.
    lda BP+39
    beq bp_apply
    lda BP+30
    cmp BP+28
    beq bp_apply
    cmp BP+29
    bne bp_advance
bp_apply:
    ldy #0
    lda BP+12
    cmp #3
    bne bp_write
    lda (BP+34),y
    and BP+38
    beq bp_return
    lda #1
    sta BP+10
bp_return:
    rts
bp_write:
    lda BP+8
    beq bp_set
    cmp #1
    beq bp_clear
    lda (BP+34),y
    eor BP+38
    jmp bp_store
bp_clear:
    lda BP+38
    eor #255
    and (BP+34),y
    jmp bp_store
bp_set:
    lda BP+38
    ora (BP+34),y
bp_store:
    sta (BP+34),y
    inc BP+40
    bne bp_advance
    inc BP+41
bp_advance:
    lda BP+30
    cmp BP+29
    beq bp_next_row
    inc BP+30
    clc
    lda BP+34
    adc #1
    sta BP+34
    bcc bp_bytes_jump
    inc BP+35
bp_bytes_jump:
    jmp bp_bytes
bp_next_row:
    inc BP+32
    bne bp_row_test
    inc BP+33
bp_row_test:
    lda BP+32
    cmp BP+22
    bne bp_more_rows
    lda BP+33
    cmp BP+23
    beq bp_return
bp_more_rows:
    jmp bp_row
bp_right_masks:
    !byte 63,31,15,7,3,1
bp_left_masks:
    !byte 63,32,48,56,60,62
bp_bit_masks:
    !byte 32,16,8,4,2,1
