*=$c000
NR=$0070
RESULT=$0300
MAP=$04f0
MAP_W=12
MAP_H=8
TILE_COUNT=4
SCREEN_COLS=40
SCREEN_ROWS=32
SCREEN=$5800
CELL_BYTES=1
X_STEP=8
TILES=$0800
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
    lda #<$5800
    sta NR+20
    lda #>$5800
    sta NR+21
    ldx #40
    lda #0
    ldy #0
clear_0:
    sta (NR+20),y
    iny
    bne clear_0
    inc NR+21
    dex
    bne clear_0
    lda #<$57e0
    sta NR+20
    lda #>$57e0
    sta NR+21
    ldx #0
    lda #165
    ldy #0
clear_1:
clear_tail_1:
    sta (NR+20),y
    iny
    cpy #16
    bne clear_tail_1
    lda #<$57f0
    sta NR+20
    lda #>$57f0
    sta NR+21
    ldx #0
    lda #165
    ldy #0
clear_2:
clear_tail_2:
    sta (NR+20),y
    iny
    cpy #16
    bne clear_tail_2
    ldx #31
copy_tiles:
    lda tile_data,x
    sta TILES,x
    dex
    bpl copy_tiles
    ldx #95
copy_map:
    lda initial_map,x
    sta MAP,x
    dex
    bpl copy_map
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
    lda #4
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
halt:
    jmp halt
initial_map:
!byte 0,1,2,3,0,1,2,3,0,1,2,3,2,3,0,1,2,3,0,1,2,3,0,1,0,1,2,3,0,1,2,3,0,1,2,3,2,3,0,1,2,3,0,1,2,3,0,1,0,1,2,3,0,1,2,3,0,1,2,3,2,3,0,1,2,3,0,1,2,3,0,1,0,1,2,3,0,1,2,3,0,1,2,3,2,3,0,1,2,3,0,1,2,3,0,1
tile_data:
!byte 0,0,0,0,0,0,0,0,170,85,170,85,170,85,170,85,255,129,129,129,129,129,129,255,129,66,36,24,24,36,66,129
glyph_codes:
!byte 0,1,2,3
tile_colours:
!byte 1,1,2,5
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
!source "../../../../../cross-platform/patterns/rendering/bitmap-regions/6502.inc"
!fill $fffa-*,0
!word start,start,start
