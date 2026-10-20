; SPDX-License-Identifier: MIT
; Original reset fixture; mailbox is verification transport, not a game loop.
*=$c000
BP=$0040
COMMAND=$0300
PIXEL_WIDTH=320
PIXEL_HEIGHT=256
start:
    sei
    cld
    ldx #$ff
    txs
    lda #8
    sta $fe20
    lda #0
    sta $fe00
    lda #63
    sta $fe01
    lda #1
    sta $fe00
    lda #40
    sta $fe01
    lda #2
    sta $fe00
    lda #49
    sta $fe01
    lda #3
    sta $fe00
    lda #36
    sta $fe01
    lda #4
    sta $fe00
    lda #38
    sta $fe01
    lda #5
    sta $fe00
    lda #0
    sta $fe01
    lda #6
    sta $fe00
    lda #32
    sta $fe01
    lda #7
    sta $fe00
    lda #34
    sta $fe01
    lda #8
    sta $fe00
    lda #0
    sta $fe01
    lda #9
    sta $fe00
    lda #7
    sta $fe01
    lda #10
    sta $fe00
    lda #32
    sta $fe01
    lda #11
    sta $fe00
    lda #0
    sta $fe01
    lda #12
    sta $fe00
    lda #11
    sta $fe01
    lda #13
    sta $fe00
    lda #0
    sta $fe01
    lda #7
    sta $fe21
    lda #23
    sta $fe21
    lda #39
    sta $fe21
    lda #55
    sta $fe21
    lda #71
    sta $fe21
    lda #87
    sta $fe21
    lda #103
    sta $fe21
    lda #119
    sta $fe21
    lda #128
    sta $fe21
    lda #144
    sta $fe21
    lda #160
    sta $fe21
    lda #176
    sta $fe21
    lda #192
    sta $fe21
    lda #208
    sta $fe21
    lda #224
    sta $fe21
    lda #240
    sta $fe21
    lda #0
    ldx #0
clear_bitmap:
    sta $5800,x
    sta $5900,x
    sta $5a00,x
    sta $5b00,x
    sta $5c00,x
    sta $5d00,x
    sta $5e00,x
    sta $5f00,x
    sta $6000,x
    sta $6100,x
    sta $6200,x
    sta $6300,x
    sta $6400,x
    sta $6500,x
    sta $6600,x
    sta $6700,x
    sta $6800,x
    sta $6900,x
    sta $6a00,x
    sta $6b00,x
    sta $6c00,x
    sta $6d00,x
    sta $6e00,x
    sta $6f00,x
    sta $7000,x
    sta $7100,x
    sta $7200,x
    sta $7300,x
    sta $7400,x
    sta $7500,x
    sta $7600,x
    sta $7700,x
    sta $7800,x
    sta $7900,x
    sta $7a00,x
    sta $7b00,x
    sta $7c00,x
    sta $7d00,x
    sta $7e00,x
    sta $7f00,x
    inx
    bne clear_bitmap
    lda #$a5
    ldx #15
set_guard:
    sta $57f0,x
    dex
    bpl set_guard
    lda #0
    sta COMMAND
    lda #$ef
    sta COMMAND+1
; Example: set a single pixel. Public inputs use little-endian words.
    lda #0
    sta BP
    sta BP+1
    sta BP+2
    sta BP+3
    sta BP+8
    jsr bp_pixel
mailbox:
    lda COMMAND
    beq mailbox
    cmp #1
    bne command_2
    jsr bp_fill
    jmp complete
command_2:
    cmp #2
    bne command_3
    jsr bp_box
    jmp complete
command_3:
    cmp #3
    bne command_4
    jsr bp_pixel
    jmp complete
command_4:
    cmp #4
    bne command_5
    jsr bp_read
    jmp complete
command_5:
    cmp #5
    bne command_6
    jsr bp_hspan
    jmp complete
command_6:
    cmp #6
    bne command_7
    jsr bp_vspan
    jmp complete
command_7:
complete:
    lda #0
    sta COMMAND
    jmp mailbox
    !source "../../../../../cross-platform/patterns/rendering/drawing-foundations/6502.inc"
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
!fill $fffa-*,0
!word start,start,start
