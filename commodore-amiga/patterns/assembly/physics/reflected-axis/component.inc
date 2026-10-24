; SPDX-License-Identifier: MIT
; Reflect Movement at Axis Bounds. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
reflected_axis_init:
    move.b #0,d0
    move.b d0,POSITION
    move.b d0,MINIMUM
    move.b d0,MAXIMUM
    move.b d0,DISTANCE
    move.b d0,DIRECTION
    move.b d0,BOUNCES
    move.b d0,VALID
    move.b d0,T0
    rts
reflected_axis_step:
; BOUNCES = 0
    move.b #0,d0
    move.b d0,BOUNCES
; VALID = 0
    move.b #0,d0
    move.b d0,VALID
; if MINIMUM >= MAXIMUM:
    move.b MINIMUM,d0
    move.b MAXIMUM,d1
    cmp.b d1,d0
    bcc reflected_axis_L1
    jmp reflected_axis_L2
reflected_axis_L1:
; return
    rts
    jmp reflected_axis_L3
reflected_axis_L2:
reflected_axis_L3:
; if POSITION < MINIMUM:
    move.b POSITION,d0
    move.b MINIMUM,d1
    cmp.b d1,d0
    bcs reflected_axis_L4
    jmp reflected_axis_L5
reflected_axis_L4:
; return
    rts
    jmp reflected_axis_L6
reflected_axis_L5:
reflected_axis_L6:
; if POSITION > MAXIMUM:
    move.b POSITION,d0
    move.b MAXIMUM,d1
    cmp.b d1,d0
    bhi reflected_axis_L7
    jmp reflected_axis_L8
reflected_axis_L7:
; return
    rts
    jmp reflected_axis_L9
reflected_axis_L8:
reflected_axis_L9:
; if DIRECTION >= 2:
    move.b DIRECTION,d0
    cmp.b #2,d0
    bcc reflected_axis_L10
    jmp reflected_axis_L11
reflected_axis_L10:
; return
    rts
    jmp reflected_axis_L12
reflected_axis_L11:
reflected_axis_L12:
; VALID = 1
    move.b #1,d0
    move.b d0,VALID
; T0 = DISTANCE
    move.b DISTANCE,d0
    move.b d0,T0
; while T0 != 0:
reflected_axis_L13:
    move.b T0,d0
    cmp.b #0,d0
    bne reflected_axis_L14
    jmp reflected_axis_L15
reflected_axis_L14:
; if DIRECTION == 0:
    move.b DIRECTION,d0
    cmp.b #0,d0
    beq reflected_axis_L16
    jmp reflected_axis_L17
reflected_axis_L16:
; if POSITION == MINIMUM:
    move.b POSITION,d0
    move.b MINIMUM,d1
    cmp.b d1,d0
    beq reflected_axis_L19
    jmp reflected_axis_L20
reflected_axis_L19:
; DIRECTION = 1
    move.b #1,d0
    move.b d0,DIRECTION
; BOUNCES = BOUNCES + 1
    move.b BOUNCES,d0
    add.b #1,d0
    move.b d0,BOUNCES
    jmp reflected_axis_L21
reflected_axis_L20:
reflected_axis_L21:
    jmp reflected_axis_L18
reflected_axis_L17:
; if POSITION == MAXIMUM:
    move.b POSITION,d0
    move.b MAXIMUM,d1
    cmp.b d1,d0
    beq reflected_axis_L22
    jmp reflected_axis_L23
reflected_axis_L22:
; DIRECTION = 0
    move.b #0,d0
    move.b d0,DIRECTION
; BOUNCES = BOUNCES + 1
    move.b BOUNCES,d0
    add.b #1,d0
    move.b d0,BOUNCES
    jmp reflected_axis_L24
reflected_axis_L23:
reflected_axis_L24:
reflected_axis_L18:
; if DIRECTION == 0:
    move.b DIRECTION,d0
    cmp.b #0,d0
    beq reflected_axis_L25
    jmp reflected_axis_L26
reflected_axis_L25:
; POSITION = POSITION - 1
    move.b POSITION,d0
    sub.b #1,d0
    move.b d0,POSITION
    jmp reflected_axis_L27
reflected_axis_L26:
; POSITION = POSITION + 1
    move.b POSITION,d0
    add.b #1,d0
    move.b d0,POSITION
reflected_axis_L27:
; T0 = T0 - 1
    move.b T0,d0
    sub.b #1,d0
    move.b d0,T0
    jmp reflected_axis_L13
reflected_axis_L15:
    rts
component_end:
