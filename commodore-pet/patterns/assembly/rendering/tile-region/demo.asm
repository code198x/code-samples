*=$f000
NR=$0070
RESULT=$0300
MAP=$04f0
MAP_W=12
MAP_H=8
TILE_COUNT=4
SCREEN_COLS=40
SCREEN_ROWS=25
SCREEN=$8000
HAS_COLOUR=0
COLOUR=$0000
start:
    sei
    cld
    ldx #$ff
    txs
    lda #10
    sta $e880
    lda #$20
    sta $e881
    lda #<$8000
    sta NR+20
    lda #>$8000
    sta NR+21
    ldx #4
    lda #0
    ldy #0
clear_0:
    sta (NR+20),y
    iny
    bne clear_0
    inc NR+21
    dex
    bne clear_0
    lda #<$7ff0
    sta NR+20
    lda #>$7ff0
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
    lda #<$8400
    sta NR+20
    lda #>$8400
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
    lda #24
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
    lda #25
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
    lda #24
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
