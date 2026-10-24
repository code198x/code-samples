; SPDX-License-Identifier: MIT
; Remember Contact Pairs for a Step. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
contact_pair_cache_init:
    ld a,0
    ld (FIRST),a
    ld (VALID),a
    ld (MODE),a
    ld (OBJECT_A),a
    ld (OBJECT_B),a
    ld (B0),a
    ld (B1),a
    ld (B2),a
    ld (B3),a
    ld (B4),a
    ld (B5),a
    ld (B6),a
    ld (B7),a
    ld (T0),a
    ld (T1),a
    ld (T2),a
    ld (T3),a
    ld (T4),a
    ld (EXPR_SAVE),a
    ret
contact_pair_cache_step:
; FIRST = 0
    ld a,0
    ld (FIRST),a
; VALID = 0
    ld a,0
    ld (VALID),a
; if MODE > 2:
    ld a,(MODE)
    cp 2
    jp z,contact_pair_cache_L2
    jp nc,contact_pair_cache_L1
    jp contact_pair_cache_L2
contact_pair_cache_L1:
; return
    ret
    jp contact_pair_cache_L3
contact_pair_cache_L2:
contact_pair_cache_L3:
; if MODE == 0:
    ld a,(MODE)
    cp 0
    jp z,contact_pair_cache_L4
    jp contact_pair_cache_L5
contact_pair_cache_L4:
; T0 = 0
    ld a,0
    ld (T0),a
; while T0 < 8:
contact_pair_cache_L7:
    ld a,(T0)
    cp 8
    jp c,contact_pair_cache_L8
    jp contact_pair_cache_L9
contact_pair_cache_L8:
; B[T0] = 0
    ld a,0
    ld c,a
    ld a,(T0)
    ld e,a
    ld d,0
    ld hl,B0
    add hl,de
    ld (hl),c
; T0 = T0 + 1
    ld a,(T0)
    add a,1
    ld (T0),a
    jp contact_pair_cache_L7
contact_pair_cache_L9:
; VALID = 1
    ld a,1
    ld (VALID),a
; return
    ret
    jp contact_pair_cache_L6
contact_pair_cache_L5:
contact_pair_cache_L6:
; if OBJECT_A >= 8:
    ld a,(OBJECT_A)
    cp 8
    jp nc,contact_pair_cache_L10
    jp contact_pair_cache_L11
contact_pair_cache_L10:
; return
    ret
    jp contact_pair_cache_L12
contact_pair_cache_L11:
contact_pair_cache_L12:
; if OBJECT_B >= 8:
    ld a,(OBJECT_B)
    cp 8
    jp nc,contact_pair_cache_L13
    jp contact_pair_cache_L14
contact_pair_cache_L13:
; return
    ret
    jp contact_pair_cache_L15
contact_pair_cache_L14:
contact_pair_cache_L15:
; if OBJECT_A == OBJECT_B:
    ld a,(OBJECT_A)
    ld b,a
    ld a,(OBJECT_B)
    ld c,a
    ld a,b
    cp c
    jp z,contact_pair_cache_L16
    jp contact_pair_cache_L17
contact_pair_cache_L16:
; return
    ret
    jp contact_pair_cache_L18
contact_pair_cache_L17:
contact_pair_cache_L18:
; T0 = OBJECT_A
    ld a,(OBJECT_A)
    ld (T0),a
; T1 = OBJECT_B
    ld a,(OBJECT_B)
    ld (T1),a
; if T0 > T1:
    ld a,(T0)
    ld b,a
    ld a,(T1)
    ld c,a
    ld a,b
    cp c
    jp z,contact_pair_cache_L20
    jp nc,contact_pair_cache_L19
    jp contact_pair_cache_L20
contact_pair_cache_L19:
; T0 = OBJECT_B
    ld a,(OBJECT_B)
    ld (T0),a
; T1 = OBJECT_A
    ld a,(OBJECT_A)
    ld (T1),a
    jp contact_pair_cache_L21
contact_pair_cache_L20:
contact_pair_cache_L21:
; T2 = 1
    ld a,1
    ld (T2),a
; while T1 != 0:
contact_pair_cache_L22:
    ld a,(T1)
    cp 0
    jp nz,contact_pair_cache_L23
    jp contact_pair_cache_L24
contact_pair_cache_L23:
; T2 = T2 << 1
    ld a,(T2)
    sla a
    ld (T2),a
; T1 = T1 - 1
    ld a,(T1)
    sub 1
    ld (T1),a
    jp contact_pair_cache_L22
contact_pair_cache_L24:
; T3 = B[T0]
    ld a,(T0)
    ld e,a
    ld d,0
    ld hl,B0
    add hl,de
    ld a,(hl)
    ld (T3),a
; T4 = T3 & T2
    ld a,(T3)
    ld b,a
    ld a,(T2)
    ld c,a
    ld a,b
    and c
    ld (T4),a
; VALID = 1
    ld a,1
    ld (VALID),a
; if T4 == 0:
    ld a,(T4)
    cp 0
    jp z,contact_pair_cache_L25
    jp contact_pair_cache_L26
contact_pair_cache_L25:
; FIRST = 1
    ld a,1
    ld (FIRST),a
; if MODE == 1:
    ld a,(MODE)
    cp 1
    jp z,contact_pair_cache_L28
    jp contact_pair_cache_L29
contact_pair_cache_L28:
; T3 = T3 | T2
    ld a,(T3)
    ld b,a
    ld a,(T2)
    ld c,a
    ld a,b
    or c
    ld (T3),a
; B[T0] = T3
    ld a,(T3)
    ld c,a
    ld a,(T0)
    ld e,a
    ld d,0
    ld hl,B0
    add hl,de
    ld (hl),c
    jp contact_pair_cache_L30
contact_pair_cache_L29:
contact_pair_cache_L30:
    jp contact_pair_cache_L27
contact_pair_cache_L26:
contact_pair_cache_L27:
    ret
component_end:
