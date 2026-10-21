; SPDX-License-Identifier: MIT
; Transform one MSB-left 8x8 glyph. F = 32 caller-owned RAM bytes.
; 6502 additionally needs GP = two zero-page bytes, disjoint from F and data.
; Flags 0..3 clockwise quarter-turns, bit 2 horizontal reflection AFTER rotation.
; Snapshot input before any output; overlapping source/destination is supported.
f_source = F+0
f_dest = F+2
f_flags = F+4
f_status = F+5
f_ptr = F+6
f_x = F+8
f_y = F+9
f_dx = F+10
f_dy = F+11
f_bits = F+12
f_mask = F+13
f_turns = F+14
f_i = F+15
f_copy = F+16
f_tmp = F+24
f_cmp = F+31
glyph_cmp = F+31
glyph_transform:
    lda #$00
    sta f_status
    lda #$07
    sta glyph_cmp
    lda f_flags
    cmp glyph_cmp
    bcs glyph_branch_2
    jmp glyph_branch_1
glyph_branch_2:
    beq glyph_branch_3
    jmp glyph_done
glyph_branch_3:
glyph_branch_1:
    lda #$ff
    sta glyph_cmp
    lda f_source+1
    cmp glyph_cmp
    bcs glyph_branch_5
    jmp glyph_branch_4
glyph_branch_5:
    beq glyph_branch_6
    jmp glyph_done
glyph_branch_6:
    lda #$f8
    sta glyph_cmp
    lda f_source
    cmp glyph_cmp
    bcs glyph_branch_7
    jmp glyph_branch_4
glyph_branch_7:
    beq glyph_branch_8
    jmp glyph_done
glyph_branch_8:
glyph_branch_4:
    lda #$ff
    sta glyph_cmp
    lda f_dest+1
    cmp glyph_cmp
    bcs glyph_branch_10
    jmp glyph_branch_9
glyph_branch_10:
    beq glyph_branch_11
    jmp glyph_done
glyph_branch_11:
    lda #$f8
    sta glyph_cmp
    lda f_dest
    cmp glyph_cmp
    bcs glyph_branch_12
    jmp glyph_branch_9
glyph_branch_12:
    beq glyph_branch_13
    jmp glyph_done
glyph_branch_13:
glyph_branch_9:
; Copy all eight source rows before clearing the destination.
    lda #$00
    sta f_i
    lda f_source
    sta f_ptr
    lda f_source+1
    sta f_ptr+1
glyph_snapshot:
    lda f_ptr
    sta GP
    lda f_ptr+1
    sta GP+1
    ldy #0
    lda (GP),y
    ldx f_i
    sta f_copy,x
    clc
    lda f_ptr
    adc #$01
    sta f_ptr
    lda f_ptr+1
    adc #$00
    sta f_ptr+1
    clc
    lda f_i
    adc #$01
    sta f_i
    lda #$08
    sta glyph_cmp
    lda f_i
    cmp glyph_cmp
    bcs glyph_branch_15
    jmp glyph_snapshot
glyph_branch_15:
glyph_branch_14:
    lda #$00
    sta f_i
    lda f_dest
    sta f_ptr
    lda f_dest+1
    sta f_ptr+1
glyph_clear:
    lda #$00
    pha
    lda f_ptr
    sta GP
    lda f_ptr+1
    sta GP+1
    ldy #0
    pla
    sta (GP),y
    clc
    lda f_ptr
    adc #$01
    sta f_ptr
    lda f_ptr+1
    adc #$00
    sta f_ptr+1
    clc
    lda f_i
    adc #$01
    sta f_i
    lda #$08
    sta glyph_cmp
    lda f_i
    cmp glyph_cmp
    bcs glyph_branch_17
    jmp glyph_clear
glyph_branch_17:
glyph_branch_16:
    lda #$00
    sta f_y
glyph_row:
    ldx f_y
    lda f_copy,x
    sta f_bits
    lda #$00
    sta f_x
glyph_pixel:
    lda f_bits
    and #$80
    bne glyph_branch_18
    jmp glyph_next
glyph_branch_18:
    lda f_x
    sta f_dx
    lda f_y
    sta f_dy
    lda f_flags
    and #3
    sta f_turns
glyph_turn:
    lda #$00
    sta glyph_cmp
    lda f_turns
    cmp glyph_cmp
    beq glyph_branch_20
    jmp glyph_branch_19
glyph_branch_20:
    jmp glyph_reflect
glyph_branch_19:
    lda f_dx
    sta f_tmp
; BEGIN ROTATION FIX: (x,y) becomes (7-y,x), not (y,x).
    lda #$07
    sta f_dx
    sec
    lda f_dx
    sbc f_dy
    sta f_dx
; END ROTATION FIX
    lda f_tmp
    sta f_dy
    clc
    lda f_turns
    adc #$ff
    sta f_turns
    jmp glyph_turn
glyph_reflect:
    lda f_flags
    and #4
    bne glyph_branch_21
    jmp glyph_store
glyph_branch_21:
    lda #$07
    sta f_tmp
    sec
    lda f_tmp
    sbc f_dx
    sta f_tmp
    lda f_tmp
    sta f_dx
glyph_store:
    ldx f_dx
    lda glyph_masks,x
    sta f_mask
    lda #$00
    sta f_ptr
    lda #$00
    sta f_ptr+1
    lda f_dy
    sta f_ptr
    clc
    lda f_ptr
    adc f_dest
    sta f_ptr
    lda f_ptr+1
    adc f_dest+1
    sta f_ptr+1
    lda f_ptr
    sta GP
    lda f_ptr+1
    sta GP+1
    ldy #0
    lda (GP),y
    ora f_mask
    pha
    lda f_ptr
    sta GP
    lda f_ptr+1
    sta GP+1
    ldy #0
    pla
    sta (GP),y
glyph_next:
    asl f_bits
    clc
    lda f_x
    adc #$01
    sta f_x
    lda #$08
    sta glyph_cmp
    lda f_x
    cmp glyph_cmp
    bcs glyph_branch_23
    jmp glyph_pixel
glyph_branch_23:
glyph_branch_22:
    clc
    lda f_y
    adc #$01
    sta f_y
    lda #$08
    sta glyph_cmp
    lda f_y
    cmp glyph_cmp
    bcs glyph_branch_25
    jmp glyph_row
glyph_branch_25:
glyph_branch_24:
    lda #$01
    sta f_status
glyph_done:
    rts
glyph_masks:
    !byte 128,64,32,16,8,4,2,1
glyph_transform_end:
