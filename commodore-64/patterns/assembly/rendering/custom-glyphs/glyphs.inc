; SPDX-License-Identifier: MIT
; C64 standard hi-res character RAM component. G = 24 private zero-page bytes.
; +0 CPU source word; +2 first byte; +3 count byte (1..255); +4 code byte;
; +5 cell word; +7 status; +8 data-write count word; +10..23 scratch. LE words.
; Inputs 0..6 preserved. A/X/Y/flags clobbered, decimal clear; non-reentrant.
; Source must remain readable without wrapping/overlap. No bank/IRQ changes.
; Caller owns VIC bank, character/screen bases, colour RAM and CPU mapping.
glyph_init:
    jsr glyph_reset_result
    lda #<8192
    sta G+12
    lda #>8192
    sta G+13
    lda #<2048
    sta G+16
    lda #>2048
    sta G+17
    jsr glyph_zero_range
    lda #<1024
    sta G+12
    lda #>1024
    sta G+13
    lda #<1000
    sta G+16
    lda #>1000
    sta G+17
    jsr glyph_zero_range
    jmp glyph_accept
glyph_zero_range:
    jsr glyph_address
zero_next:
    lda #0
    jsr glyph_store
    jsr glyph_decrement
    bne zero_next
    rts
glyph_replace:
    lda #1
    bne glyph_begin
glyph_install:
    lda G+3
glyph_begin:
    sta G+10
    jsr glyph_reset_result
    lda G+10
    beq glyph_reject
    clc
    adc G+2
    bcc glyph_range_ok
    bne glyph_reject ; carry plus zero is the legal exclusive end 256
 glyph_range_ok:
    lda G+2
    asl
    sta G+12
    lda #0
    rol
    sta G+13
    asl G+12
    rol G+13
    asl G+12
    rol G+13
    lda G+13
    clc
    adc #>8192
    sta G+13
    jsr glyph_address
    lda G
    sta G+14
    lda G+1
    sta G+15
    lda G+10
    sta G+16
    lda #0
    sta G+17
    asl G+16
    rol G+17
    asl G+16
    rol G+17
    asl G+16
    rol G+17
    ldy #0
copy_next:
    lda (G+14),y
    jsr glyph_store
    inc G+14
    bne source_ok
    inc G+15
source_ok:
    jsr glyph_decrement
    bne copy_next
glyph_accept:
    lda #1
    sta G+7
glyph_reject:
    rts
glyph_select:
    jsr glyph_reset_result
    lda G+6
    cmp #>1000
    bcc cell_ok
    bne glyph_reject
    lda G+5
    cmp #<1000
    bcs glyph_reject
cell_ok:
    lda G+5
    sta G+12
    lda G+6
    clc
    adc #>1024
    sta G+13
    jsr glyph_address
    lda G+4
    jsr glyph_store
    jmp glyph_accept
glyph_reset_result:
    lda #0
    sta G+7
    sta G+8
    sta G+9
    rts
glyph_decrement:
    lda G+16
    bne length_low
    dec G+17
length_low:
    dec G+16
    lda G+16
    ora G+17
    rts
glyph_address:
    rts
glyph_store:
    ldy #0
    sta (G+12),y
    inc G+12
    bne destination_ok
    inc G+13
destination_ok:
    inc G+8
    bne count_ok
    inc G+9
count_ok:
    rts
