 org $8000
NR equ 896
RESULT equ 768
MAP equ 1264
MAP_W equ 12
MAP_H equ 8
TILE_COUNT equ 4
CELL_BYTES equ 1
SCREEN_COLS equ 32
SCREEN_ROWS equ 24
X_STEP equ 1
start
    orcc #$50
    lds #$7f00
    ; Configure PIA1 B direction before its output data register.
    clr $ff23
    lda #$ff
    sta $ff22
    lda #4
    sta $ff23
    lda #$f0
    sta $ff22
    ; SAM V=110 for RG6; base $0600 = 3 * 512.
    sta $ffc0
    sta $ffc3
    sta $ffc5
    sta $ffc7
    sta $ffc9
    sta $ffca
    sta $ffcc
    sta $ffce
    sta $ffd0
    sta $ffd2
    ldx #$0600
clear_bitmap
    clr ,x+
    cmpx #$1e00
    bne clear_bitmap
    ldx #initial_map
    ldy #MAP
    ldb #96
copy_map
    lda ,x+
    sta ,y+
    decb
    bne copy_map
    lda #$a5
    sta MAP+96
    ldx #$05f0
clear_guard
    sta ,x+
    cmpx #$0600
    bne clear_guard
case_0
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
case_1
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
case_2
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
case_3
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
case_4
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
case_5
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
case_6
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
case_7
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
case_8
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
case_9
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
case_10
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
case_11
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
case_12
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
case_13
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
case_14
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
case_15
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
case_16
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
case_17
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
diagnostic_done
    lda #239
    sta RESULT
finished
    bra finished
 include "../../../../../cross-platform/patterns/rendering/bitmap-regions/6809.inc"
initial_map
    fcb 0,1,2,3,0,1,2,3,0,1,2,3,2,3,0,1,2,3,0,1,2,3,0,1,0,1,2,3,0,1,2,3,0,1,2,3,2,3,0,1,2,3,0,1,2,3,0,1,0,1,2,3,0,1,2,3,0,1,2,3,2,3,0,1,2,3,0,1,2,3,0,1,0,1,2,3,0,1,2,3,0,1,2,3,2,3,0,1,2,3,0,1,2,3,0,1
TILES
    fcb 0,0,0,0,0,0,0,0
    fcb 170,85,170,85,170,85,170,85
    fcb 255,129,129,129,129,129,129,255
    fcb 129,66,36,24,24,36,66,129
bitmap_lo
    fcb 0,32,64,96,128,160,192,224,0,32,64,96,128,160,192,224
    fcb 0,32,64,96,128,160,192,224,0,32,64,96,128,160,192,224
    fcb 0,32,64,96,128,160,192,224,0,32,64,96,128,160,192,224
    fcb 0,32,64,96,128,160,192,224,0,32,64,96,128,160,192,224
    fcb 0,32,64,96,128,160,192,224,0,32,64,96,128,160,192,224
    fcb 0,32,64,96,128,160,192,224,0,32,64,96,128,160,192,224
    fcb 0,32,64,96,128,160,192,224,0,32,64,96,128,160,192,224
    fcb 0,32,64,96,128,160,192,224,0,32,64,96,128,160,192,224
    fcb 0,32,64,96,128,160,192,224,0,32,64,96,128,160,192,224
    fcb 0,32,64,96,128,160,192,224,0,32,64,96,128,160,192,224
    fcb 0,32,64,96,128,160,192,224,0,32,64,96,128,160,192,224
    fcb 0,32,64,96,128,160,192,224,0,32,64,96,128,160,192,224
bitmap_hi
    fcb 6,6,6,6,6,6,6,6,7,7,7,7,7,7,7,7
    fcb 8,8,8,8,8,8,8,8,9,9,9,9,9,9,9,9
    fcb 10,10,10,10,10,10,10,10,11,11,11,11,11,11,11,11
    fcb 12,12,12,12,12,12,12,12,13,13,13,13,13,13,13,13
    fcb 14,14,14,14,14,14,14,14,15,15,15,15,15,15,15,15
    fcb 16,16,16,16,16,16,16,16,17,17,17,17,17,17,17,17
    fcb 18,18,18,18,18,18,18,18,19,19,19,19,19,19,19,19
    fcb 20,20,20,20,20,20,20,20,21,21,21,21,21,21,21,21
    fcb 22,22,22,22,22,22,22,22,23,23,23,23,23,23,23,23
    fcb 24,24,24,24,24,24,24,24,25,25,25,25,25,25,25,25
    fcb 26,26,26,26,26,26,26,26,27,27,27,27,27,27,27,27
    fcb 28,28,28,28,28,28,28,28,29,29,29,29,29,29,29,29
; build.py installs reset/interrupt vectors at the end of the 16 KB ROM.
