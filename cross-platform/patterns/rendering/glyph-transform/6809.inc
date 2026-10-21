; SPDX-License-Identifier: MIT
; Transform one MSB-left 8x8 glyph. F = 32 caller-owned RAM bytes.
; 6502 additionally needs GP = two zero-page bytes, disjoint from F and data.
; Flags 0..3 clockwise quarter-turns, bit 2 horizontal reflection AFTER rotation.
; Snapshot input before any output; overlapping source/destination is supported.
f_source equ F+0
f_dest equ F+2
f_flags equ F+4
f_status equ F+5
f_ptr equ F+6
f_x equ F+8
f_y equ F+9
f_dx equ F+10
f_dy equ F+11
f_bits equ F+12
f_mask equ F+13
f_turns equ F+14
f_i equ F+15
f_copy equ F+16
f_tmp equ F+24
f_cmp equ F+31
glyph_cmp equ F+31
glyph_transform
    lda #$00
    sta f_status
    lda #$07
    sta glyph_cmp
    lda f_flags
    cmpa glyph_cmp
    lblo glyph_branch_1
    lbne glyph_done
glyph_branch_1
    lda #$ff
    sta glyph_cmp
    lda f_source
    cmpa glyph_cmp
    lblo glyph_branch_2
    lbne glyph_done
    lda #$f8
    sta glyph_cmp
    lda f_source+1
    cmpa glyph_cmp
    lblo glyph_branch_2
    lbne glyph_done
glyph_branch_2
    lda #$ff
    sta glyph_cmp
    lda f_dest
    cmpa glyph_cmp
    lblo glyph_branch_3
    lbne glyph_done
    lda #$f8
    sta glyph_cmp
    lda f_dest+1
    cmpa glyph_cmp
    lblo glyph_branch_3
    lbne glyph_done
glyph_branch_3
; Copy all eight source rows before clearing the destination.
    lda #$00
    sta f_i
    ldd f_source
    std f_ptr
glyph_snapshot
    ldx f_ptr
    lda ,x
    ldx #f_copy
    ldb f_i
    sta b,x
    ldd f_ptr
    addd #$0001
    std f_ptr
    lda f_i
    adda #$01
    sta f_i
    lda #$08
    sta glyph_cmp
    lda f_i
    cmpa glyph_cmp
    lblo glyph_snapshot
glyph_branch_4
    lda #$00
    sta f_i
    ldd f_dest
    std f_ptr
glyph_clear
    lda #$00
    ldx f_ptr
    sta ,x
    ldd f_ptr
    addd #$0001
    std f_ptr
    lda f_i
    adda #$01
    sta f_i
    lda #$08
    sta glyph_cmp
    lda f_i
    cmpa glyph_cmp
    lblo glyph_clear
glyph_branch_5
    lda #$00
    sta f_y
glyph_row
    ldx #f_copy
    ldb f_y
    lda b,x
    sta f_bits
    lda #$00
    sta f_x
glyph_pixel
    lda f_bits
    anda #$80
    lbeq glyph_next
    lda f_x
    sta f_dx
    lda f_y
    sta f_dy
    lda f_flags
    anda #3
    sta f_turns
glyph_turn
    lda #$00
    sta glyph_cmp
    lda f_turns
    cmpa glyph_cmp
    lbne glyph_branch_6
    jmp glyph_reflect
glyph_branch_6
    lda f_dx
    sta f_tmp
; BEGIN ROTATION FIX: (x,y) becomes (7-y,x), not (y,x).
    lda #$07
    sta f_dx
    lda f_dx
    suba f_dy
    sta f_dx
; END ROTATION FIX
    lda f_tmp
    sta f_dy
    lda f_turns
    adda #$ff
    sta f_turns
    jmp glyph_turn
glyph_reflect
    lda f_flags
    anda #4
    lbeq glyph_store
    lda #$07
    sta f_tmp
    lda f_tmp
    suba f_dx
    sta f_tmp
    lda f_tmp
    sta f_dx
glyph_store
    ldx #glyph_masks
    ldb f_dx
    lda b,x
    sta f_mask
    ldd #$0000
    std f_ptr
    lda f_dy
    sta f_ptr+1
    ldd f_ptr
    addd f_dest
    std f_ptr
    ldx f_ptr
    lda ,x
    ora f_mask
    ldx f_ptr
    sta ,x
glyph_next
    lsl f_bits
    lda f_x
    adda #$01
    sta f_x
    lda #$08
    sta glyph_cmp
    lda f_x
    cmpa glyph_cmp
    lblo glyph_pixel
glyph_branch_7
    lda f_y
    adda #$01
    sta f_y
    lda #$08
    sta glyph_cmp
    lda f_y
    cmpa glyph_cmp
    lblo glyph_row
glyph_branch_8
    lda #$01
    sta f_status
glyph_done
    rts
glyph_masks
    fcb 128,64,32,16,8,4,2,1
glyph_transform_end
