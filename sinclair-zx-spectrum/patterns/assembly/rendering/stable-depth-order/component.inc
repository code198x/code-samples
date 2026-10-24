; SPDX-License-Identifier: MIT
; Sort a Small Draw Order Stably. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
stable_depth_order_init:
    ld a,0
    ld (COUNT),a
    ld (VALID),a
    ld (Z0),a
    ld (Z1),a
    ld (Z2),a
    ld (Z3),a
    ld (Z4),a
    ld (Z5),a
    ld (Z6),a
    ld (Z7),a
    ld (I0),a
    ld (I1),a
    ld (I2),a
    ld (I3),a
    ld (I4),a
    ld (I5),a
    ld (I6),a
    ld (I7),a
    ld (T0),a
    ld (T1),a
    ld (T2),a
    ld (T3),a
    ld (T4),a
    ld (T5),a
    ld (T6),a
    ld (EXPR_SAVE),a
    ret
stable_depth_order_step:
; VALID = 0
    ld a,0
    ld (VALID),a
; if COUNT > 8:
    ld a,(COUNT)
    cp 8
    jp z,stable_depth_order_L2
    jp nc,stable_depth_order_L1
    jp stable_depth_order_L2
stable_depth_order_L1:
; return
    ret
    jp stable_depth_order_L3
stable_depth_order_L2:
stable_depth_order_L3:
; T0 = 0
    ld a,0
    ld (T0),a
; while T0 < 8:
stable_depth_order_L4:
    ld a,(T0)
    cp 8
    jp c,stable_depth_order_L5
    jp stable_depth_order_L6
stable_depth_order_L5:
; I[T0] = T0
    ld a,(T0)
    ld c,a
    ld a,(T0)
    ld e,a
    ld d,0
    ld hl,I0
    add hl,de
    ld (hl),c
; T0 = T0 + 1
    ld a,(T0)
    add a,1
    ld (T0),a
    jp stable_depth_order_L4
stable_depth_order_L6:
; T0 = 1
    ld a,1
    ld (T0),a
; while T0 < COUNT:
stable_depth_order_L7:
    ld a,(T0)
    ld b,a
    ld a,(COUNT)
    ld c,a
    ld a,b
    cp c
    jp c,stable_depth_order_L8
    jp stable_depth_order_L9
stable_depth_order_L8:
; T1 = I[T0]
    ld a,(T0)
    ld e,a
    ld d,0
    ld hl,I0
    add hl,de
    ld a,(hl)
    ld (T1),a
; T2 = Z[T1]
    ld a,(T1)
    ld e,a
    ld d,0
    ld hl,Z0
    add hl,de
    ld a,(hl)
    ld (T2),a
; T3 = T0
    ld a,(T0)
    ld (T3),a
; while T3 != 0:
stable_depth_order_L10:
    ld a,(T3)
    cp 0
    jp nz,stable_depth_order_L11
    jp stable_depth_order_L12
stable_depth_order_L11:
; T4 = T3 - 1
    ld a,(T3)
    sub 1
    ld (T4),a
; T5 = I[T4]
    ld a,(T4)
    ld e,a
    ld d,0
    ld hl,I0
    add hl,de
    ld a,(hl)
    ld (T5),a
; T6 = Z[T5]
    ld a,(T5)
    ld e,a
    ld d,0
    ld hl,Z0
    add hl,de
    ld a,(hl)
    ld (T6),a
; if T6 <= T2:
    ld a,(T6)
    ld b,a
    ld a,(T2)
    ld c,a
    ld a,b
    cp c
    jp c,stable_depth_order_L13
    jp z,stable_depth_order_L13
    jp stable_depth_order_L14
stable_depth_order_L13:
; break
    jp stable_depth_order_L12
    jp stable_depth_order_L15
stable_depth_order_L14:
stable_depth_order_L15:
; I[T3] = T5
    ld a,(T5)
    ld c,a
    ld a,(T3)
    ld e,a
    ld d,0
    ld hl,I0
    add hl,de
    ld (hl),c
; T3 = T3 - 1
    ld a,(T3)
    sub 1
    ld (T3),a
    jp stable_depth_order_L10
stable_depth_order_L12:
; I[T3] = T1
    ld a,(T1)
    ld c,a
    ld a,(T3)
    ld e,a
    ld d,0
    ld hl,I0
    add hl,de
    ld (hl),c
; T0 = T0 + 1
    ld a,(T0)
    add a,1
    ld (T0),a
    jp stable_depth_order_L7
stable_depth_order_L9:
; VALID = 1
    ld a,1
    ld (VALID),a
    ret
component_end:
