; SPDX-License-Identifier: MIT
; Original reset caller, not manufacturer firmware or an OS-loaded program.
*=$e000
BP=$0070
COMMAND=$0800
PIXEL_WIDTH=320
PIXEL_HEIGHT=200
PIXEL_BYTE_STEP=8
start:
    sei
    cld
    ldx #$ff
    txs
    lda #$2f
    sta $00
    lda #$37
    sta $01
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
    lda #3
    sta $dd02
    sta $dd00
    lda #$3b
    sta $d011
    lda #8
    sta $d016
    lda #$18
    sta $d018
    lda #$10
    ldx #0
c64_screen:
    sta $0400,x
    sta $0500,x
    sta $0600,x
    sta $0700,x
    inx
    bne c64_screen
    lda #<8192
    sta BP+34
    lda #>8192
    sta BP+35
    ldx #32
    ldy #0
    lda #0
clear_page:
    sta (BP+34),y
    iny
    bne clear_page
    inc BP+35
    dex
    bne clear_page
; A normal game call: outline a box. End coordinates are exclusive.
    lda #<13
    sta BP+0
    lda #>13
    sta BP+1
    lda #<27
    sta BP+2
    lda #>27
    sta BP+3
    lda #<91
    sta BP+4
    lda #>91
    sta BP+5
    lda #<53
    sta BP+6
    lda #>53
    sta BP+7
    lda #0
    sta BP+8
    jsr bp_box
    lda #239
    sta COMMAND+1
    lda #0
    sta COMMAND
mailbox:
    lda COMMAND
    beq mailbox
    cmp #1
    bne next_1
    jsr bp_pixel
    jmp complete
next_1:
    cmp #2
    bne next_2
    jsr bp_read
    jmp complete
next_2:
    cmp #3
    bne next_3
    jsr bp_hspan
    jmp complete
next_3:
    cmp #4
    bne next_4
    jsr bp_vspan
    jmp complete
next_4:
    cmp #5
    bne next_5
    jsr bp_fill
    jmp complete
next_5:
    cmp #6
    bne next_6
    jsr bp_box
    jmp complete
next_6:
complete:
    lda #0
    sta COMMAND
    jmp mailbox
backend_start:
    !source "../../../../../cross-platform/patterns/rendering/remaining-primitives/6502.inc"
backend_end:
bitmap_lo:
    !byte 0,1,2,3,4,5,6,7,64,65,66,67,68,69,70,71
    !byte 128,129,130,131,132,133,134,135,192,193,194,195,196,197,198,199
    !byte 0,1,2,3,4,5,6,7,64,65,66,67,68,69,70,71
    !byte 128,129,130,131,132,133,134,135,192,193,194,195,196,197,198,199
    !byte 0,1,2,3,4,5,6,7,64,65,66,67,68,69,70,71
    !byte 128,129,130,131,132,133,134,135,192,193,194,195,196,197,198,199
    !byte 0,1,2,3,4,5,6,7,64,65,66,67,68,69,70,71
    !byte 128,129,130,131,132,133,134,135,192,193,194,195,196,197,198,199
    !byte 0,1,2,3,4,5,6,7,64,65,66,67,68,69,70,71
    !byte 128,129,130,131,132,133,134,135,192,193,194,195,196,197,198,199
    !byte 0,1,2,3,4,5,6,7,64,65,66,67,68,69,70,71
    !byte 128,129,130,131,132,133,134,135,192,193,194,195,196,197,198,199
    !byte 0,1,2,3,4,5,6,7
bitmap_hi:
    !byte 32,32,32,32,32,32,32,32,33,33,33,33,33,33,33,33
    !byte 34,34,34,34,34,34,34,34,35,35,35,35,35,35,35,35
    !byte 37,37,37,37,37,37,37,37,38,38,38,38,38,38,38,38
    !byte 39,39,39,39,39,39,39,39,40,40,40,40,40,40,40,40
    !byte 42,42,42,42,42,42,42,42,43,43,43,43,43,43,43,43
    !byte 44,44,44,44,44,44,44,44,45,45,45,45,45,45,45,45
    !byte 47,47,47,47,47,47,47,47,48,48,48,48,48,48,48,48
    !byte 49,49,49,49,49,49,49,49,50,50,50,50,50,50,50,50
    !byte 52,52,52,52,52,52,52,52,53,53,53,53,53,53,53,53
    !byte 54,54,54,54,54,54,54,54,55,55,55,55,55,55,55,55
    !byte 57,57,57,57,57,57,57,57,58,58,58,58,58,58,58,58
    !byte 59,59,59,59,59,59,59,59,60,60,60,60,60,60,60,60
    !byte 62,62,62,62,62,62,62,62
    *=$fffa
    !word start,start,start
