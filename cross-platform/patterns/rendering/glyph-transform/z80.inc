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
glyph_transform:
    ld a,$00
    ld (f_status),a
    ld a,$07
    ld (glyph_cmp),a
    ld a,(f_flags)
    ld b,a
    ld a,(glyph_cmp)
    ld c,a
    ld a,b
    cp c
    jp c,glyph_branch_1
    jp nz,glyph_done
glyph_branch_1:
    ld a,$ff
    ld (glyph_cmp),a
    ld a,(f_source+1)
    ld b,a
    ld a,(glyph_cmp)
    ld c,a
    ld a,b
    cp c
    jp c,glyph_branch_2
    jp nz,glyph_done
    ld a,$f8
    ld (glyph_cmp),a
    ld a,(f_source)
    ld b,a
    ld a,(glyph_cmp)
    ld c,a
    ld a,b
    cp c
    jp c,glyph_branch_2
    jp nz,glyph_done
glyph_branch_2:
    ld a,$ff
    ld (glyph_cmp),a
    ld a,(f_dest+1)
    ld b,a
    ld a,(glyph_cmp)
    ld c,a
    ld a,b
    cp c
    jp c,glyph_branch_3
    jp nz,glyph_done
    ld a,$f8
    ld (glyph_cmp),a
    ld a,(f_dest)
    ld b,a
    ld a,(glyph_cmp)
    ld c,a
    ld a,b
    cp c
    jp c,glyph_branch_3
    jp nz,glyph_done
glyph_branch_3:
; Copy all eight source rows before clearing the destination.
    ld a,$00
    ld (f_i),a
    ld hl,(f_source)
    ld (f_ptr),hl
glyph_snapshot:
    ld hl,(f_ptr)
    ld a,(hl)
    push af
    ld a,(f_i)
    ld l,a
    ld h,0
    ld de,f_copy
    add hl,de
    pop af
    ld (hl),a
    ld hl,(f_ptr)
    ld de,$0001
    add hl,de
    ld (f_ptr),hl
    or a
    ld a,$01
    ld b,a
    ld a,(f_i)
    adc a,b
    ld (f_i),a
    ld a,$08
    ld (glyph_cmp),a
    ld a,(f_i)
    ld b,a
    ld a,(glyph_cmp)
    ld c,a
    ld a,b
    cp c
    jp c,glyph_snapshot
glyph_branch_4:
    ld a,$00
    ld (f_i),a
    ld hl,(f_dest)
    ld (f_ptr),hl
glyph_clear:
    ld a,$00
    ld hl,(f_ptr)
    ld (hl),a
    ld hl,(f_ptr)
    ld de,$0001
    add hl,de
    ld (f_ptr),hl
    or a
    ld a,$01
    ld b,a
    ld a,(f_i)
    adc a,b
    ld (f_i),a
    ld a,$08
    ld (glyph_cmp),a
    ld a,(f_i)
    ld b,a
    ld a,(glyph_cmp)
    ld c,a
    ld a,b
    cp c
    jp c,glyph_clear
glyph_branch_5:
    ld a,$00
    ld (f_y),a
glyph_row:
    ld a,(f_y)
    ld l,a
    ld h,0
    ld de,f_copy
    add hl,de
    ld a,(hl)
    ld (f_bits),a
    ld a,$00
    ld (f_x),a
glyph_pixel:
    ld a,(f_bits)
    and $80
    jp z,glyph_next
    ld a,(f_x)
    ld (f_dx),a
    ld a,(f_y)
    ld (f_dy),a
    ld a,(f_flags)
    and 3
    ld (f_turns),a
glyph_turn:
    ld a,$00
    ld (glyph_cmp),a
    ld a,(f_turns)
    ld b,a
    ld a,(glyph_cmp)
    ld c,a
    ld a,b
    cp c
    jp nz,glyph_branch_6
    jp glyph_reflect
glyph_branch_6:
    ld a,(f_dx)
    ld (f_tmp),a
; BEGIN ROTATION FIX: (x,y) becomes (7-y,x), not (y,x).
    ld a,$07
    ld (f_dx),a
    or a
    ld a,(f_dy)
    ld b,a
    ld a,(f_dx)
    sbc a,b
    ld (f_dx),a
; END ROTATION FIX
    ld a,(f_tmp)
    ld (f_dy),a
    or a
    ld a,$ff
    ld b,a
    ld a,(f_turns)
    adc a,b
    ld (f_turns),a
    jp glyph_turn
glyph_reflect:
    ld a,(f_flags)
    and 4
    jp z,glyph_store
    ld a,$07
    ld (f_tmp),a
    or a
    ld a,(f_dx)
    ld b,a
    ld a,(f_tmp)
    sbc a,b
    ld (f_tmp),a
    ld a,(f_tmp)
    ld (f_dx),a
glyph_store:
    ld a,(f_dx)
    ld l,a
    ld h,0
    ld de,glyph_masks
    add hl,de
    ld a,(hl)
    ld (f_mask),a
    ld hl,$0000
    ld (f_ptr),hl
    ld a,(f_dy)
    ld (f_ptr),a
    ld hl,(f_ptr)
    ld de,(f_dest)
    add hl,de
    ld (f_ptr),hl
    ld hl,(f_ptr)
    ld a,(hl)
    ld b,a
    ld a,(f_mask)
    or b
    ld hl,(f_ptr)
    ld (hl),a
glyph_next:
    ld hl,f_bits
    sla (hl)
    or a
    ld a,$01
    ld b,a
    ld a,(f_x)
    adc a,b
    ld (f_x),a
    ld a,$08
    ld (glyph_cmp),a
    ld a,(f_x)
    ld b,a
    ld a,(glyph_cmp)
    ld c,a
    ld a,b
    cp c
    jp c,glyph_pixel
glyph_branch_7:
    or a
    ld a,$01
    ld b,a
    ld a,(f_y)
    adc a,b
    ld (f_y),a
    ld a,$08
    ld (glyph_cmp),a
    ld a,(f_y)
    ld b,a
    ld a,(glyph_cmp)
    ld c,a
    ld a,b
    cp c
    jp c,glyph_row
glyph_branch_8:
    ld a,$01
    ld (f_status),a
glyph_done:
    ret
glyph_masks:
    db 128,64,32,16,8,4,2,1
glyph_transform_end:
