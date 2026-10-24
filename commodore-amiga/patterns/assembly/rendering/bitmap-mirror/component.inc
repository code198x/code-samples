; SPDX-License-Identifier: MIT
; Mirror an Eight-bit Bitmap Row. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
bitmap_mirror_init:
    move.b #0,d0
    move.b d0,MIRRORED
    move.b d0,ROW
    move.b d0,T0
    move.b d0,T1
    move.b d0,T2
    rts
bitmap_mirror_step:
; MIRRORED = 0
    move.b #0,d0
    move.b d0,MIRRORED
; T0 = ROW
    move.b ROW,d0
    move.b d0,T0
; T1 = 8
    move.b #8,d0
    move.b d0,T1
; while T1 != 0:
bitmap_mirror_L1:
    move.b T1,d0
    cmp.b #0,d0
    bne bitmap_mirror_L2
    jmp bitmap_mirror_L3
bitmap_mirror_L2:
; T2 = T0 & 1
    move.b T0,d0
    and.b #1,d0
    move.b d0,T2
; MIRRORED = MIRRORED << 1
    move.b MIRRORED,d0
    lsl.b #1,d0
    move.b d0,MIRRORED
; MIRRORED = MIRRORED | T2
    move.b MIRRORED,d0
    move.b T2,d1
    or.b d1,d0
    move.b d0,MIRRORED
; T0 = T0 >> 1
    move.b T0,d0
    lsr.b #1,d0
    move.b d0,T0
; T1 = T1 - 1
    move.b T1,d0
    sub.b #1,d0
    move.b d0,T1
    jmp bitmap_mirror_L1
bitmap_mirror_L3:
    rts
component_end:
