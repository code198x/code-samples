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
glyph_resize:
    ld a,$00
    ld (r_status),a
    ld a,$01
    ld (resize_cmp),a
    ld a,(r_width)
    ld b,a
    ld a,(resize_cmp)
    ld c,a
    ld a,b
    cp c
    jp c,resize_done
resize_branch_1:
    ld a,$08
    ld (resize_cmp),a
    ld a,(r_width)
    ld b,a
    ld a,(resize_cmp)
    ld c,a
    ld a,b
    cp c
    jp c,resize_branch_2
    jp nz,resize_done
resize_branch_2:
    ld a,$01
    ld (resize_cmp),a
    ld a,(r_height)
    ld b,a
    ld a,(resize_cmp)
    ld c,a
    ld a,b
    cp c
    jp c,resize_done
resize_branch_3:
    ld a,$08
    ld (resize_cmp),a
    ld a,(r_height)
    ld b,a
    ld a,(resize_cmp)
    ld c,a
    ld a,b
    cp c
    jp c,resize_branch_4
    jp nz,resize_done
resize_branch_4:
    ld a,$ff
    ld (resize_cmp),a
    ld a,(r_source+1)
    ld b,a
    ld a,(resize_cmp)
    ld c,a
    ld a,b
    cp c
    jp c,resize_branch_5
    jp nz,resize_done
    ld a,$f8
    ld (resize_cmp),a
    ld a,(r_source)
    ld b,a
    ld a,(resize_cmp)
    ld c,a
    ld a,b
    cp c
    jp c,resize_branch_5
    jp nz,resize_done
resize_branch_5:
    ld a,$ff
    ld (resize_cmp),a
    ld a,(r_dest+1)
    ld b,a
    ld a,(resize_cmp)
    ld c,a
    ld a,b
    cp c
    jp c,resize_branch_6
    jp nz,resize_done
    ld a,$f8
    ld (resize_cmp),a
    ld a,(r_dest)
    ld b,a
    ld a,(resize_cmp)
    ld c,a
    ld a,b
    cp c
    jp c,resize_branch_6
    jp nz,resize_done
resize_branch_6:
    ld a,$00
    ld (r_x),a
    ld hl,(r_source)
    ld (r_ptr),hl
resize_snapshot:
    ld hl,(r_ptr)
    ld a,(hl)
    push af
    ld a,(r_x)
    ld l,a
    ld h,0
    ld de,r_copy
    add hl,de
    pop af
    ld (hl),a
    ld hl,(r_ptr)
    ld de,$0001
    add hl,de
    ld (r_ptr),hl
    or a
    ld a,$01
    ld b,a
    ld a,(r_x)
    adc a,b
    ld (r_x),a
    ld a,$08
    ld (resize_cmp),a
    ld a,(r_x)
    ld b,a
    ld a,(resize_cmp)
    ld c,a
    ld a,b
    cp c
    jp c,resize_snapshot
resize_branch_7:
    ld a,$00
    ld (r_x),a
    ld hl,(r_dest)
    ld (r_ptr),hl
resize_clear:
    ld a,$00
    ld hl,(r_ptr)
    ld (hl),a
    ld hl,(r_ptr)
    ld de,$0001
    add hl,de
    ld (r_ptr),hl
    or a
    ld a,$01
    ld b,a
    ld a,(r_x)
    adc a,b
    ld (r_x),a
    ld a,$08
    ld (resize_cmp),a
    ld a,(r_x)
    ld b,a
    ld a,(resize_cmp)
    ld c,a
    ld a,b
    cp c
    jp c,resize_clear
resize_branch_8:
    ld a,$00
    ld (r_y),a
    ld a,$00
    ld (r_sy),a
    ld a,$00
    ld (r_ye),a
resize_row:
    ld a,(r_sy)
    ld l,a
    ld h,0
    ld de,r_copy
    add hl,de
    ld a,(hl)
    ld (r_bits),a
    ld a,$00
    ld (r_x),a
    ld a,$00
    ld (r_sx),a
    ld a,$00
    ld (r_xe),a
resize_pixel:
    ld a,(r_sx)
    ld l,a
    ld h,0
    ld de,resize_masks
    add hl,de
    ld a,(hl)
    ld b,a
    ld a,(r_bits)
    and b
    jp z,resize_next
    ld a,(r_x)
    ld l,a
    ld h,0
    ld de,resize_masks
    add hl,de
    ld a,(hl)
    ld (r_mask),a
    ld hl,$0000
    ld (r_ptr),hl
    ld a,(r_y)
    ld (r_ptr),a
    ld hl,(r_ptr)
    ld de,(r_dest)
    add hl,de
    ld (r_ptr),hl
    ld hl,(r_ptr)
    ld a,(hl)
    ld b,a
    ld a,(r_mask)
    or b
    ld hl,(r_ptr)
    ld (hl),a
resize_next:
; BEGIN SAMPLING FIX: accumulate eight source steps per destination width.
    or a
    ld a,$08
    ld b,a
    ld a,(r_xe)
    adc a,b
    ld (r_xe),a
resize_x_sample:
    ld a,(r_width)
    ld (resize_cmp),a
    ld a,(r_xe)
    ld b,a
    ld a,(resize_cmp)
    ld c,a
    ld a,b
    cp c
    jp c,resize_x_ready
resize_branch_9:
    or a
    ld a,(r_width)
    ld b,a
    ld a,(r_xe)
    sbc a,b
    ld (r_xe),a
    or a
    ld a,$01
    ld b,a
    ld a,(r_sx)
    adc a,b
    ld (r_sx),a
    jp resize_x_sample
resize_x_ready:
; END SAMPLING FIX
    or a
    ld a,$01
    ld b,a
    ld a,(r_x)
    adc a,b
    ld (r_x),a
    ld a,(r_width)
    ld (resize_cmp),a
    ld a,(r_x)
    ld b,a
    ld a,(resize_cmp)
    ld c,a
    ld a,b
    cp c
    jp c,resize_pixel
resize_branch_10:
    or a
    ld a,$08
    ld b,a
    ld a,(r_ye)
    adc a,b
    ld (r_ye),a
resize_y_sample:
    ld a,(r_height)
    ld (resize_cmp),a
    ld a,(r_ye)
    ld b,a
    ld a,(resize_cmp)
    ld c,a
    ld a,b
    cp c
    jp c,resize_y_ready
resize_branch_11:
    or a
    ld a,(r_height)
    ld b,a
    ld a,(r_ye)
    sbc a,b
    ld (r_ye),a
    or a
    ld a,$01
    ld b,a
    ld a,(r_sy)
    adc a,b
    ld (r_sy),a
    jp resize_y_sample
resize_y_ready:
    or a
    ld a,$01
    ld b,a
    ld a,(r_y)
    adc a,b
    ld (r_y),a
    ld a,(r_height)
    ld (resize_cmp),a
    ld a,(r_y)
    ld b,a
    ld a,(resize_cmp)
    ld c,a
    ld a,b
    cp c
    jp c,resize_row
resize_branch_12:
    ld a,$01
    ld (r_status),a
resize_done:
    ret
resize_masks:
    db 128,64,32,16,8,4,2,1
glyph_resize_end:
