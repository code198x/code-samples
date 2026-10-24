; SPDX-License-Identifier: MIT
; Mirror an Eight-bit Bitmap Row. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
bitmap_mirror_init:
    ld a,0
    ld (MIRRORED),a
    ld (ROW),a
    ld (T0),a
    ld (T1),a
    ld (T2),a
    ret
bitmap_mirror_step:
; MIRRORED = 0
    ld a,0
    ld (MIRRORED),a
; T0 = ROW
    ld a,(ROW)
    ld (T0),a
; T1 = 8
    ld a,8
    ld (T1),a
; while T1 != 0:
bitmap_mirror_L1:
    ld a,(T1)
    cp 0
    jp nz,bitmap_mirror_L2
    jp bitmap_mirror_L3
bitmap_mirror_L2:
; T2 = T0 & 1
    ld a,(T0)
    and 1
    ld (T2),a
; MIRRORED = MIRRORED << 1
    ld a,(MIRRORED)
    sla a
    ld (MIRRORED),a
; MIRRORED = MIRRORED | T2
    ld a,(MIRRORED)
    ld b,a
    ld a,(T2)
    ld c,a
    ld a,b
    or c
    ld (MIRRORED),a
; T0 = T0 >> 1
    ld a,(T0)
    srl a
    ld (T0),a
; T1 = T1 - 1
    ld a,(T1)
    sub 1
    ld (T1),a
    jp bitmap_mirror_L1
bitmap_mirror_L3:
    ret
component_end:
