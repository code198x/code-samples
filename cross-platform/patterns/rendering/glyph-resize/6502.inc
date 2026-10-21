; SPDX-License-Identifier: MIT
; Shrink an MSB-left 8x8 glyph into 1..8 by 1..8 ink bounds, zero-padded to 8x8.
; RZ = 32 RAM bytes; 6502 RP = separate two zero-page bytes.
; Source sampling: floor(destination*8/size), top-left convention. Snapshot permits overlap.
r_source = RZ+0
r_dest = RZ+2
r_width = RZ+4
r_height = RZ+5
r_status = RZ+6
r_ptr = RZ+8
r_x = RZ+10
r_y = RZ+11
r_sx = RZ+12
r_sy = RZ+13
r_xe = RZ+14
r_ye = RZ+15
r_bits = RZ+16
r_mask = RZ+17
r_cmp = RZ+23
r_copy = RZ+24
resize_cmp = RZ+23
glyph_resize:
    lda #$00
    sta r_status
    lda #$01
    sta resize_cmp
    lda r_width
    cmp resize_cmp
    bcs resize_branch_2
    jmp resize_done
resize_branch_2:
resize_branch_1:
    lda #$08
    sta resize_cmp
    lda r_width
    cmp resize_cmp
    bcs resize_branch_4
    jmp resize_branch_3
resize_branch_4:
    beq resize_branch_5
    jmp resize_done
resize_branch_5:
resize_branch_3:
    lda #$01
    sta resize_cmp
    lda r_height
    cmp resize_cmp
    bcs resize_branch_7
    jmp resize_done
resize_branch_7:
resize_branch_6:
    lda #$08
    sta resize_cmp
    lda r_height
    cmp resize_cmp
    bcs resize_branch_9
    jmp resize_branch_8
resize_branch_9:
    beq resize_branch_10
    jmp resize_done
resize_branch_10:
resize_branch_8:
    lda #$ff
    sta resize_cmp
    lda r_source+1
    cmp resize_cmp
    bcs resize_branch_12
    jmp resize_branch_11
resize_branch_12:
    beq resize_branch_13
    jmp resize_done
resize_branch_13:
    lda #$f8
    sta resize_cmp
    lda r_source
    cmp resize_cmp
    bcs resize_branch_14
    jmp resize_branch_11
resize_branch_14:
    beq resize_branch_15
    jmp resize_done
resize_branch_15:
resize_branch_11:
    lda #$ff
    sta resize_cmp
    lda r_dest+1
    cmp resize_cmp
    bcs resize_branch_17
    jmp resize_branch_16
resize_branch_17:
    beq resize_branch_18
    jmp resize_done
resize_branch_18:
    lda #$f8
    sta resize_cmp
    lda r_dest
    cmp resize_cmp
    bcs resize_branch_19
    jmp resize_branch_16
resize_branch_19:
    beq resize_branch_20
    jmp resize_done
resize_branch_20:
resize_branch_16:
    lda #$00
    sta r_x
    lda r_source
    sta r_ptr
    lda r_source+1
    sta r_ptr+1
resize_snapshot:
    lda r_ptr
    sta RP
    lda r_ptr+1
    sta RP+1
    ldy #0
    lda (RP),y
    ldx r_x
    sta r_copy,x
    clc
    lda r_ptr
    adc #$01
    sta r_ptr
    lda r_ptr+1
    adc #$00
    sta r_ptr+1
    clc
    lda r_x
    adc #$01
    sta r_x
    lda #$08
    sta resize_cmp
    lda r_x
    cmp resize_cmp
    bcs resize_branch_22
    jmp resize_snapshot
resize_branch_22:
resize_branch_21:
    lda #$00
    sta r_x
    lda r_dest
    sta r_ptr
    lda r_dest+1
    sta r_ptr+1
resize_clear:
    lda #$00
    pha
    lda r_ptr
    sta RP
    lda r_ptr+1
    sta RP+1
    ldy #0
    pla
    sta (RP),y
    clc
    lda r_ptr
    adc #$01
    sta r_ptr
    lda r_ptr+1
    adc #$00
    sta r_ptr+1
    clc
    lda r_x
    adc #$01
    sta r_x
    lda #$08
    sta resize_cmp
    lda r_x
    cmp resize_cmp
    bcs resize_branch_24
    jmp resize_clear
resize_branch_24:
resize_branch_23:
    lda #$00
    sta r_y
    lda #$00
    sta r_sy
    lda #$00
    sta r_ye
resize_row:
    ldx r_sy
    lda r_copy,x
    sta r_bits
    lda #$00
    sta r_x
    lda #$00
    sta r_sx
    lda #$00
    sta r_xe
resize_pixel:
    ldx r_sx
    lda resize_masks,x
    and r_bits
    bne resize_branch_25
    jmp resize_next
resize_branch_25:
    ldx r_x
    lda resize_masks,x
    sta r_mask
    lda #$00
    sta r_ptr
    lda #$00
    sta r_ptr+1
    lda r_y
    sta r_ptr
    clc
    lda r_ptr
    adc r_dest
    sta r_ptr
    lda r_ptr+1
    adc r_dest+1
    sta r_ptr+1
    lda r_ptr
    sta RP
    lda r_ptr+1
    sta RP+1
    ldy #0
    lda (RP),y
    ora r_mask
    pha
    lda r_ptr
    sta RP
    lda r_ptr+1
    sta RP+1
    ldy #0
    pla
    sta (RP),y
resize_next:
; BEGIN SAMPLING FIX: accumulate eight source steps per destination width.
    clc
    lda r_xe
    adc #$08
    sta r_xe
resize_x_sample:
    lda r_width
    sta resize_cmp
    lda r_xe
    cmp resize_cmp
    bcs resize_branch_27
    jmp resize_x_ready
resize_branch_27:
resize_branch_26:
    sec
    lda r_xe
    sbc r_width
    sta r_xe
    clc
    lda r_sx
    adc #$01
    sta r_sx
    jmp resize_x_sample
resize_x_ready:
; END SAMPLING FIX
    clc
    lda r_x
    adc #$01
    sta r_x
    lda r_width
    sta resize_cmp
    lda r_x
    cmp resize_cmp
    bcs resize_branch_29
    jmp resize_pixel
resize_branch_29:
resize_branch_28:
    clc
    lda r_ye
    adc #$08
    sta r_ye
resize_y_sample:
    lda r_height
    sta resize_cmp
    lda r_ye
    cmp resize_cmp
    bcs resize_branch_31
    jmp resize_y_ready
resize_branch_31:
resize_branch_30:
    sec
    lda r_ye
    sbc r_height
    sta r_ye
    clc
    lda r_sy
    adc #$01
    sta r_sy
    jmp resize_y_sample
resize_y_ready:
    clc
    lda r_y
    adc #$01
    sta r_y
    lda r_height
    sta resize_cmp
    lda r_y
    cmp resize_cmp
    bcs resize_branch_33
    jmp resize_row
resize_branch_33:
resize_branch_32:
    lda #$01
    sta r_status
resize_done:
    rts
resize_masks:
    !byte 128,64,32,16,8,4,2,1
glyph_resize_end:
