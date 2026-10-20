*=$e000
NR=112
RESULT=768
MAP=1264
MAP_W=12
MAP_H=8
TILE_COUNT=4
CELL_BYTES=1
SCREEN_COLS=40
SCREEN_ROWS=24
X_STEP=1
start:
    sei
    cld
    ldx #$ff
    txs
    lda #<16384
    sta NR+20
    lda #>16384
    sta NR+21
    lda #0
    ldx #0
clear_0:
    sta $4000,x
    inx
    bne clear_0
    lda #0
    ldx #0
clear_1:
    sta $4100,x
    inx
    bne clear_1
    lda #0
    ldx #0
clear_2:
    sta $4200,x
    inx
    bne clear_2
    lda #0
    ldx #0
clear_3:
    sta $4300,x
    inx
    bne clear_3
    lda #0
    ldx #0
clear_4:
    sta $4400,x
    inx
    bne clear_4
    lda #0
    ldx #0
clear_5:
    sta $4500,x
    inx
    bne clear_5
    lda #0
    ldx #0
clear_6:
    sta $4600,x
    inx
    bne clear_6
    lda #0
    ldx #0
clear_7:
    sta $4700,x
    inx
    bne clear_7
    lda #0
    ldx #0
clear_8:
    sta $4800,x
    inx
    bne clear_8
    lda #0
    ldx #0
clear_9:
    sta $4900,x
    inx
    bne clear_9
    lda #0
    ldx #0
clear_10:
    sta $4a00,x
    inx
    bne clear_10
    lda #0
    ldx #0
clear_11:
    sta $4b00,x
    inx
    bne clear_11
    lda #0
    ldx #0
clear_12:
    sta $4c00,x
    inx
    bne clear_12
    lda #0
    ldx #0
clear_13:
    sta $4d00,x
    inx
    bne clear_13
    lda #0
    ldx #0
clear_14:
    sta $4e00,x
    inx
    bne clear_14
    lda #0
    ldx #0
clear_15:
    sta $4f00,x
    inx
    bne clear_15
    lda #0
    ldx #0
clear_16:
    sta $5000,x
    inx
    bne clear_16
    lda #0
    ldx #0
clear_17:
    sta $5100,x
    inx
    bne clear_17
    lda #0
    ldx #0
clear_18:
    sta $5200,x
    inx
    bne clear_18
    lda #0
    ldx #0
clear_19:
    sta $5300,x
    inx
    bne clear_19
    lda #0
    ldx #0
clear_20:
    sta $5400,x
    inx
    bne clear_20
    lda #0
    ldx #0
clear_21:
    sta $5500,x
    inx
    bne clear_21
    lda #0
    ldx #0
clear_22:
    sta $5600,x
    inx
    bne clear_22
    lda #0
    ldx #0
clear_23:
    sta $5700,x
    inx
    bne clear_23
    lda #0
    ldx #0
clear_24:
    sta $5800,x
    inx
    bne clear_24
    lda #0
    ldx #0
clear_25:
    sta $5900,x
    inx
    bne clear_25
    lda #0
    ldx #0
clear_26:
    sta $5a00,x
    inx
    bne clear_26
    lda #0
    ldx #0
clear_27:
    sta $5b00,x
    inx
    bne clear_27
    lda #0
    ldx #0
clear_28:
    sta $5c00,x
    inx
    bne clear_28
    lda #0
    ldx #0
clear_29:
    sta $5d00,x
    inx
    bne clear_29
    lda #0
    ldx #0
clear_30:
    sta $5e00,x
    inx
    bne clear_30
    lda #0
    ldx #0
clear_31:
    sta $5f00,x
    inx
    bne clear_31
    lda #0
    sta $d400
    sta $d40e
    sta $d01b
    sta $d01a
    sta $d018
    lda #14
    sta $d017
    ldx #0
copy_display_list:
    lda display_list,x
    sta $3000,x
    lda display_list+256,x
    sta $3100,x
    lda display_list+512,x
    sta $3200,x
    inx
    bne copy_display_list
    lda #0
    sta $d402
    lda #48
    sta $d403
    ldx #95
copy_map:
    lda initial_map,x
    sta MAP,x
    dex
    bpl copy_map
    lda #165
    sta $3ff0
    sta $3ff1
    sta $3ff2
    sta $3ff3
    sta $3ff4
    sta $3ff5
    sta $3ff6
    sta $3ff7
    sta $3ff8
    sta $3ff9
    sta $3ffa
    sta $3ffb
    sta $3ffc
    sta $3ffd
    sta $3ffe
    sta $3fff
    lda #165
    sta $6000
    sta $6001
    sta $6002
    sta $6003
    sta $6004
    sta $6005
    sta $6006
    sta $6007
    sta $6008
    sta $6009
    sta $600a
    sta $600b
    sta $600c
    sta $600d
    sta $600e
    sta $600f
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
    lda #34
    sta $d400
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
!byte 0,40,80,120,160,200,240,24,64,104,144,184,224,8,48,88
!byte 128,168,208,248,32,72,112,152,192,232,16,56,96,136,176,216
!byte 0,40,80,120,160,200,240,24,64,104,144,184,224,8,48,88
!byte 128,168,208,248,32,72,112,152,192,232,16,56,96,136,176,216
!byte 0,40,80,120,160,200,240,24,64,104,144,184,224,8,48,88
!byte 128,168,208,248,32,72,112,152,192,232,16,56,96,136,176,216
!byte 0,40,80,120,160,200,0,40,80,120,160,200,240,24,64,104
!byte 144,184,224,8,48,88,128,168,208,248,32,72,112,152,192,232
!byte 16,56,96,136,176,216,0,40,80,120,160,200,240,24,64,104
!byte 144,184,224,8,48,88,128,168,208,248,32,72,112,152,192,232
!byte 16,56,96,136,176,216,0,40,80,120,160,200,240,24,64,104
!byte 144,184,224,8,48,88,128,168,208,248,32,72,112,152,192,232
bitmap_hi:
!byte 64,64,64,64,64,64,64,65,65,65,65,65,65,66,66,66
!byte 66,66,66,66,67,67,67,67,67,67,68,68,68,68,68,68
!byte 69,69,69,69,69,69,69,70,70,70,70,70,70,71,71,71
!byte 71,71,71,71,72,72,72,72,72,72,73,73,73,73,73,73
!byte 74,74,74,74,74,74,74,75,75,75,75,75,75,76,76,76
!byte 76,76,76,76,77,77,77,77,77,77,78,78,78,78,78,78
!byte 79,79,79,79,79,79,80,80,80,80,80,80,80,81,81,81
!byte 81,81,81,82,82,82,82,82,82,82,83,83,83,83,83,83
!byte 84,84,84,84,84,84,85,85,85,85,85,85,85,86,86,86
!byte 86,86,86,87,87,87,87,87,87,87,88,88,88,88,88,88
!byte 89,89,89,89,89,89,90,90,90,90,90,90,90,91,91,91
!byte 91,91,91,92,92,92,92,92,92,92,93,93,93,93,93,93
display_list:
!byte 112,112,112,79,0,64,79,40,64,79,80,64,79,120,64,79
!byte 160,64,79,200,64,79,240,64,79,24,65,79,64,65,79,104
!byte 65,79,144,65,79,184,65,79,224,65,79,8,66,79,48,66
!byte 79,88,66,79,128,66,79,168,66,79,208,66,79,248,66,79
!byte 32,67,79,72,67,79,112,67,79,152,67,79,192,67,79,232
!byte 67,79,16,68,79,56,68,79,96,68,79,136,68,79,176,68
!byte 79,216,68,79,0,69,79,40,69,79,80,69,79,120,69,79
!byte 160,69,79,200,69,79,240,69,79,24,70,79,64,70,79,104
!byte 70,79,144,70,79,184,70,79,224,70,79,8,71,79,48,71
!byte 79,88,71,79,128,71,79,168,71,79,208,71,79,248,71,79
!byte 32,72,79,72,72,79,112,72,79,152,72,79,192,72,79,232
!byte 72,79,16,73,79,56,73,79,96,73,79,136,73,79,176,73
!byte 79,216,73,79,0,74,79,40,74,79,80,74,79,120,74,79
!byte 160,74,79,200,74,79,240,74,79,24,75,79,64,75,79,104
!byte 75,79,144,75,79,184,75,79,224,75,79,8,76,79,48,76
!byte 79,88,76,79,128,76,79,168,76,79,208,76,79,248,76,79
!byte 32,77,79,72,77,79,112,77,79,152,77,79,192,77,79,232
!byte 77,79,16,78,79,56,78,79,96,78,79,136,78,79,176,78
!byte 79,216,78,79,0,79,79,40,79,79,80,79,79,120,79,79
!byte 160,79,79,200,79,79,0,80,79,40,80,79,80,80,79,120
!byte 80,79,160,80,79,200,80,79,240,80,79,24,81,79,64,81
!byte 79,104,81,79,144,81,79,184,81,79,224,81,79,8,82,79
!byte 48,82,79,88,82,79,128,82,79,168,82,79,208,82,79,248
!byte 82,79,32,83,79,72,83,79,112,83,79,152,83,79,192,83
!byte 79,232,83,79,16,84,79,56,84,79,96,84,79,136,84,79
!byte 176,84,79,216,84,79,0,85,79,40,85,79,80,85,79,120
!byte 85,79,160,85,79,200,85,79,240,85,79,24,86,79,64,86
!byte 79,104,86,79,144,86,79,184,86,79,224,86,79,8,87,79
!byte 48,87,79,88,87,79,128,87,79,168,87,79,208,87,79,248
!byte 87,79,32,88,79,72,88,79,112,88,79,152,88,79,192,88
!byte 79,232,88,79,16,89,79,56,89,79,96,89,79,136,89,79
!byte 176,89,79,216,89,79,0,90,79,40,90,79,80,90,79,120
!byte 90,79,160,90,79,200,90,79,240,90,79,24,91,79,64,91
!byte 79,104,91,79,144,91,79,184,91,79,224,91,79,8,92,79
!byte 48,92,79,88,92,79,128,92,79,168,92,79,208,92,79,248
!byte 92,79,32,93,79,72,93,79,112,93,79,152,93,79,192,93
!byte 79,232,93,65,0,48,0,0,0,0,0,0,0,0,0,0
!byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
!byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
!byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
!byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
!byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
!byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
!byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
!byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
!byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
!byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
!byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
!fill $fffa-*,0
!word start,start,start
