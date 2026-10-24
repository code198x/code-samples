; SPDX-License-Identifier: MIT
; Compact a Live Object Prefix. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
stable_compaction_init:
    ld a,0
    ld (COUNT),a
    ld (REMOVED),a
    ld (VALID),a
    ld (F0),a
    ld (F1),a
    ld (F2),a
    ld (F3),a
    ld (F4),a
    ld (F5),a
    ld (F6),a
    ld (F7),a
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
    ld (EXPR_SAVE),a
    ret
stable_compaction_step:
; REMOVED = 0
    ld a,0
    ld (REMOVED),a
; VALID = 0
    ld a,0
    ld (VALID),a
; if COUNT > 8:
    ld a,(COUNT)
    cp 8
    jp z,stable_compaction_L2
    jp nc,stable_compaction_L1
    jp stable_compaction_L2
stable_compaction_L1:
; return
    ret
    jp stable_compaction_L3
stable_compaction_L2:
stable_compaction_L3:
; VALID = 1
    ld a,1
    ld (VALID),a
; T0 = 0
    ld a,0
    ld (T0),a
; T1 = 0
    ld a,0
    ld (T1),a
; T4 = COUNT
    ld a,(COUNT)
    ld (T4),a
; while T0 < T4:
stable_compaction_L4:
    ld a,(T0)
    ld b,a
    ld a,(T4)
    ld c,a
    ld a,b
    cp c
    jp c,stable_compaction_L5
    jp stable_compaction_L6
stable_compaction_L5:
; T2 = F[T0]
    ld a,(T0)
    ld e,a
    ld d,0
    ld hl,F0
    add hl,de
    ld a,(hl)
    ld (T2),a
; if T2 != 0:
    ld a,(T2)
    cp 0
    jp nz,stable_compaction_L7
    jp stable_compaction_L8
stable_compaction_L7:
; T3 = I[T0]
    ld a,(T0)
    ld e,a
    ld d,0
    ld hl,I0
    add hl,de
    ld a,(hl)
    ld (T3),a
; F[T1] = T2
    ld a,(T2)
    ld c,a
    ld a,(T1)
    ld e,a
    ld d,0
    ld hl,F0
    add hl,de
    ld (hl),c
; I[T1] = T3
    ld a,(T3)
    ld c,a
    ld a,(T1)
    ld e,a
    ld d,0
    ld hl,I0
    add hl,de
    ld (hl),c
; T1 = T1 + 1
    ld a,(T1)
    add a,1
    ld (T1),a
    jp stable_compaction_L9
stable_compaction_L8:
stable_compaction_L9:
; T0 = T0 + 1
    ld a,(T0)
    add a,1
    ld (T0),a
    jp stable_compaction_L4
stable_compaction_L6:
; COUNT = T1
    ld a,(T1)
    ld (COUNT),a
; REMOVED = T4 - T1
    ld a,(T4)
    ld b,a
    ld a,(T1)
    ld c,a
    ld a,b
    sub c
    ld (REMOVED),a
; while T1 < T4:
stable_compaction_L10:
    ld a,(T1)
    ld b,a
    ld a,(T4)
    ld c,a
    ld a,b
    cp c
    jp c,stable_compaction_L11
    jp stable_compaction_L12
stable_compaction_L11:
; F[T1] = 0
    ld a,0
    ld c,a
    ld a,(T1)
    ld e,a
    ld d,0
    ld hl,F0
    add hl,de
    ld (hl),c
; I[T1] = 0
    ld a,0
    ld c,a
    ld a,(T1)
    ld e,a
    ld d,0
    ld hl,I0
    add hl,de
    ld (hl),c
; T1 = T1 + 1
    ld a,(T1)
    add a,1
    ld (T1),a
    jp stable_compaction_L10
stable_compaction_L12:
    ret
component_end:
