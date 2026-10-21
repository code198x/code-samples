; SPDX-License-Identifier: MIT
; Shrink an MSB-left 8x8 glyph into 1..8 by 1..8 ink bounds, zero-padded to 8x8.
; RZ = 32 RAM bytes; 6502 RP = separate two zero-page bytes.
; Source sampling: floor(destination*8/size), top-left convention. Snapshot permits overlap.
r_source equ RZ+0
r_dest equ RZ+2
r_width equ RZ+4
r_height equ RZ+5
r_status equ RZ+6
r_ptr equ RZ+8
r_x equ RZ+10
r_y equ RZ+11
r_sx equ RZ+12
r_sy equ RZ+13
r_xe equ RZ+14
r_ye equ RZ+15
r_bits equ RZ+16
r_mask equ RZ+17
r_cmp equ RZ+23
r_copy equ RZ+24
resize_cmp equ RZ+23
glyph_resize
    lda #$00
    sta r_status
    lda #$01
    sta resize_cmp
    lda r_width
    cmpa resize_cmp
    lblo resize_done
resize_branch_1
    lda #$08
    sta resize_cmp
    lda r_width
    cmpa resize_cmp
    lblo resize_branch_2
    lbne resize_done
resize_branch_2
    lda #$01
    sta resize_cmp
    lda r_height
    cmpa resize_cmp
    lblo resize_done
resize_branch_3
    lda #$08
    sta resize_cmp
    lda r_height
    cmpa resize_cmp
    lblo resize_branch_4
    lbne resize_done
resize_branch_4
    lda #$ff
    sta resize_cmp
    lda r_source
    cmpa resize_cmp
    lblo resize_branch_5
    lbne resize_done
    lda #$f8
    sta resize_cmp
    lda r_source+1
    cmpa resize_cmp
    lblo resize_branch_5
    lbne resize_done
resize_branch_5
    lda #$ff
    sta resize_cmp
    lda r_dest
    cmpa resize_cmp
    lblo resize_branch_6
    lbne resize_done
    lda #$f8
    sta resize_cmp
    lda r_dest+1
    cmpa resize_cmp
    lblo resize_branch_6
    lbne resize_done
resize_branch_6
    lda #$00
    sta r_x
    ldd r_source
    std r_ptr
resize_snapshot
    ldx r_ptr
    lda ,x
    ldx #r_copy
    ldb r_x
    sta b,x
    ldd r_ptr
    addd #$0001
    std r_ptr
    lda r_x
    adda #$01
    sta r_x
    lda #$08
    sta resize_cmp
    lda r_x
    cmpa resize_cmp
    lblo resize_snapshot
resize_branch_7
    lda #$00
    sta r_x
    ldd r_dest
    std r_ptr
resize_clear
    lda #$00
    ldx r_ptr
    sta ,x
    ldd r_ptr
    addd #$0001
    std r_ptr
    lda r_x
    adda #$01
    sta r_x
    lda #$08
    sta resize_cmp
    lda r_x
    cmpa resize_cmp
    lblo resize_clear
resize_branch_8
    lda #$00
    sta r_y
    lda #$00
    sta r_sy
    lda #$00
    sta r_ye
resize_row
    ldx #r_copy
    ldb r_sy
    lda b,x
    sta r_bits
    lda #$00
    sta r_x
    lda #$00
    sta r_sx
    lda #$00
    sta r_xe
resize_pixel
    ldx #resize_masks
    ldb r_sx
    lda b,x
    anda r_bits
    lbeq resize_next
    ldx #resize_masks
    ldb r_x
    lda b,x
    sta r_mask
    ldd #$0000
    std r_ptr
    lda r_y
    sta r_ptr+1
    ldd r_ptr
    addd r_dest
    std r_ptr
    ldx r_ptr
    lda ,x
    ora r_mask
    ldx r_ptr
    sta ,x
resize_next
; BEGIN SAMPLING FIX: accumulate eight source steps per destination width.
    lda r_xe
    adda #$08
    sta r_xe
resize_x_sample
    lda r_width
    sta resize_cmp
    lda r_xe
    cmpa resize_cmp
    lblo resize_x_ready
resize_branch_9
    lda r_xe
    suba r_width
    sta r_xe
    lda r_sx
    adda #$01
    sta r_sx
    jmp resize_x_sample
resize_x_ready
; END SAMPLING FIX
    lda r_x
    adda #$01
    sta r_x
    lda r_width
    sta resize_cmp
    lda r_x
    cmpa resize_cmp
    lblo resize_pixel
resize_branch_10
    lda r_ye
    adda #$08
    sta r_ye
resize_y_sample
    lda r_height
    sta resize_cmp
    lda r_ye
    cmpa resize_cmp
    lblo resize_y_ready
resize_branch_11
    lda r_ye
    suba r_height
    sta r_ye
    lda r_sy
    adda #$01
    sta r_sy
    jmp resize_y_sample
resize_y_ready
    lda r_y
    adda #$01
    sta r_y
    lda r_height
    sta resize_cmp
    lda r_y
    cmpa resize_cmp
    lblo resize_row
resize_branch_12
    lda #$01
    sta r_status
resize_done
    rts
resize_masks
    fcb 128,64,32,16,8,4,2,1
glyph_resize_end
