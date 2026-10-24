; SPDX-License-Identifier: MIT
; Extend glyphs.inc, G=24 private ZP bytes, code/context below $a000.
; A=ROM half 0/1. X=caller's known $01 output-latch shadow (not a port read).
; Standard no-cartridge mapping; KERNAL already out, banking DDR bits outputs.
; Safe RAM NMI vector/handler and CIA2 NMI ownership are caller prerequisites.
; Preserves inputs G..G+6 and caller P, including I/D; A/X/Y clobbered.
; G+7 accepted, G+8/9 data writes. Leaves screen/colour RAM/DDR untouched.
glyph_init_rom:
    sta G+11
    stx G+10
    php
    sei
    cld
    jsr glyph_reset_result
    lda G+11
    cmp #2
    bcs rom_reject
    lda $00
    and #7
    cmp #7
    bne rom_reject
    lda G+10
    and #2
    bne rom_reject
    lda G+10
    eor $01
    and $00
    and #$3f
    bne rom_reject
    lda G+10
    and #$f8
!if ROM_WRONG {
    ora #5 ; Deliberate error: leave I/O visible instead of character ROM.
} else {
    ora #1
}
    sta $01
    lda #0
    sta G+12
    sta G+14
    sta G+16
    lda #$20
    sta G+13
    lda #8
    sta G+17
    lda G+11
    asl
    asl
    asl
    clc
    adc #$d0
    sta G+15
rom_copy:
    ldy #0
    lda (G+14),y
    jsr glyph_store
    inc G+14
    bne rom_source_ok
    inc G+15
rom_source_ok:
    jsr glyph_decrement
    bne rom_copy
    lda G+10
    sta $01
    lda #1
    sta G+7
rom_reject:
    plp
    rts
rom_init_end:
