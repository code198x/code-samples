; SPDX-License-Identifier: MIT
; Encode a Small Run-length Block. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
bounded_rle_encoder_init:
    ld a,0
    ld (WRITTEN),a
    ld (ERROR),a
    ld (VALID),a
    ld (INPUT_COUNT),a
    ld (CAPACITY),a
    ld (B0),a
    ld (B1),a
    ld (B2),a
    ld (B3),a
    ld (B4),a
    ld (B5),a
    ld (B6),a
    ld (B7),a
    ld (R0),a
    ld (R1),a
    ld (R2),a
    ld (R3),a
    ld (R4),a
    ld (R5),a
    ld (R6),a
    ld (R7),a
    ld (R8),a
    ld (R9),a
    ld (R10),a
    ld (R11),a
    ld (R12),a
    ld (R13),a
    ld (R14),a
    ld (R15),a
    ld (T0),a
    ld (T1),a
    ld (T2),a
    ld (T3),a
    ld (T4),a
    ld (EXPR_SAVE),a
    ret
bounded_rle_encoder_step:
; WRITTEN = 0
    ld a,0
    ld (WRITTEN),a
; ERROR = 1
    ld a,1
    ld (ERROR),a
; VALID = 0
    ld a,0
    ld (VALID),a
; if INPUT_COUNT > 8:
    ld a,(INPUT_COUNT)
    cp 8
    jp z,bounded_rle_encoder_L2
    jp nc,bounded_rle_encoder_L1
    jp bounded_rle_encoder_L2
bounded_rle_encoder_L1:
; return
    ret
    jp bounded_rle_encoder_L3
bounded_rle_encoder_L2:
bounded_rle_encoder_L3:
; if CAPACITY > 16:
    ld a,(CAPACITY)
    cp 16
    jp z,bounded_rle_encoder_L5
    jp nc,bounded_rle_encoder_L4
    jp bounded_rle_encoder_L5
bounded_rle_encoder_L4:
; return
    ret
    jp bounded_rle_encoder_L6
bounded_rle_encoder_L5:
bounded_rle_encoder_L6:
; VALID = 1
    ld a,1
    ld (VALID),a
; ERROR = 0
    ld a,0
    ld (ERROR),a
; if INPUT_COUNT == 0:
    ld a,(INPUT_COUNT)
    cp 0
    jp z,bounded_rle_encoder_L7
    jp bounded_rle_encoder_L8
bounded_rle_encoder_L7:
; return
    ret
    jp bounded_rle_encoder_L9
bounded_rle_encoder_L8:
bounded_rle_encoder_L9:
; T0 = 1
    ld a,1
    ld (T0),a
; T1 = B[0]
    ld a,0
    ld e,a
    ld d,0
    ld hl,B0
    add hl,de
    ld a,(hl)
    ld (T1),a
; T2 = 1
    ld a,1
    ld (T2),a
; while T0 < INPUT_COUNT:
bounded_rle_encoder_L10:
    ld a,(T0)
    ld b,a
    ld a,(INPUT_COUNT)
    ld c,a
    ld a,b
    cp c
    jp c,bounded_rle_encoder_L11
    jp bounded_rle_encoder_L12
bounded_rle_encoder_L11:
; T3 = B[T0]
    ld a,(T0)
    ld e,a
    ld d,0
    ld hl,B0
    add hl,de
    ld a,(hl)
    ld (T3),a
; if T3 != T1:
    ld a,(T3)
    ld b,a
    ld a,(T1)
    ld c,a
    ld a,b
    cp c
    jp nz,bounded_rle_encoder_L13
    jp bounded_rle_encoder_L14
bounded_rle_encoder_L13:
; T2 = T2 + 1
    ld a,(T2)
    add a,1
    ld (T2),a
; T1 = T3
    ld a,(T3)
    ld (T1),a
    jp bounded_rle_encoder_L15
bounded_rle_encoder_L14:
bounded_rle_encoder_L15:
; T0 = T0 + 1
    ld a,(T0)
    add a,1
    ld (T0),a
    jp bounded_rle_encoder_L10
bounded_rle_encoder_L12:
; T2 = T2 << 1
    ld a,(T2)
    sla a
    ld (T2),a
; if T2 > CAPACITY:
    ld a,(T2)
    ld b,a
    ld a,(CAPACITY)
    ld c,a
    ld a,b
    cp c
    jp z,bounded_rle_encoder_L17
    jp nc,bounded_rle_encoder_L16
    jp bounded_rle_encoder_L17
bounded_rle_encoder_L16:
; ERROR = 2
    ld a,2
    ld (ERROR),a
; return
    ret
    jp bounded_rle_encoder_L18
bounded_rle_encoder_L17:
bounded_rle_encoder_L18:
; T0 = 0
    ld a,0
    ld (T0),a
; T1 = 0
    ld a,0
    ld (T1),a
; while T0 < INPUT_COUNT:
bounded_rle_encoder_L19:
    ld a,(T0)
    ld b,a
    ld a,(INPUT_COUNT)
    ld c,a
    ld a,b
    cp c
    jp c,bounded_rle_encoder_L20
    jp bounded_rle_encoder_L21
bounded_rle_encoder_L20:
; T2 = B[T0]
    ld a,(T0)
    ld e,a
    ld d,0
    ld hl,B0
    add hl,de
    ld a,(hl)
    ld (T2),a
; T3 = 1
    ld a,1
    ld (T3),a
; T0 = T0 + 1
    ld a,(T0)
    add a,1
    ld (T0),a
; while T0 < INPUT_COUNT:
bounded_rle_encoder_L22:
    ld a,(T0)
    ld b,a
    ld a,(INPUT_COUNT)
    ld c,a
    ld a,b
    cp c
    jp c,bounded_rle_encoder_L23
    jp bounded_rle_encoder_L24
bounded_rle_encoder_L23:
; T4 = B[T0]
    ld a,(T0)
    ld e,a
    ld d,0
    ld hl,B0
    add hl,de
    ld a,(hl)
    ld (T4),a
; if T4 != T2:
    ld a,(T4)
    ld b,a
    ld a,(T2)
    ld c,a
    ld a,b
    cp c
    jp nz,bounded_rle_encoder_L25
    jp bounded_rle_encoder_L26
bounded_rle_encoder_L25:
; break
    jp bounded_rle_encoder_L24
    jp bounded_rle_encoder_L27
bounded_rle_encoder_L26:
bounded_rle_encoder_L27:
; T3 = T3 + 1
    ld a,(T3)
    add a,1
    ld (T3),a
; T0 = T0 + 1
    ld a,(T0)
    add a,1
    ld (T0),a
    jp bounded_rle_encoder_L22
bounded_rle_encoder_L24:
; R[T1] = T3
    ld a,(T3)
    ld c,a
    ld a,(T1)
    ld e,a
    ld d,0
    ld hl,R0
    add hl,de
    ld (hl),c
; T1 = T1 + 1
    ld a,(T1)
    add a,1
    ld (T1),a
; R[T1] = T2
    ld a,(T2)
    ld c,a
    ld a,(T1)
    ld e,a
    ld d,0
    ld hl,R0
    add hl,de
    ld (hl),c
; T1 = T1 + 1
    ld a,(T1)
    add a,1
    ld (T1),a
    jp bounded_rle_encoder_L19
bounded_rle_encoder_L21:
; WRITTEN = T1
    ld a,(T1)
    ld (WRITTEN),a
    ret
component_end:
