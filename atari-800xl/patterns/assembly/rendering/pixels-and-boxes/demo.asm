; SPDX-License-Identifier: MIT
; Original reset diagnostic; no manufacturer firmware or OS integration.
*=$e000
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
    sta $d01b
    sta $d01a
    sta $d018
    lda #14
    sta $d017
    lda #0
    ldx #0
clear_16384:
    sta $4000,x
    inx
    bne clear_16384
    lda #0
    ldx #0
clear_16640:
    sta $4100,x
    inx
    bne clear_16640
    lda #0
    ldx #0
clear_16896:
    sta $4200,x
    inx
    bne clear_16896
    lda #0
    ldx #0
clear_17152:
    sta $4300,x
    inx
    bne clear_17152
    lda #0
    ldx #0
clear_17408:
    sta $4400,x
    inx
    bne clear_17408
    lda #0
    ldx #0
clear_17664:
    sta $4500,x
    inx
    bne clear_17664
    lda #0
    ldx #0
clear_17920:
    sta $4600,x
    inx
    bne clear_17920
    lda #0
    ldx #0
clear_18176:
    sta $4700,x
    inx
    bne clear_18176
    lda #0
    ldx #0
clear_18432:
    sta $4800,x
    inx
    bne clear_18432
    lda #0
    ldx #0
clear_18688:
    sta $4900,x
    inx
    bne clear_18688
    lda #0
    ldx #0
clear_18944:
    sta $4a00,x
    inx
    bne clear_18944
    lda #0
    ldx #0
clear_19200:
    sta $4b00,x
    inx
    bne clear_19200
    lda #0
    ldx #0
clear_19456:
    sta $4c00,x
    inx
    bne clear_19456
    lda #0
    ldx #0
clear_19712:
    sta $4d00,x
    inx
    bne clear_19712
    lda #0
    ldx #0
clear_19968:
    sta $4e00,x
    inx
    bne clear_19968
    lda #0
    ldx #0
clear_20224:
    sta $4f00,x
    inx
    bne clear_20224
    lda #0
    ldx #0
clear_20480:
    sta $5000,x
    inx
    bne clear_20480
    lda #0
    ldx #0
clear_20736:
    sta $5100,x
    inx
    bne clear_20736
    lda #0
    ldx #0
clear_20992:
    sta $5200,x
    inx
    bne clear_20992
    lda #0
    ldx #0
clear_21248:
    sta $5300,x
    inx
    bne clear_21248
    lda #0
    ldx #0
clear_21504:
    sta $5400,x
    inx
    bne clear_21504
    lda #0
    ldx #0
clear_21760:
    sta $5500,x
    inx
    bne clear_21760
    lda #0
    ldx #0
clear_22016:
    sta $5600,x
    inx
    bne clear_22016
    lda #0
    ldx #0
clear_22272:
    sta $5700,x
    inx
    bne clear_22272
    lda #0
    ldx #0
clear_22528:
    sta $5800,x
    inx
    bne clear_22528
    lda #0
    ldx #0
clear_22784:
    sta $5900,x
    inx
    bne clear_22784
    lda #0
    ldx #0
clear_23040:
    sta $5a00,x
    inx
    bne clear_23040
    lda #0
    ldx #0
clear_23296:
    sta $5b00,x
    inx
    bne clear_23296
    lda #0
    ldx #0
clear_23552:
    sta $5c00,x
    inx
    bne clear_23552
    lda #0
    ldx #0
clear_23808:
    sta $5d00,x
    inx
    bne clear_23808
    lda #0
    ldx #0
clear_24064:
    sta $5e00,x
    inx
    bne clear_24064
    lda #0
    ldx #0
clear_24320:
    sta $5f00,x
    inx
    bne clear_24320
    ldx #0
copy_dl_0:
    lda display_list+0,x
    sta $3000,x
    inx
    bne copy_dl_0
    ldx #0
copy_dl_1:
    lda display_list+256,x
    sta $3100,x
    inx
    bne copy_dl_1
    ldx #0
copy_dl_2:
    lda display_list+512,x
    sta $3200,x
    inx
    bne copy_dl_2
    lda #<12288
    sta $d402
    lda #>12288
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
