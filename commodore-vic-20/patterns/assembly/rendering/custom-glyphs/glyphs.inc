; SPDX-License-Identifier: MIT
; Unexpanded VIC-20, hi-res 8x8 chars, CPU glyphs $1000..13ff, screen $1e00.
; G reserves 24 zero-page bytes. +0 source word, +2 first slot, +3 count (1..128),
; +4 code, +5 cell word (0..505), +7 status, +8 word bytes written (all LE).
; Inputs preserved. +10..23 scratch. A/X/Y/flags destroyed; decimal mode off.
; glyph_init blanks owned glyphs and screen; caller owns video/colour setup.
; glyph_replace ignores +3, replaces one slot. select never writes glyph RAM.
; Trusted readable source range, no overlap with destination/context; IRQ owners
; must not share G or these resources. No bank or interrupt changes here.
glyph_init:
    lda #0
    sta G+7
    sta G+8
    sta G+9
    ldx #0
glyph_blank:
    sta $1000,x
    sta $1100,x
    sta $1200,x
    sta $1300,x
    sta $1e00,x
    inx
    bne glyph_blank
    ldx #0
glyph_blank_tail:
    sta $1f00,x
    inx
    cpx #250
    bne glyph_blank_tail
    lda #250
    sta G+8
    lda #5
    sta G+9
    lda #1
    sta G+7
    rts
glyph_replace:
    lda #1
    bne glyph_begin
glyph_install:
    lda G+3
glyph_begin:
    sta G+10
    lda #0
    sta G+7
    sta G+8
    sta G+9
    lda G+10
    beq glyph_invalid
    clc
    adc G+2
    bcs glyph_invalid
    cmp #129
    bcs glyph_invalid
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
    adc #$10
    sta G+13
    lda G
    sta G+14
    lda G+1
    sta G+15
    ldy #0
glyph_next:
    ldx #8
glyph_row:
    lda (G+14),y
    sta (G+12),y
    inc G+14
    bne glyph_src_ok
    inc G+15
glyph_src_ok:
    inc G+12
    bne glyph_dst_ok
    inc G+13
glyph_dst_ok:
    inc G+8
    bne glyph_count_ok
    inc G+9
glyph_count_ok:
    dex
    bne glyph_row
    dec G+10
    bne glyph_next
    lda #1
    sta G+7
glyph_invalid:
    rts
glyph_select:
    lda #0
    sta G+7
    sta G+8
    sta G+9
    lda G+4
    cmp #128
    bcs glyph_invalid
    lda G+6
    cmp #1
    bcc glyph_cell_ok
    bne glyph_invalid
    lda G+5
    cmp #250
    bcs glyph_invalid
glyph_cell_ok:
    lda G+5
    sta G+12
    lda G+6
    clc
    adc #$1e
    sta G+13
    ldy #0
    lda G+4
    sta (G+12),y
    lda #1
    sta G+7
    sta G+8
    rts
