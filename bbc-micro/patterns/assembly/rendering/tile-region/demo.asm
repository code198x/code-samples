*=$c000
NR=112
RESULT=768
MAP=1264
MAP_W=12
MAP_H=8
TILE_COUNT=4
CELL_BYTES=1
SCREEN_COLS=40
SCREEN_ROWS=32
X_STEP=8
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
    ldx #0
    lda #0
clear_0:
    sta $5800,x
    inx
    bne clear_0
    ldx #0
    lda #0
clear_1:
    sta $5900,x
    inx
    bne clear_1
    ldx #0
    lda #0
clear_2:
    sta $5a00,x
    inx
    bne clear_2
    ldx #0
    lda #0
clear_3:
    sta $5b00,x
    inx
    bne clear_3
    ldx #0
    lda #0
clear_4:
    sta $5c00,x
    inx
    bne clear_4
    ldx #0
    lda #0
clear_5:
    sta $5d00,x
    inx
    bne clear_5
    ldx #0
    lda #0
clear_6:
    sta $5e00,x
    inx
    bne clear_6
    ldx #0
    lda #0
clear_7:
    sta $5f00,x
    inx
    bne clear_7
    ldx #0
    lda #0
clear_8:
    sta $6000,x
    inx
    bne clear_8
    ldx #0
    lda #0
clear_9:
    sta $6100,x
    inx
    bne clear_9
    ldx #0
    lda #0
clear_10:
    sta $6200,x
    inx
    bne clear_10
    ldx #0
    lda #0
clear_11:
    sta $6300,x
    inx
    bne clear_11
    ldx #0
    lda #0
clear_12:
    sta $6400,x
    inx
    bne clear_12
    ldx #0
    lda #0
clear_13:
    sta $6500,x
    inx
    bne clear_13
    ldx #0
    lda #0
clear_14:
    sta $6600,x
    inx
    bne clear_14
    ldx #0
    lda #0
clear_15:
    sta $6700,x
    inx
    bne clear_15
    ldx #0
    lda #0
clear_16:
    sta $6800,x
    inx
    bne clear_16
    ldx #0
    lda #0
clear_17:
    sta $6900,x
    inx
    bne clear_17
    ldx #0
    lda #0
clear_18:
    sta $6a00,x
    inx
    bne clear_18
    ldx #0
    lda #0
clear_19:
    sta $6b00,x
    inx
    bne clear_19
    ldx #0
    lda #0
clear_20:
    sta $6c00,x
    inx
    bne clear_20
    ldx #0
    lda #0
clear_21:
    sta $6d00,x
    inx
    bne clear_21
    ldx #0
    lda #0
clear_22:
    sta $6e00,x
    inx
    bne clear_22
    ldx #0
    lda #0
clear_23:
    sta $6f00,x
    inx
    bne clear_23
    ldx #0
    lda #0
clear_24:
    sta $7000,x
    inx
    bne clear_24
    ldx #0
    lda #0
clear_25:
    sta $7100,x
    inx
    bne clear_25
    ldx #0
    lda #0
clear_26:
    sta $7200,x
    inx
    bne clear_26
    ldx #0
    lda #0
clear_27:
    sta $7300,x
    inx
    bne clear_27
    ldx #0
    lda #0
clear_28:
    sta $7400,x
    inx
    bne clear_28
    ldx #0
    lda #0
clear_29:
    sta $7500,x
    inx
    bne clear_29
    ldx #0
    lda #0
clear_30:
    sta $7600,x
    inx
    bne clear_30
    ldx #0
    lda #0
clear_31:
    sta $7700,x
    inx
    bne clear_31
    ldx #0
    lda #0
clear_32:
    sta $7800,x
    inx
    bne clear_32
    ldx #0
    lda #0
clear_33:
    sta $7900,x
    inx
    bne clear_33
    ldx #0
    lda #0
clear_34:
    sta $7a00,x
    inx
    bne clear_34
    ldx #0
    lda #0
clear_35:
    sta $7b00,x
    inx
    bne clear_35
    ldx #0
    lda #0
clear_36:
    sta $7c00,x
    inx
    bne clear_36
    ldx #0
    lda #0
clear_37:
    sta $7d00,x
    inx
    bne clear_37
    ldx #0
    lda #0
clear_38:
    sta $7e00,x
    inx
    bne clear_38
    ldx #0
    lda #0
clear_39:
    sta $7f00,x
    inx
    bne clear_39
    ldx #95
copy_map:
    lda initial_map,x
    sta MAP,x
    dex
    bpl copy_map
    lda #$a5
    sta MAP+96
    sta $57f0
    sta $57f1
    sta $57f2
    sta $57f3
    sta $57f4
    sta $57f5
    sta $57f6
    sta $57f7
    sta $57f8
    sta $57f9
    sta $57fa
    sta $57fb
    sta $57fc
    sta $57fd
    sta $57fe
    sta $57ff
case_0:
    lda #2
    sta NR+0
    lda #1
    sta NR+1
    lda #4
    sta NR+2
    lda #3
    sta NR+3
    lda #5
    sta NR+4
    lda #3
    sta NR+5
    jsr region_draw
    lda NR+6
    ora #128
    sta RESULT+1
case_1:
    lda #0
    sta NR+0
    lda #0
    sta NR+1
    lda #6
    sta NR+2
    lda #4
    sta NR+3
    lda #1
    sta NR+4
    lda #1
    sta NR+5
    jsr region_draw
    lda NR+6
    ora #128
    sta RESULT+2
case_2:
    lda #11
    sta NR+0
    lda #7
    sta NR+1
    lda #39
    sta NR+2
    lda #31
    sta NR+3
    lda #1
    sta NR+4
    lda #1
    sta NR+5
    jsr region_draw
    lda NR+6
    ora #128
    sta RESULT+3
case_3:
    lda #12
    sta NR+0
    lda #0
    sta NR+1
    lda #0
    sta NR+2
    lda #0
    sta NR+3
    lda #1
    sta NR+4
    lda #1
    sta NR+5
    jsr region_draw
    lda NR+6
    ora #128
    sta RESULT+4
case_4:
    lda #0
    sta NR+0
    lda #8
    sta NR+1
    lda #0
    sta NR+2
    lda #0
    sta NR+3
    lda #1
    sta NR+4
    lda #1
    sta NR+5
    jsr region_draw
    lda NR+6
    ora #128
    sta RESULT+5
case_5:
    lda #0
    sta NR+0
    lda #0
    sta NR+1
    lda #40
    sta NR+2
    lda #0
    sta NR+3
    lda #1
    sta NR+4
    lda #1
    sta NR+5
    jsr region_draw
    lda NR+6
    ora #128
    sta RESULT+6
case_6:
    lda #0
    sta NR+0
    lda #0
    sta NR+1
    lda #0
    sta NR+2
    lda #32
    sta NR+3
    lda #1
    sta NR+4
    lda #1
    sta NR+5
    jsr region_draw
    lda NR+6
    ora #128
    sta RESULT+7
case_7:
    lda #0
    sta NR+0
    lda #0
    sta NR+1
    lda #0
    sta NR+2
    lda #0
    sta NR+3
    lda #0
    sta NR+4
    lda #1
    sta NR+5
    jsr region_draw
    lda NR+6
    ora #128
    sta RESULT+8
case_8:
    lda #0
    sta NR+0
    lda #0
    sta NR+1
    lda #0
    sta NR+2
    lda #0
    sta NR+3
    lda #1
    sta NR+4
    lda #0
    sta NR+5
    jsr region_draw
    lda NR+6
    ora #128
    sta RESULT+9
case_9:
    lda #11
    sta NR+0
    lda #0
    sta NR+1
    lda #0
    sta NR+2
    lda #0
    sta NR+3
    lda #2
    sta NR+4
    lda #1
    sta NR+5
    jsr region_draw
    lda NR+6
    ora #128
    sta RESULT+10
case_10:
    lda #0
    sta NR+0
    lda #7
    sta NR+1
    lda #0
    sta NR+2
    lda #0
    sta NR+3
    lda #1
    sta NR+4
    lda #2
    sta NR+5
    jsr region_draw
    lda NR+6
    ora #128
    sta RESULT+11
case_11:
    lda #0
    sta NR+0
    lda #0
    sta NR+1
    lda #39
    sta NR+2
    lda #0
    sta NR+3
    lda #2
    sta NR+4
    lda #1
    sta NR+5
    jsr region_draw
    lda NR+6
    ora #128
    sta RESULT+12
case_12:
    lda #0
    sta NR+0
    lda #0
    sta NR+1
    lda #0
    sta NR+2
    lda #31
    sta NR+3
    lda #1
    sta NR+4
    lda #2
    sta NR+5
    jsr region_draw
    lda NR+6
    ora #128
    sta RESULT+13
case_13:
    lda #255
    sta NR+0
    lda #0
    sta NR+1
    lda #0
    sta NR+2
    lda #0
    sta NR+3
    lda #2
    sta NR+4
    lda #1
    sta NR+5
    jsr region_draw
    lda NR+6
    ora #128
    sta RESULT+14
case_14:
    lda #0
    sta NR+0
    lda #0
    sta NR+1
    lda #255
    sta NR+2
    lda #0
    sta NR+3
    lda #2
    sta NR+4
    lda #1
    sta NR+5
    jsr region_draw
    lda NR+6
    ora #128
    sta RESULT+15
case_15:
    lda #0
    sta NR+0
    lda #0
    sta NR+1
    lda #0
    sta NR+2
    lda #255
    sta NR+3
    lda #1
    sta NR+4
    lda #2
    sta NR+5
    jsr region_draw
    lda NR+6
    ora #128
    sta RESULT+16
case_16:
    lda #0
    sta NR+0
    lda #0
    sta NR+1
    lda #0
    sta NR+2
    lda #0
    sta NR+3
    lda #255
    sta NR+4
    lda #1
    sta NR+5
    jsr region_draw
    lda NR+6
    ora #128
    sta RESULT+17
case_17:
    lda #255
    sta MAP+13
    lda #0
    sta NR+0
    lda #1
    sta NR+1
    lda #0
    sta NR+2
    lda #0
    sta NR+3
    lda #2
    sta NR+4
    lda #1
    sta NR+5
    jsr region_draw
    lda NR+6
    ora #128
    sta RESULT+18
diagnostic_done:
    lda #239
    sta RESULT
finished:
    jmp finished
!source "../../../../../cross-platform/patterns/rendering/bitmap-regions/6502.inc"
initial_map:
!byte 0,1,2,3,0,1,2,3,0,1,2,3,2,3,0,1,2,3,0,1,2,3,0,1,0,1,2,3,0,1,2,3,0,1,2,3,2,3,0,1,2,3,0,1,2,3,0,1,0,1,2,3,0,1,2,3,0,1,2,3,2,3,0,1,2,3,0,1,2,3,0,1,0,1,2,3,0,1,2,3,0,1,2,3,2,3,0,1,2,3,0,1,2,3,0,1
TILES:
!byte 0,0,0,0,0,0,0,0
!byte 170,85,170,85,170,85,170,85
!byte 255,129,129,129,129,129,129,255
!byte 129,66,36,24,24,36,66,129
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
