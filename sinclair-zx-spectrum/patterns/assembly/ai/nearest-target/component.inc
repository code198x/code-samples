; SPDX-License-Identifier: MIT
; Select the Nearest Active Target. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
nearest_target_init:
    ld a,0
    ld (SLOT),a
    ld (DISTANCE_LO),a
    ld (DISTANCE_HI),a
    ld (FOUND),a
    ld (ACTIVE),a
    ld (ORIGIN_X),a
    ld (ORIGIN_Y),a
    ld (PX0),a
    ld (PX1),a
    ld (PX2),a
    ld (PX3),a
    ld (PY0),a
    ld (PY1),a
    ld (PY2),a
    ld (PY3),a
    ld (T0),a
    ld (T1),a
    ld (T2),a
    ld (T3),a
    ld (T4),a
    ld (T5),a
    ld (T6),a
    ld (T7),a
    ret
nearest_target_step:
; SLOT = 255
    ld a,255
    ld (SLOT),a
; DISTANCE_LO = 0
    ld a,0
    ld (DISTANCE_LO),a
; DISTANCE_HI = 0
    ld a,0
    ld (DISTANCE_HI),a
; FOUND = 0
    ld a,0
    ld (FOUND),a
; T0 = 0
    ld a,0
    ld (T0),a
; T1 = 1
    ld a,1
    ld (T1),a
; while T0 < 4:
nearest_target_L1:
    ld a,(T0)
    cp 4
    jp c,nearest_target_L2
    jp nearest_target_L3
nearest_target_L2:
; T2 = ACTIVE & T1
    ld a,(ACTIVE)
    ld b,a
    ld a,(T1)
    ld c,a
    ld a,b
    and c
    ld (T2),a
; if T2 != 0:
    ld a,(T2)
    cp 0
    jp nz,nearest_target_L4
    jp nearest_target_L5
nearest_target_L4:
; T2 = PX[T0]
    ld a,(T0)
    ld e,a
    ld d,0
    ld hl,PX0
    add hl,de
    ld a,(hl)
    ld (T2),a
; if T2 >= ORIGIN_X:
    ld a,(T2)
    ld b,a
    ld a,(ORIGIN_X)
    ld c,a
    ld a,b
    cp c
    jp nc,nearest_target_L7
    jp nearest_target_L8
nearest_target_L7:
; T3 = T2 - ORIGIN_X
    ld a,(T2)
    ld b,a
    ld a,(ORIGIN_X)
    ld c,a
    ld a,b
    sub c
    ld (T3),a
    jp nearest_target_L9
nearest_target_L8:
; T3 = ORIGIN_X - T2
    ld a,(ORIGIN_X)
    ld b,a
    ld a,(T2)
    ld c,a
    ld a,b
    sub c
    ld (T3),a
nearest_target_L9:
; T2 = PY[T0]
    ld a,(T0)
    ld e,a
    ld d,0
    ld hl,PY0
    add hl,de
    ld a,(hl)
    ld (T2),a
; if T2 >= ORIGIN_Y:
    ld a,(T2)
    ld b,a
    ld a,(ORIGIN_Y)
    ld c,a
    ld a,b
    cp c
    jp nc,nearest_target_L10
    jp nearest_target_L11
nearest_target_L10:
; T4 = T2 - ORIGIN_Y
    ld a,(T2)
    ld b,a
    ld a,(ORIGIN_Y)
    ld c,a
    ld a,b
    sub c
    ld (T4),a
    jp nearest_target_L12
nearest_target_L11:
; T4 = ORIGIN_Y - T2
    ld a,(ORIGIN_Y)
    ld b,a
    ld a,(T2)
    ld c,a
    ld a,b
    sub c
    ld (T4),a
nearest_target_L12:
; T5 = T3 + T4
    ld a,(T3)
    ld b,a
    ld a,(T4)
    ld c,a
    ld a,b
    add a,c
    ld (T5),a
; T6 = 0
    ld a,0
    ld (T6),a
; if T5 < T3:
    ld a,(T5)
    ld b,a
    ld a,(T3)
    ld c,a
    ld a,b
    cp c
    jp c,nearest_target_L13
    jp nearest_target_L14
nearest_target_L13:
; T6 = 1
    ld a,1
    ld (T6),a
    jp nearest_target_L15
nearest_target_L14:
nearest_target_L15:
; T7 = 0
    ld a,0
    ld (T7),a
; if FOUND == 0:
    ld a,(FOUND)
    cp 0
    jp z,nearest_target_L16
    jp nearest_target_L17
nearest_target_L16:
; T7 = 1
    ld a,1
    ld (T7),a
    jp nearest_target_L18
nearest_target_L17:
nearest_target_L18:
; if T6 < DISTANCE_HI:
    ld a,(T6)
    ld b,a
    ld a,(DISTANCE_HI)
    ld c,a
    ld a,b
    cp c
    jp c,nearest_target_L19
    jp nearest_target_L20
nearest_target_L19:
; T7 = 1
    ld a,1
    ld (T7),a
    jp nearest_target_L21
nearest_target_L20:
nearest_target_L21:
; if T6 == DISTANCE_HI:
    ld a,(T6)
    ld b,a
    ld a,(DISTANCE_HI)
    ld c,a
    ld a,b
    cp c
    jp z,nearest_target_L22
    jp nearest_target_L23
nearest_target_L22:
; if T5 < DISTANCE_LO:
    ld a,(T5)
    ld b,a
    ld a,(DISTANCE_LO)
    ld c,a
    ld a,b
    cp c
    jp c,nearest_target_L25
    jp nearest_target_L26
nearest_target_L25:
; T7 = 1
    ld a,1
    ld (T7),a
    jp nearest_target_L27
nearest_target_L26:
nearest_target_L27:
    jp nearest_target_L24
nearest_target_L23:
nearest_target_L24:
; if T7 != 0:
    ld a,(T7)
    cp 0
    jp nz,nearest_target_L28
    jp nearest_target_L29
nearest_target_L28:
; SLOT = T0
    ld a,(T0)
    ld (SLOT),a
; DISTANCE_LO = T5
    ld a,(T5)
    ld (DISTANCE_LO),a
; DISTANCE_HI = T6
    ld a,(T6)
    ld (DISTANCE_HI),a
; FOUND = 1
    ld a,1
    ld (FOUND),a
    jp nearest_target_L30
nearest_target_L29:
nearest_target_L30:
    jp nearest_target_L6
nearest_target_L5:
nearest_target_L6:
; T0 = T0 + 1
    ld a,(T0)
    add a,1
    ld (T0),a
; T1 = T1 << 1
    ld a,(T1)
    sla a
    ld (T1),a
    jp nearest_target_L1
nearest_target_L3:
    ret
component_end:
