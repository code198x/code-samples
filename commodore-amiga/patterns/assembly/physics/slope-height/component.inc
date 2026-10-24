; SPDX-License-Identifier: MIT
; Query a Small Slope Height Profile. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
slope_height_init:
    move.b #0,d0
    move.b d0,LOCAL_X
    move.b d0,BASE_Y
    move.b d0,MIRROR
    move.b d0,SURFACE
    move.b d0,VALID
    move.b d0,H0
    move.b d0,H1
    move.b d0,H2
    move.b d0,H3
    move.b d0,H4
    move.b d0,H5
    move.b d0,H6
    move.b d0,H7
    move.b d0,T0
    move.b d0,T1
    move.b d0,T2
    rts
slope_height_step:
; SURFACE = 255
    move.b #255,d0
    move.b d0,SURFACE
; VALID = 0
    move.b #0,d0
    move.b d0,VALID
; if LOCAL_X >= 8:
    move.b LOCAL_X,d0
    cmp.b #8,d0
    bcc slope_height_L1
    jmp slope_height_L2
slope_height_L1:
; return
    rts
    jmp slope_height_L3
slope_height_L2:
slope_height_L3:
; T0 = LOCAL_X
    move.b LOCAL_X,d0
    move.b d0,T0
; if MIRROR != 0:
    move.b MIRROR,d0
    cmp.b #0,d0
    bne slope_height_L4
    jmp slope_height_L5
slope_height_L4:
; T0 = 7 - T0
    move.b #7,d0
    move.b T0,d1
    sub.b d1,d0
    move.b d0,T0
    jmp slope_height_L6
slope_height_L5:
slope_height_L6:
; T1 = H[T0]
    moveq #0,d1
    move.b T0,d1
    lea H0,a0
    move.b 0(a0,d1.w),d0
    move.b d0,T1
; T2 = 255 - BASE_Y
    move.b #255,d0
    move.b BASE_Y,d1
    sub.b d1,d0
    move.b d0,T2
; if T1 > T2:
    move.b T1,d0
    move.b T2,d1
    cmp.b d1,d0
    bhi slope_height_L7
    jmp slope_height_L8
slope_height_L7:
; return
    rts
    jmp slope_height_L9
slope_height_L8:
slope_height_L9:
; SURFACE = BASE_Y + T1
    move.b BASE_Y,d0
    move.b T1,d1
    add.b d1,d0
    move.b d0,SURFACE
; VALID = 1
    move.b #1,d0
    move.b d0,VALID
    rts
component_end:
