; SPDX-License-Identifier: MIT
; Original reset caller, not manufacturer firmware or an OS-loaded program.
*=$c000
BP=$70
COMMAND=$0600
PIXEL_WIDTH=256
PIXEL_HEIGHT=192
PIXEL_BYTE_STEP=1
start:
    sei
    cld
    ldx #$ff
    txs
    lda #$8a
    sta $b003
    lda #$f0
    sta $b000
    lda #<32768
    sta BP+34
    lda #>32768
    sta BP+35
    ldx #24
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
    !byte 0,32,64,96,128,160,192,224,0,32,64,96,128,160,192,224
    !byte 0,32,64,96,128,160,192,224,0,32,64,96,128,160,192,224
    !byte 0,32,64,96,128,160,192,224,0,32,64,96,128,160,192,224
    !byte 0,32,64,96,128,160,192,224,0,32,64,96,128,160,192,224
    !byte 0,32,64,96,128,160,192,224,0,32,64,96,128,160,192,224
    !byte 0,32,64,96,128,160,192,224,0,32,64,96,128,160,192,224
    !byte 0,32,64,96,128,160,192,224,0,32,64,96,128,160,192,224
    !byte 0,32,64,96,128,160,192,224,0,32,64,96,128,160,192,224
    !byte 0,32,64,96,128,160,192,224,0,32,64,96,128,160,192,224
    !byte 0,32,64,96,128,160,192,224,0,32,64,96,128,160,192,224
    !byte 0,32,64,96,128,160,192,224,0,32,64,96,128,160,192,224
    !byte 0,32,64,96,128,160,192,224,0,32,64,96,128,160,192,224
bitmap_hi:
    !byte 128,128,128,128,128,128,128,128,129,129,129,129,129,129,129,129
    !byte 130,130,130,130,130,130,130,130,131,131,131,131,131,131,131,131
    !byte 132,132,132,132,132,132,132,132,133,133,133,133,133,133,133,133
    !byte 134,134,134,134,134,134,134,134,135,135,135,135,135,135,135,135
    !byte 136,136,136,136,136,136,136,136,137,137,137,137,137,137,137,137
    !byte 138,138,138,138,138,138,138,138,139,139,139,139,139,139,139,139
    !byte 140,140,140,140,140,140,140,140,141,141,141,141,141,141,141,141
    !byte 142,142,142,142,142,142,142,142,143,143,143,143,143,143,143,143
    !byte 144,144,144,144,144,144,144,144,145,145,145,145,145,145,145,145
    !byte 146,146,146,146,146,146,146,146,147,147,147,147,147,147,147,147
    !byte 148,148,148,148,148,148,148,148,149,149,149,149,149,149,149,149
    !byte 150,150,150,150,150,150,150,150,151,151,151,151,151,151,151,151
    *=$fffa
    !word start,start,start
