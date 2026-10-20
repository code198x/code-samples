*=$c000
NR=112
RESULT=768
MAP=1264
MAP_W=12
MAP_H=8
TILE_COUNT=4
CELL_BYTES=1
SCREEN_COLS=32
SCREEN_ROWS=24
X_STEP=1
start:
    sei
    cld
    ldx #$ff
    txs
    lda #$8a
    sta $b003
    lda #$f0
    sta $b000
    ldx #0
    lda #0
clear_0:
    sta $8000,x
    inx
    bne clear_0
    ldx #0
    lda #0
clear_1:
    sta $8100,x
    inx
    bne clear_1
    ldx #0
    lda #0
clear_2:
    sta $8200,x
    inx
    bne clear_2
    ldx #0
    lda #0
clear_3:
    sta $8300,x
    inx
    bne clear_3
    ldx #0
    lda #0
clear_4:
    sta $8400,x
    inx
    bne clear_4
    ldx #0
    lda #0
clear_5:
    sta $8500,x
    inx
    bne clear_5
    ldx #0
    lda #0
clear_6:
    sta $8600,x
    inx
    bne clear_6
    ldx #0
    lda #0
clear_7:
    sta $8700,x
    inx
    bne clear_7
    ldx #0
    lda #0
clear_8:
    sta $8800,x
    inx
    bne clear_8
    ldx #0
    lda #0
clear_9:
    sta $8900,x
    inx
    bne clear_9
    ldx #0
    lda #0
clear_10:
    sta $8a00,x
    inx
    bne clear_10
    ldx #0
    lda #0
clear_11:
    sta $8b00,x
    inx
    bne clear_11
    ldx #0
    lda #0
clear_12:
    sta $8c00,x
    inx
    bne clear_12
    ldx #0
    lda #0
clear_13:
    sta $8d00,x
    inx
    bne clear_13
    ldx #0
    lda #0
clear_14:
    sta $8e00,x
    inx
    bne clear_14
    ldx #0
    lda #0
clear_15:
    sta $8f00,x
    inx
    bne clear_15
    ldx #0
    lda #0
clear_16:
    sta $9000,x
    inx
    bne clear_16
    ldx #0
    lda #0
clear_17:
    sta $9100,x
    inx
    bne clear_17
    ldx #0
    lda #0
clear_18:
    sta $9200,x
    inx
    bne clear_18
    ldx #0
    lda #0
clear_19:
    sta $9300,x
    inx
    bne clear_19
    ldx #0
    lda #0
clear_20:
    sta $9400,x
    inx
    bne clear_20
    ldx #0
    lda #0
clear_21:
    sta $9500,x
    inx
    bne clear_21
    ldx #0
    lda #0
clear_22:
    sta $9600,x
    inx
    bne clear_22
    ldx #0
    lda #0
clear_23:
    sta $9700,x
    inx
    bne clear_23
    ldx #95
copy_map:
    lda initial_map,x
    sta MAP,x
    dex
    bpl copy_map
    lda #$a5
    sta MAP+96
    sta $0550
    sta $0551
    sta $0552
    sta $0553
    sta $0554
    sta $0555
    sta $0556
    sta $0557
    sta $0558
    sta $0559
    sta $055a
    sta $055b
    sta $055c
    sta $055d
    sta $055e
    sta $055f
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
    lda #31
    sta NR+2
    lda #23
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
    lda #32
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
    lda #24
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
    lda #31
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
    lda #23
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
!fill $fffa-*,0
!word start,start,start
