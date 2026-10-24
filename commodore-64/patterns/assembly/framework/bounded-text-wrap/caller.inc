*=$0801
    !byte $0b,$08,$0a,$00,$9e
    !text "2064"
    !byte 0,0,0
*=$0810
start:
    sei
    cld
    lda #$7f
    sta $dc0d
    sta $dd0d
    lda $dc0d
    lda $dd0d
    lda #0
    sta $d01a
    sta $d015
    sta $d020
    sta $d021
    lda $dd02
    ora #3
    sta $dd02
    lda $dd00
    ora #3
    sta $dd00
    lda #$1b
    sta $d011
    lda #8
    sta $d016
    lda #$18
    sta $d018
    ldx #0
    lda #0
clear_screen:
    sta $0400,x
    sta $0500,x
    sta $0600,x
    sta $0700,x
    inx
    bne clear_screen
    lda #1
colours:
    sta $d800,x
    sta $d900,x
    sta $da00,x
    sta $db00,x
    inx
    bne colours
    ldx #0
copy_font:
    lda hex_font,x
    sta $2000,x
    inx
    cpx #136
    bne copy_font
    jsr exercise_rules
    ldx #0
    ldy #0
show_byte:
    lda preview,x
    lsr
    lsr
    lsr
    lsr
    clc
    adc #1
    sta $0400,y
    iny
    lda preview,x
    and #15
    clc
    adc #1
    sta $0400,y
    iny
    iny
    inx
    cpx #8
    bne show_byte
    lda #165
    sta ready
hold:
    jmp hold
