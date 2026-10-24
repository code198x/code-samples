; SPDX-License-Identifier: MIT
; Keep Camera Shake out of World State. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
camera_shake_init:
    move.b #0,d0
    move.b d0,OFFSET_X
    move.b d0,OFFSET_Y
    move.b d0,REMAINING
    move.b d0,AMPLITUDE
    move.b d0,VALID
    move.b d0,TRIGGER
    move.b d0,STRENGTH
    move.b d0,DURATION
    move.b d0,NOISE_X
    move.b d0,NOISE_Y
    move.b d0,T0
    move.b d0,T1
    rts
camera_shake_step:
; OFFSET_X = 0
    move.b #0,d0
    move.b d0,OFFSET_X
; OFFSET_Y = 0
    move.b #0,d0
    move.b d0,OFFSET_Y
; VALID = 0
    move.b #0,d0
    move.b d0,VALID
; if STRENGTH > 15:
    move.b STRENGTH,d0
    cmp.b #15,d0
    bhi camera_shake_L1
    jmp camera_shake_L2
camera_shake_L1:
; return
    rts
    jmp camera_shake_L3
camera_shake_L2:
camera_shake_L3:
; if TRIGGER == 0:
    move.b TRIGGER,d0
    cmp.b #0,d0
    beq camera_shake_L4
    jmp camera_shake_L5
camera_shake_L4:
; if AMPLITUDE > 15:
    move.b AMPLITUDE,d0
    cmp.b #15,d0
    bhi camera_shake_L7
    jmp camera_shake_L8
camera_shake_L7:
; return
    rts
    jmp camera_shake_L9
camera_shake_L8:
camera_shake_L9:
    jmp camera_shake_L6
camera_shake_L5:
camera_shake_L6:
; VALID = 1
    move.b #1,d0
    move.b d0,VALID
; if TRIGGER != 0:
    move.b TRIGGER,d0
    cmp.b #0,d0
    bne camera_shake_L10
    jmp camera_shake_L11
camera_shake_L10:
; AMPLITUDE = STRENGTH
    move.b STRENGTH,d0
    move.b d0,AMPLITUDE
; REMAINING = DURATION
    move.b DURATION,d0
    move.b d0,REMAINING
    jmp camera_shake_L12
camera_shake_L11:
camera_shake_L12:
; if REMAINING == 0:
    move.b REMAINING,d0
    cmp.b #0,d0
    beq camera_shake_L13
    jmp camera_shake_L14
camera_shake_L13:
; return
    rts
    jmp camera_shake_L15
camera_shake_L14:
camera_shake_L15:
; REMAINING = REMAINING - 1
    move.b REMAINING,d0
    sub.b #1,d0
    move.b d0,REMAINING
; if AMPLITUDE == 0:
    move.b AMPLITUDE,d0
    cmp.b #0,d0
    beq camera_shake_L16
    jmp camera_shake_L17
camera_shake_L16:
; return
    rts
    jmp camera_shake_L18
camera_shake_L17:
camera_shake_L18:
; T0 = AMPLITUDE << 1
    move.b AMPLITUDE,d0
    lsl.b #1,d0
    move.b d0,T0
; T0 = T0 + 1
    move.b T0,d0
    add.b #1,d0
    move.b d0,T0
; T1 = NOISE_X
    move.b NOISE_X,d0
    move.b d0,T1
; while T1 >= T0:
camera_shake_L19:
    move.b T1,d0
    move.b T0,d1
    cmp.b d1,d0
    bcc camera_shake_L20
    jmp camera_shake_L21
camera_shake_L20:
; T1 = T1 - T0
    move.b T1,d0
    move.b T0,d1
    sub.b d1,d0
    move.b d0,T1
    jmp camera_shake_L19
camera_shake_L21:
; OFFSET_X = T1 - AMPLITUDE
    move.b T1,d0
    move.b AMPLITUDE,d1
    sub.b d1,d0
    move.b d0,OFFSET_X
; T1 = NOISE_Y
    move.b NOISE_Y,d0
    move.b d0,T1
; while T1 >= T0:
camera_shake_L22:
    move.b T1,d0
    move.b T0,d1
    cmp.b d1,d0
    bcc camera_shake_L23
    jmp camera_shake_L24
camera_shake_L23:
; T1 = T1 - T0
    move.b T1,d0
    move.b T0,d1
    sub.b d1,d0
    move.b d0,T1
    jmp camera_shake_L22
camera_shake_L24:
; OFFSET_Y = T1 - AMPLITUDE
    move.b T1,d0
    move.b AMPLITUDE,d1
    sub.b d1,d0
    move.b d0,OFFSET_Y
    rts
component_end:
