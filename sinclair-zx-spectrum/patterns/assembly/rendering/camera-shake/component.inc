; SPDX-License-Identifier: MIT
; Keep Camera Shake out of World State. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
camera_shake_init:
    ld a,0
    ld (OFFSET_X),a
    ld (OFFSET_Y),a
    ld (REMAINING),a
    ld (AMPLITUDE),a
    ld (VALID),a
    ld (TRIGGER),a
    ld (STRENGTH),a
    ld (DURATION),a
    ld (NOISE_X),a
    ld (NOISE_Y),a
    ld (T0),a
    ld (T1),a
    ret
camera_shake_step:
; OFFSET_X = 0
    ld a,0
    ld (OFFSET_X),a
; OFFSET_Y = 0
    ld a,0
    ld (OFFSET_Y),a
; VALID = 0
    ld a,0
    ld (VALID),a
; if STRENGTH > 15:
    ld a,(STRENGTH)
    cp 15
    jp z,camera_shake_L2
    jp nc,camera_shake_L1
    jp camera_shake_L2
camera_shake_L1:
; return
    ret
    jp camera_shake_L3
camera_shake_L2:
camera_shake_L3:
; if TRIGGER == 0:
    ld a,(TRIGGER)
    cp 0
    jp z,camera_shake_L4
    jp camera_shake_L5
camera_shake_L4:
; if AMPLITUDE > 15:
    ld a,(AMPLITUDE)
    cp 15
    jp z,camera_shake_L8
    jp nc,camera_shake_L7
    jp camera_shake_L8
camera_shake_L7:
; return
    ret
    jp camera_shake_L9
camera_shake_L8:
camera_shake_L9:
    jp camera_shake_L6
camera_shake_L5:
camera_shake_L6:
; VALID = 1
    ld a,1
    ld (VALID),a
; if TRIGGER != 0:
    ld a,(TRIGGER)
    cp 0
    jp nz,camera_shake_L10
    jp camera_shake_L11
camera_shake_L10:
; AMPLITUDE = STRENGTH
    ld a,(STRENGTH)
    ld (AMPLITUDE),a
; REMAINING = DURATION
    ld a,(DURATION)
    ld (REMAINING),a
    jp camera_shake_L12
camera_shake_L11:
camera_shake_L12:
; if REMAINING == 0:
    ld a,(REMAINING)
    cp 0
    jp z,camera_shake_L13
    jp camera_shake_L14
camera_shake_L13:
; return
    ret
    jp camera_shake_L15
camera_shake_L14:
camera_shake_L15:
; REMAINING = REMAINING - 1
    ld a,(REMAINING)
    sub 1
    ld (REMAINING),a
; if AMPLITUDE == 0:
    ld a,(AMPLITUDE)
    cp 0
    jp z,camera_shake_L16
    jp camera_shake_L17
camera_shake_L16:
; return
    ret
    jp camera_shake_L18
camera_shake_L17:
camera_shake_L18:
; T0 = AMPLITUDE << 1
    ld a,(AMPLITUDE)
    sla a
    ld (T0),a
; T0 = T0 + 1
    ld a,(T0)
    add a,1
    ld (T0),a
; T1 = NOISE_X
    ld a,(NOISE_X)
    ld (T1),a
; while T1 >= T0:
camera_shake_L19:
    ld a,(T1)
    ld b,a
    ld a,(T0)
    ld c,a
    ld a,b
    cp c
    jp nc,camera_shake_L20
    jp camera_shake_L21
camera_shake_L20:
; T1 = T1 - T0
    ld a,(T1)
    ld b,a
    ld a,(T0)
    ld c,a
    ld a,b
    sub c
    ld (T1),a
    jp camera_shake_L19
camera_shake_L21:
; OFFSET_X = T1 - AMPLITUDE
    ld a,(T1)
    ld b,a
    ld a,(AMPLITUDE)
    ld c,a
    ld a,b
    sub c
    ld (OFFSET_X),a
; T1 = NOISE_Y
    ld a,(NOISE_Y)
    ld (T1),a
; while T1 >= T0:
camera_shake_L22:
    ld a,(T1)
    ld b,a
    ld a,(T0)
    ld c,a
    ld a,b
    cp c
    jp nc,camera_shake_L23
    jp camera_shake_L24
camera_shake_L23:
; T1 = T1 - T0
    ld a,(T1)
    ld b,a
    ld a,(T0)
    ld c,a
    ld a,b
    sub c
    ld (T1),a
    jp camera_shake_L22
camera_shake_L24:
; OFFSET_Y = T1 - AMPLITUDE
    ld a,(T1)
    ld b,a
    ld a,(AMPLITUDE)
    ld c,a
    ld a,b
    sub c
    ld (OFFSET_Y),a
    ret
component_end:
