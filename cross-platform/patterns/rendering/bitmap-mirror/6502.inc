; SPDX-License-Identifier: MIT
; Mirror an Eight-bit Bitmap Row. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
bitmap_mirror_init:
    lda #0
    sta MIRRORED
    sta ROW
    sta T0
    sta T1
    sta T2
    rts
bitmap_mirror_step:
; MIRRORED = 0
    lda #0
    sta MIRRORED
; T0 = ROW
    lda ROW
    sta T0
; T1 = 8
    lda #8
    sta T1
; while T1 != 0:
bitmap_mirror_L1:
    lda T1
    cmp #0
    bne bitmap_mirror_L4
bitmap_mirror_L5:
    jmp bitmap_mirror_L3
bitmap_mirror_L4:
    jmp bitmap_mirror_L2
bitmap_mirror_L2:
; T2 = T0 & 1
    lda T0
    and #1
    sta T2
; MIRRORED = MIRRORED << 1
    lda MIRRORED
    asl
    sta MIRRORED
; MIRRORED = MIRRORED | T2
    lda MIRRORED
    ora T2
    sta MIRRORED
; T0 = T0 >> 1
    lda T0
    lsr
    sta T0
; T1 = T1 - 1
    lda T1
    sec
    sbc #1
    sta T1
    jmp bitmap_mirror_L1
bitmap_mirror_L3:
    rts
component_end:
