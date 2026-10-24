; SPDX-License-Identifier: MIT
; Insert into a High-score Table. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
high_score_insertion_init:
    ld a,0
    ld (RANK),a
    ld (INSERTED),a
    ld (VALID),a
    ld (SCORE),a
    ld (TAG),a
    ld (COUNT),a
    ld (S0),a
    ld (S1),a
    ld (S2),a
    ld (S3),a
    ld (I0),a
    ld (I1),a
    ld (I2),a
    ld (I3),a
    ld (T0),a
    ld (T1),a
    ld (T2),a
    ld (T3),a
    ld (EXPR_SAVE),a
    ret
high_score_insertion_step:
; RANK = 255
    ld a,255
    ld (RANK),a
; INSERTED = 0
    ld a,0
    ld (INSERTED),a
; VALID = 0
    ld a,0
    ld (VALID),a
; if COUNT > 4:
    ld a,(COUNT)
    cp 4
    jp z,high_score_insertion_L2
    jp nc,high_score_insertion_L1
    jp high_score_insertion_L2
high_score_insertion_L1:
; return
    ret
    jp high_score_insertion_L3
high_score_insertion_L2:
high_score_insertion_L3:
; VALID = 1
    ld a,1
    ld (VALID),a
; T0 = 0
    ld a,0
    ld (T0),a
; while T0 < COUNT:
high_score_insertion_L4:
    ld a,(T0)
    ld b,a
    ld a,(COUNT)
    ld c,a
    ld a,b
    cp c
    jp c,high_score_insertion_L5
    jp high_score_insertion_L6
high_score_insertion_L5:
; T1 = S[T0]
    ld a,(T0)
    ld e,a
    ld d,0
    ld hl,S0
    add hl,de
    ld a,(hl)
    ld (T1),a
; if SCORE > T1:
    ld a,(SCORE)
    ld b,a
    ld a,(T1)
    ld c,a
    ld a,b
    cp c
    jp z,high_score_insertion_L8
    jp nc,high_score_insertion_L7
    jp high_score_insertion_L8
high_score_insertion_L7:
; break
    jp high_score_insertion_L6
    jp high_score_insertion_L9
high_score_insertion_L8:
high_score_insertion_L9:
; T0 = T0 + 1
    ld a,(T0)
    add a,1
    ld (T0),a
    jp high_score_insertion_L4
high_score_insertion_L6:
; if T0 >= 4:
    ld a,(T0)
    cp 4
    jp nc,high_score_insertion_L10
    jp high_score_insertion_L11
high_score_insertion_L10:
; return
    ret
    jp high_score_insertion_L12
high_score_insertion_L11:
high_score_insertion_L12:
; RANK = T0
    ld a,(T0)
    ld (RANK),a
; if COUNT < 4:
    ld a,(COUNT)
    cp 4
    jp c,high_score_insertion_L13
    jp high_score_insertion_L14
high_score_insertion_L13:
; COUNT = COUNT + 1
    ld a,(COUNT)
    add a,1
    ld (COUNT),a
    jp high_score_insertion_L15
high_score_insertion_L14:
high_score_insertion_L15:
; T1 = COUNT - 1
    ld a,(COUNT)
    sub 1
    ld (T1),a
; while T1 > T0:
high_score_insertion_L16:
    ld a,(T1)
    ld b,a
    ld a,(T0)
    ld c,a
    ld a,b
    cp c
    jp z,high_score_insertion_L18
    jp nc,high_score_insertion_L17
    jp high_score_insertion_L18
high_score_insertion_L17:
; T2 = T1 - 1
    ld a,(T1)
    sub 1
    ld (T2),a
; T3 = S[T2]
    ld a,(T2)
    ld e,a
    ld d,0
    ld hl,S0
    add hl,de
    ld a,(hl)
    ld (T3),a
; S[T1] = T3
    ld a,(T3)
    ld c,a
    ld a,(T1)
    ld e,a
    ld d,0
    ld hl,S0
    add hl,de
    ld (hl),c
; T3 = I[T2]
    ld a,(T2)
    ld e,a
    ld d,0
    ld hl,I0
    add hl,de
    ld a,(hl)
    ld (T3),a
; I[T1] = T3
    ld a,(T3)
    ld c,a
    ld a,(T1)
    ld e,a
    ld d,0
    ld hl,I0
    add hl,de
    ld (hl),c
; T1 = T1 - 1
    ld a,(T1)
    sub 1
    ld (T1),a
    jp high_score_insertion_L16
high_score_insertion_L18:
; S[T0] = SCORE
    ld a,(SCORE)
    ld c,a
    ld a,(T0)
    ld e,a
    ld d,0
    ld hl,S0
    add hl,de
    ld (hl),c
; I[T0] = TAG
    ld a,(TAG)
    ld c,a
    ld a,(T0)
    ld e,a
    ld d,0
    ld hl,I0
    add hl,de
    ld (hl),c
; INSERTED = 1
    ld a,1
    ld (INSERTED),a
    ret
component_end:
