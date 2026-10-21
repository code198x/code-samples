; SPDX-License-Identifier: MIT
; oric: selected character-RAM allocation, G=24 private zero-page bytes.
; +0 CPU source word; +2 first slot byte; +3 count byte; +4 screen-code byte;
; +5 logical cell word; +7 output accepted; +8 output data-write word; +10..23 scratch.
; Inputs +0..6 survive. A/X/Y/flags clobbered, clear decimal; non-reentrant.
; Trusted readable source must not wrap/overlap; caller owns video/banks/IRQs.
; Allocations, bounds, character-code and colour rules are in the family README.
glyph_init:
    jsr glyph_reset_result
    lda #<46336
    sta G+12
    lda #>46336
    sta G+13
    lda #<768
    sta G+16
    lda #>768
    sta G+17
    jsr glyph_zero_range
    lda #<$bb83
    sta G+12
    lda #>$bb83
    sta G+13
    lda #28
    sta G+18
init_row:
    lda #37
    sta G+19
init_cell:
    lda #32
    jsr glyph_store
    dec G+19
    bne init_cell
    clc
    lda G+12
    adc #3
    sta G+12
    bcc init_next
    inc G+13
init_next:
    dec G+18
    bne init_row
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
    lda G+2
    cmp #32
    bcc glyph_reject
    cmp #128
    bcs glyph_reject
    lda G+10
    clc
    adc G+2
    bcs glyph_reject
    cmp #129
    bcs glyph_reject
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
    adc #>46080
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
    lda G+4
    and #127
    cmp #32
    bcc glyph_reject
    lda G+6
    cmp #>1036
    bcc cell_ok
    bne glyph_reject
    lda G+5
    cmp #<1036
    bcs glyph_reject
cell_ok:
    lda G+5
    sta G+20
    lda G+6
    sta G+21
    lda #<$bb83
    sta G+12
    lda #>$bb83
    sta G+13
find_row:
    lda G+21
    bne subtract_row
    lda G+20
    cmp #37
    bcc found_row
subtract_row:
    sec
    lda G+20
    sbc #37
    sta G+20
    lda G+21
    sbc #0
    sta G+21
    clc
    lda G+12
    adc #40
    sta G+12
    bcc find_row
    inc G+13
    jmp find_row
found_row:
    clc
    lda G+12
    adc G+20
    sta G+12
    bcc name_address
    inc G+13
name_address:
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
