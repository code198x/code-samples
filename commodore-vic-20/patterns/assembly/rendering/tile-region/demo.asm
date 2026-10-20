*=$e000
NR=$0070
RESULT=$1600
MAP=$16f0
MAP_W=12
MAP_H=8
TILE_COUNT=4
SCREEN_COLS=22
SCREEN_ROWS=23
SCREEN=$1e00
HAS_COLOUR=1
COLOUR=$9600
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
    ldx #31
copy_glyphs:
    lda tile_data,x
    sta $1000,x
    dex
    bpl copy_glyphs
    lda #<$1e00
    sta NR+20
    lda #>$1e00
    sta NR+21
    ldx #2
    lda #0
    ldy #0
clear_0:
    sta (NR+20),y
    iny
    bne clear_0
    inc NR+21
    dex
    bne clear_0
    lda #<$9600
    sta NR+20
    lda #>$9600
    sta NR+21
    ldx #2
    lda #1
    ldy #0
clear_1:
    sta (NR+20),y
    iny
    bne clear_1
    inc NR+21
    dex
    bne clear_1
    lda #<$1df0
    sta NR+20
    lda #>$1df0
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
    lda #<$95f0
    sta NR+20
    lda #>$95f0
    sta NR+21
    ldx #0
    lda #5
    ldy #0
clear_3:
clear_tail_3:
    sta (NR+20),y
    iny
    cpy #16
    bne clear_tail_3
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
    lda #21
    sta NR+2
    lda #22
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
    lda #22
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
    lda #23
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
    lda #21
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
    lda #22
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
!byte 0,3,1,2
tile_colours:
!byte 1,1,2,5
!source "../../../../../cross-platform/patterns/rendering/character-regions/6502.inc"
!fill $fffa-*,0
!word start,start,start
