; SPDX-License-Identifier: MIT
; Keep a Small Position History. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
motion_history_init:
    ld a,0
    ld (OUT_X),a
    ld (OUT_Y),a
    ld (VALID),a
    ld (HEAD),a
    ld (COUNT),a
    ld (INPUT_X),a
    ld (INPUT_Y),a
    ld (LAG),a
    ld (APPEND_SAMPLE),a
    ld (HX0),a
    ld (HX1),a
    ld (HX2),a
    ld (HX3),a
    ld (HX4),a
    ld (HX5),a
    ld (HX6),a
    ld (HX7),a
    ld (HY0),a
    ld (HY1),a
    ld (HY2),a
    ld (HY3),a
    ld (HY4),a
    ld (HY5),a
    ld (HY6),a
    ld (HY7),a
    ld (T0),a
    ld (EXPR_SAVE),a
    ret
motion_history_step:
; OUT_X = 0
    ld a,0
    ld (OUT_X),a
; OUT_Y = 0
    ld a,0
    ld (OUT_Y),a
; VALID = 0
    ld a,0
    ld (VALID),a
; if HEAD >= 8:
    ld a,(HEAD)
    cp 8
    jp nc,motion_history_L1
    jp motion_history_L2
motion_history_L1:
; return
    ret
    jp motion_history_L3
motion_history_L2:
motion_history_L3:
; if COUNT > 8:
    ld a,(COUNT)
    cp 8
    jp z,motion_history_L5
    jp nc,motion_history_L4
    jp motion_history_L5
motion_history_L4:
; return
    ret
    jp motion_history_L6
motion_history_L5:
motion_history_L6:
; if APPEND_SAMPLE != 0:
    ld a,(APPEND_SAMPLE)
    cp 0
    jp nz,motion_history_L7
    jp motion_history_L8
motion_history_L7:
; HX[HEAD] = INPUT_X
    ld a,(INPUT_X)
    ld c,a
    ld a,(HEAD)
    ld e,a
    ld d,0
    ld hl,HX0
    add hl,de
    ld (hl),c
; HY[HEAD] = INPUT_Y
    ld a,(INPUT_Y)
    ld c,a
    ld a,(HEAD)
    ld e,a
    ld d,0
    ld hl,HY0
    add hl,de
    ld (hl),c
; HEAD = HEAD + 1
    ld a,(HEAD)
    add a,1
    ld (HEAD),a
; HEAD = HEAD & 7
    ld a,(HEAD)
    and 7
    ld (HEAD),a
; if COUNT < 8:
    ld a,(COUNT)
    cp 8
    jp c,motion_history_L10
    jp motion_history_L11
motion_history_L10:
; COUNT = COUNT + 1
    ld a,(COUNT)
    add a,1
    ld (COUNT),a
    jp motion_history_L12
motion_history_L11:
motion_history_L12:
    jp motion_history_L9
motion_history_L8:
motion_history_L9:
; if LAG >= COUNT:
    ld a,(LAG)
    ld b,a
    ld a,(COUNT)
    ld c,a
    ld a,b
    cp c
    jp nc,motion_history_L13
    jp motion_history_L14
motion_history_L13:
; return
    ret
    jp motion_history_L15
motion_history_L14:
motion_history_L15:
; T0 = HEAD - 1
    ld a,(HEAD)
    sub 1
    ld (T0),a
; T0 = T0 - LAG
    ld a,(T0)
    ld b,a
    ld a,(LAG)
    ld c,a
    ld a,b
    sub c
    ld (T0),a
; T0 = T0 & 7
    ld a,(T0)
    and 7
    ld (T0),a
; OUT_X = HX[T0]
    ld a,(T0)
    ld e,a
    ld d,0
    ld hl,HX0
    add hl,de
    ld a,(hl)
    ld (OUT_X),a
; OUT_Y = HY[T0]
    ld a,(T0)
    ld e,a
    ld d,0
    ld hl,HY0
    add hl,de
    ld a,(hl)
    ld (OUT_Y),a
; VALID = 1
    ld a,1
    ld (VALID),a
    ret
component_end:
