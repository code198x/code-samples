; SPDX-License-Identifier: MIT
; Original reset caller; mailbox only serves independent verification.
*=$e000
G=$0040
COMMAND=$1600
start:
    sei
    cld
    ldx #$ff
    txs
    lda #12
    sta $9000
    lda #38
    sta $9001
    lda #150
    sta $9002
    lda #46
    sta $9003
    lda #252
    sta $9005
    lda #8
    sta $900f
    ldx #0
    lda #1
colours:
    sta $9600,x
    sta $9700,x
    inx
    bne colours
    lda #165
    ldx #15
seed_guards:
    sta $1400,x
    sta $1df0,x
    dex
    bpl seed_guards
    ldx #5
seed_after:
    sta $1ffa,x
    dex
    bpl seed_after
    jsr glyph_init
; Install two original glyphs in slots 1 and 2, then select slot 1 twice.
    lda #<original_glyphs
    sta G
    lda #>original_glyphs
    sta G+1
    lda #1
    sta G+2
    lda #2
    sta G+3
    jsr glyph_install
    lda #1
    sta G+4
    lda #0
    sta G+6
    lda #46
    sta G+5
    jsr glyph_select
    inc G+5
    jsr glyph_select
    lda #0
    sta COMMAND
    lda #239
    sta COMMAND+1
mailbox:
    lda COMMAND
    beq mailbox
    cmp #1
    bne command_2
    jsr glyph_init
    jmp complete
command_2:
    cmp #2
    bne command_3
    jsr glyph_install
    jmp complete
command_3:
    cmp #3
    bne command_4
    jsr glyph_replace
    jmp complete
command_4:
    cmp #4
    bne command_5
    jsr glyph_select
    jmp complete
command_5:
complete:
    lda #0
    sta COMMAND
    jmp mailbox
    !source "glyphs.inc"
original_glyphs:
    !byte 129,66,36,24,24,36,66,129,255,129,165,129,165,153,129,255
!fill $fffa-*,0
!word start,start,start
