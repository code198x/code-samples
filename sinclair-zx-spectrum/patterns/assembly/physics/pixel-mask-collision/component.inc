; SPDX-License-Identifier: MIT
; Test Two Small Opaque Pixel Masks. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
pixel_mask_collision_init:
    ld a,0
    ld (HIT),a
    ld (ROW),a
    ld (SHIFT_X),a
    ld (SHIFT_Y),a
    ld (P0),a
    ld (P1),a
    ld (P2),a
    ld (P3),a
    ld (P4),a
    ld (P5),a
    ld (P6),a
    ld (P7),a
    ld (Q0),a
    ld (Q1),a
    ld (Q2),a
    ld (Q3),a
    ld (Q4),a
    ld (Q5),a
    ld (Q6),a
    ld (Q7),a
    ld (T0),a
    ld (T1),a
    ld (T2),a
    ld (T3),a
    ld (T4),a
    ld (T5),a
    ret
pixel_mask_collision_step:
; HIT = 0
    ld a,0
    ld (HIT),a
; ROW = 255
    ld a,255
    ld (ROW),a
; if SHIFT_X >= 8:
    ld a,(SHIFT_X)
    cp 8
    jp nc,pixel_mask_collision_L1
    jp pixel_mask_collision_L2
pixel_mask_collision_L1:
; return
    ret
    jp pixel_mask_collision_L3
pixel_mask_collision_L2:
pixel_mask_collision_L3:
; if SHIFT_Y >= 8:
    ld a,(SHIFT_Y)
    cp 8
    jp nc,pixel_mask_collision_L4
    jp pixel_mask_collision_L5
pixel_mask_collision_L4:
; return
    ret
    jp pixel_mask_collision_L6
pixel_mask_collision_L5:
pixel_mask_collision_L6:
; T0 = 0
    ld a,0
    ld (T0),a
; T5 = 8 - SHIFT_Y
    ld a,8
    ld b,a
    ld a,(SHIFT_Y)
    ld c,a
    ld a,b
    sub c
    ld (T5),a
; while T0 < T5:
pixel_mask_collision_L7:
    ld a,(T0)
    ld b,a
    ld a,(T5)
    ld c,a
    ld a,b
    cp c
    jp c,pixel_mask_collision_L8
    jp pixel_mask_collision_L9
pixel_mask_collision_L8:
; T1 = Q[T0]
    ld a,(T0)
    ld e,a
    ld d,0
    ld hl,Q0
    add hl,de
    ld a,(hl)
    ld (T1),a
; T2 = SHIFT_X
    ld a,(SHIFT_X)
    ld (T2),a
; while T2 != 0:
pixel_mask_collision_L10:
    ld a,(T2)
    cp 0
    jp nz,pixel_mask_collision_L11
    jp pixel_mask_collision_L12
pixel_mask_collision_L11:
; T1 = T1 >> 1
    ld a,(T1)
    srl a
    ld (T1),a
; T2 = T2 - 1
    ld a,(T2)
    sub 1
    ld (T2),a
    jp pixel_mask_collision_L10
pixel_mask_collision_L12:
; T3 = T0 + SHIFT_Y
    ld a,(T0)
    ld b,a
    ld a,(SHIFT_Y)
    ld c,a
    ld a,b
    add a,c
    ld (T3),a
; T4 = P[T3]
    ld a,(T3)
    ld e,a
    ld d,0
    ld hl,P0
    add hl,de
    ld a,(hl)
    ld (T4),a
; T4 = T4 & T1
    ld a,(T4)
    ld b,a
    ld a,(T1)
    ld c,a
    ld a,b
    and c
    ld (T4),a
; if T4 != 0:
    ld a,(T4)
    cp 0
    jp nz,pixel_mask_collision_L13
    jp pixel_mask_collision_L14
pixel_mask_collision_L13:
; HIT = 1
    ld a,1
    ld (HIT),a
; ROW = T3
    ld a,(T3)
    ld (ROW),a
; return
    ret
    jp pixel_mask_collision_L15
pixel_mask_collision_L14:
pixel_mask_collision_L15:
; T0 = T0 + 1
    ld a,(T0)
    add a,1
    ld (T0),a
    jp pixel_mask_collision_L7
pixel_mask_collision_L9:
    ret
component_end:
