; SPDX-License-Identifier: MIT
; Original reset caller, not manufacturer firmware or an OS-loaded program.
*=$c000
BP=$70
COMMAND=$0600
PIXEL_WIDTH=320
PIXEL_HEIGHT=256
PIXEL_BYTE_STEP=8
start:
    sei
    cld
    ldx #$ff
    txs
    lda #$20
    sta $fe07
    lda #0
    sta $fe02
    sta $fe00
    lda #$2c
    sta $fe03
    ldx #7
palette:
    lda #$ff
    sta $fe08,x
    dex
    bpl palette
    lda #$ef
    sta $fe0e
    lda #$ee
    sta $fe0f
    lda #<22528
    sta BP+34
    lda #>22528
    sta BP+35
    ldx #40
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
    !byte 0,1,2,3,4,5,6,7,64,65,66,67,68,69,70,71
    !byte 128,129,130,131,132,133,134,135,192,193,194,195,196,197,198,199
    !byte 0,1,2,3,4,5,6,7,64,65,66,67,68,69,70,71
    !byte 128,129,130,131,132,133,134,135,192,193,194,195,196,197,198,199
bitmap_hi:
    !byte 88,88,88,88,88,88,88,88,89,89,89,89,89,89,89,89
    !byte 90,90,90,90,90,90,90,90,91,91,91,91,91,91,91,91
    !byte 93,93,93,93,93,93,93,93,94,94,94,94,94,94,94,94
    !byte 95,95,95,95,95,95,95,95,96,96,96,96,96,96,96,96
    !byte 98,98,98,98,98,98,98,98,99,99,99,99,99,99,99,99
    !byte 100,100,100,100,100,100,100,100,101,101,101,101,101,101,101,101
    !byte 103,103,103,103,103,103,103,103,104,104,104,104,104,104,104,104
    !byte 105,105,105,105,105,105,105,105,106,106,106,106,106,106,106,106
    !byte 108,108,108,108,108,108,108,108,109,109,109,109,109,109,109,109
    !byte 110,110,110,110,110,110,110,110,111,111,111,111,111,111,111,111
    !byte 113,113,113,113,113,113,113,113,114,114,114,114,114,114,114,114
    !byte 115,115,115,115,115,115,115,115,116,116,116,116,116,116,116,116
    !byte 118,118,118,118,118,118,118,118,119,119,119,119,119,119,119,119
    !byte 120,120,120,120,120,120,120,120,121,121,121,121,121,121,121,121
    !byte 123,123,123,123,123,123,123,123,124,124,124,124,124,124,124,124
    !byte 125,125,125,125,125,125,125,125,126,126,126,126,126,126,126,126
    *=$fffa
    !word start,start,start
