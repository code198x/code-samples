; SPDX-License-Identifier: MIT
; Original reset diagnostic; no manufacturer firmware or OS integration.
*=$4000
BP=$70
COMMAND=$600
PIXEL_WIDTH=320
PIXEL_HEIGHT=192
start:
    sei
    cld
    ldx #$ff
    txs
    lda #0
    sta $d400
    sta $d40e
    sta $c01b
    sta $c01a
    sta $c018
    lda #14
    sta $c017
    lda #0
    ldx #0
clear_8192:
    sta $2000,x
    inx
    bne clear_8192
    lda #0
    ldx #0
clear_8448:
    sta $2100,x
    inx
    bne clear_8448
    lda #0
    ldx #0
clear_8704:
    sta $2200,x
    inx
    bne clear_8704
    lda #0
    ldx #0
clear_8960:
    sta $2300,x
    inx
    bne clear_8960
    lda #0
    ldx #0
clear_9216:
    sta $2400,x
    inx
    bne clear_9216
    lda #0
    ldx #0
clear_9472:
    sta $2500,x
    inx
    bne clear_9472
    lda #0
    ldx #0
clear_9728:
    sta $2600,x
    inx
    bne clear_9728
    lda #0
    ldx #0
clear_9984:
    sta $2700,x
    inx
    bne clear_9984
    lda #0
    ldx #0
clear_10240:
    sta $2800,x
    inx
    bne clear_10240
    lda #0
    ldx #0
clear_10496:
    sta $2900,x
    inx
    bne clear_10496
    lda #0
    ldx #0
clear_10752:
    sta $2a00,x
    inx
    bne clear_10752
    lda #0
    ldx #0
clear_11008:
    sta $2b00,x
    inx
    bne clear_11008
    lda #0
    ldx #0
clear_11264:
    sta $2c00,x
    inx
    bne clear_11264
    lda #0
    ldx #0
clear_11520:
    sta $2d00,x
    inx
    bne clear_11520
    lda #0
    ldx #0
clear_11776:
    sta $2e00,x
    inx
    bne clear_11776
    lda #0
    ldx #0
clear_12032:
    sta $2f00,x
    inx
    bne clear_12032
    lda #0
    ldx #0
clear_12288:
    sta $3000,x
    inx
    bne clear_12288
    lda #0
    ldx #0
clear_12544:
    sta $3100,x
    inx
    bne clear_12544
    lda #0
    ldx #0
clear_12800:
    sta $3200,x
    inx
    bne clear_12800
    lda #0
    ldx #0
clear_13056:
    sta $3300,x
    inx
    bne clear_13056
    lda #0
    ldx #0
clear_13312:
    sta $3400,x
    inx
    bne clear_13312
    lda #0
    ldx #0
clear_13568:
    sta $3500,x
    inx
    bne clear_13568
    lda #0
    ldx #0
clear_13824:
    sta $3600,x
    inx
    bne clear_13824
    lda #0
    ldx #0
clear_14080:
    sta $3700,x
    inx
    bne clear_14080
    lda #0
    ldx #0
clear_14336:
    sta $3800,x
    inx
    bne clear_14336
    lda #0
    ldx #0
clear_14592:
    sta $3900,x
    inx
    bne clear_14592
    lda #0
    ldx #0
clear_14848:
    sta $3a00,x
    inx
    bne clear_14848
    lda #0
    ldx #0
clear_15104:
    sta $3b00,x
    inx
    bne clear_15104
    lda #0
    ldx #0
clear_15360:
    sta $3c00,x
    inx
    bne clear_15360
    lda #0
    ldx #0
clear_15616:
    sta $3d00,x
    inx
    bne clear_15616
    lda #0
    ldx #0
clear_15872:
    sta $3e00,x
    inx
    bne clear_15872
    lda #0
    ldx #0
clear_16128:
    sta $3f00,x
    inx
    bne clear_16128
    ldx #0
copy_dl_0:
    lda display_list+0,x
    sta $1000,x
    inx
    bne copy_dl_0
    ldx #0
copy_dl_1:
    lda display_list+256,x
    sta $1100,x
    inx
    bne copy_dl_1
    ldx #0
copy_dl_2:
    lda display_list+512,x
    sta $1200,x
    inx
    bne copy_dl_2
    lda #<4096
    sta $d402
    lda #>4096
    sta $d403
    lda #34
    sta $d400
; A normal game call: an outlined box using exclusive right/bottom ends.
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
    lda #0
    sta COMMAND
    lda #239
    sta COMMAND+1
mailbox:
    lda COMMAND
    beq mailbox
    cmp #1
    bne cmd_2
    jsr bp_pixel
    jmp complete
cmd_2:
    cmp #2
    bne cmd_3
    jsr bp_read
    jmp complete
cmd_3:
    cmp #3
    bne cmd_4
    jsr bp_hspan
    jmp complete
cmd_4:
    cmp #4
    bne cmd_5
    jsr bp_vspan
    jmp complete
cmd_5:
    cmp #5
    bne cmd_6
    jsr bp_fill
    jmp complete
cmd_6:
    cmp #6
    bne cmd_7
    jsr bp_box
    jmp complete
cmd_7:
complete:
    lda #0
    sta COMMAND
    jmp mailbox
backend_start:
    !source "../../../../../cross-platform/patterns/rendering/extended-primitives/antic.inc"
backend_end:
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
    !byte 32,32,32,32,32,32,32,33,33,33,33,33,33,34,34,34
    !byte 34,34,34,34,35,35,35,35,35,35,36,36,36,36,36,36
    !byte 37,37,37,37,37,37,37,38,38,38,38,38,38,39,39,39
    !byte 39,39,39,39,40,40,40,40,40,40,41,41,41,41,41,41
    !byte 42,42,42,42,42,42,42,43,43,43,43,43,43,44,44,44
    !byte 44,44,44,44,45,45,45,45,45,45,46,46,46,46,46,46
    !byte 47,47,47,47,47,47,48,48,48,48,48,48,48,49,49,49
    !byte 49,49,49,50,50,50,50,50,50,50,51,51,51,51,51,51
    !byte 52,52,52,52,52,52,53,53,53,53,53,53,53,54,54,54
    !byte 54,54,54,55,55,55,55,55,55,55,56,56,56,56,56,56
    !byte 57,57,57,57,57,57,58,58,58,58,58,58,58,59,59,59
    !byte 59,59,59,60,60,60,60,60,60,60,61,61,61,61,61,61
display_list:
    !byte 112,112,112,79,0,32,79,40,32,79,80,32,79,120,32,79
    !byte 160,32,79,200,32,79,240,32,79,24,33,79,64,33,79,104
    !byte 33,79,144,33,79,184,33,79,224,33,79,8,34,79,48,34
    !byte 79,88,34,79,128,34,79,168,34,79,208,34,79,248,34,79
    !byte 32,35,79,72,35,79,112,35,79,152,35,79,192,35,79,232
    !byte 35,79,16,36,79,56,36,79,96,36,79,136,36,79,176,36
    !byte 79,216,36,79,0,37,79,40,37,79,80,37,79,120,37,79
    !byte 160,37,79,200,37,79,240,37,79,24,38,79,64,38,79,104
    !byte 38,79,144,38,79,184,38,79,224,38,79,8,39,79,48,39
    !byte 79,88,39,79,128,39,79,168,39,79,208,39,79,248,39,79
    !byte 32,40,79,72,40,79,112,40,79,152,40,79,192,40,79,232
    !byte 40,79,16,41,79,56,41,79,96,41,79,136,41,79,176,41
    !byte 79,216,41,79,0,42,79,40,42,79,80,42,79,120,42,79
    !byte 160,42,79,200,42,79,240,42,79,24,43,79,64,43,79,104
    !byte 43,79,144,43,79,184,43,79,224,43,79,8,44,79,48,44
    !byte 79,88,44,79,128,44,79,168,44,79,208,44,79,248,44,79
    !byte 32,45,79,72,45,79,112,45,79,152,45,79,192,45,79,232
    !byte 45,79,16,46,79,56,46,79,96,46,79,136,46,79,176,46
    !byte 79,216,46,79,0,47,79,40,47,79,80,47,79,120,47,79
    !byte 160,47,79,200,47,79,0,48,79,40,48,79,80,48,79,120
    !byte 48,79,160,48,79,200,48,79,240,48,79,24,49,79,64,49
    !byte 79,104,49,79,144,49,79,184,49,79,224,49,79,8,50,79
    !byte 48,50,79,88,50,79,128,50,79,168,50,79,208,50,79,248
    !byte 50,79,32,51,79,72,51,79,112,51,79,152,51,79,192,51
    !byte 79,232,51,79,16,52,79,56,52,79,96,52,79,136,52,79
    !byte 176,52,79,216,52,79,0,53,79,40,53,79,80,53,79,120
    !byte 53,79,160,53,79,200,53,79,240,53,79,24,54,79,64,54
    !byte 79,104,54,79,144,54,79,184,54,79,224,54,79,8,55,79
    !byte 48,55,79,88,55,79,128,55,79,168,55,79,208,55,79,248
    !byte 55,79,32,56,79,72,56,79,112,56,79,152,56,79,192,56
    !byte 79,232,56,79,16,57,79,56,57,79,96,57,79,136,57,79
    !byte 176,57,79,216,57,79,0,58,79,40,58,79,80,58,79,120
    !byte 58,79,160,58,79,200,58,79,240,58,79,24,59,79,64,59
    !byte 79,104,59,79,144,59,79,184,59,79,224,59,79,8,60,79
    !byte 48,60,79,88,60,79,128,60,79,168,60,79,208,60,79,248
    !byte 60,79,32,61,79,72,61,79,112,61,79,152,61,79,192,61
    !byte 79,232,61,65,0,16,0,0,0,0,0,0,0,0,0,0
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
!fill $bffe-*,0
!word start
