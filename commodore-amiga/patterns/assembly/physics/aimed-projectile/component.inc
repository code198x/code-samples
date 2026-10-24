; SPDX-License-Identifier: MIT
; Aim a Projectile with Bounded Integer Speed. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
aimed_projectile_init:
    move.b #0,d0
    move.b d0,VELOCITY_X
    move.b d0,VELOCITY_Y
    move.b d0,VALID
    move.b d0,ORIGIN_X
    move.b d0,ORIGIN_Y
    move.b d0,TARGET_X
    move.b d0,TARGET_Y
    move.b d0,SPEED
    move.b d0,T0
    move.b d0,T1
    move.b d0,T2
    move.b d0,T3
    move.b d0,T4
    move.b d0,T5
    move.b d0,T6
    move.b d0,T7
    move.b d0,T8
    move.b d0,T9
    move.b d0,T10
    rts
aimed_projectile_step:
; VELOCITY_X = 0
    move.b #0,d0
    move.b d0,VELOCITY_X
; VELOCITY_Y = 0
    move.b #0,d0
    move.b d0,VELOCITY_Y
; VALID = 0
    move.b #0,d0
    move.b d0,VALID
; if SPEED > 15:
    move.b SPEED,d0
    cmp.b #15,d0
    bhi aimed_projectile_L1
    jmp aimed_projectile_L2
aimed_projectile_L1:
; return
    rts
    jmp aimed_projectile_L3
aimed_projectile_L2:
aimed_projectile_L3:
; VALID = 1
    move.b #1,d0
    move.b d0,VALID
; if TARGET_X >= ORIGIN_X:
    move.b TARGET_X,d0
    move.b ORIGIN_X,d1
    cmp.b d1,d0
    bcc aimed_projectile_L4
    jmp aimed_projectile_L5
aimed_projectile_L4:
; T0 = TARGET_X - ORIGIN_X
    move.b TARGET_X,d0
    move.b ORIGIN_X,d1
    sub.b d1,d0
    move.b d0,T0
; T2 = 0
    move.b #0,d0
    move.b d0,T2
    jmp aimed_projectile_L6
aimed_projectile_L5:
; T0 = ORIGIN_X - TARGET_X
    move.b ORIGIN_X,d0
    move.b TARGET_X,d1
    sub.b d1,d0
    move.b d0,T0
; T2 = 1
    move.b #1,d0
    move.b d0,T2
aimed_projectile_L6:
; if TARGET_Y >= ORIGIN_Y:
    move.b TARGET_Y,d0
    move.b ORIGIN_Y,d1
    cmp.b d1,d0
    bcc aimed_projectile_L7
    jmp aimed_projectile_L8
aimed_projectile_L7:
; T1 = TARGET_Y - ORIGIN_Y
    move.b TARGET_Y,d0
    move.b ORIGIN_Y,d1
    sub.b d1,d0
    move.b d0,T1
; T3 = 0
    move.b #0,d0
    move.b d0,T3
    jmp aimed_projectile_L9
aimed_projectile_L8:
; T1 = ORIGIN_Y - TARGET_Y
    move.b ORIGIN_Y,d0
    move.b TARGET_Y,d1
    sub.b d1,d0
    move.b d0,T1
; T3 = 1
    move.b #1,d0
    move.b d0,T3
aimed_projectile_L9:
; T4 = T0
    move.b T0,d0
    move.b d0,T4
; if T1 > T4:
    move.b T1,d0
    move.b T4,d1
    cmp.b d1,d0
    bhi aimed_projectile_L10
    jmp aimed_projectile_L11
aimed_projectile_L10:
; T4 = T1
    move.b T1,d0
    move.b d0,T4
    jmp aimed_projectile_L12
aimed_projectile_L11:
aimed_projectile_L12:
; if T4 == 0:
    move.b T4,d0
    cmp.b #0,d0
    beq aimed_projectile_L13
    jmp aimed_projectile_L14
aimed_projectile_L13:
; return
    rts
    jmp aimed_projectile_L15
aimed_projectile_L14:
aimed_projectile_L15:
; T5 = 0
    move.b #0,d0
    move.b d0,T5
; T6 = 0
    move.b #0,d0
    move.b d0,T6
; T7 = 0
    move.b #0,d0
    move.b d0,T7
; T8 = 0
    move.b #0,d0
    move.b d0,T8
; T9 = 0
    move.b #0,d0
    move.b d0,T9
; while T5 < SPEED:
aimed_projectile_L16:
    move.b T5,d0
    move.b SPEED,d1
    cmp.b d1,d0
    bcs aimed_projectile_L17
    jmp aimed_projectile_L18
aimed_projectile_L17:
; T10 = T4 - T0
    move.b T4,d0
    move.b T0,d1
    sub.b d1,d0
    move.b d0,T10
; if T6 >= T10:
    move.b T6,d0
    move.b T10,d1
    cmp.b d1,d0
    bcc aimed_projectile_L19
    jmp aimed_projectile_L20
aimed_projectile_L19:
; T6 = T6 - T10
    move.b T6,d0
    move.b T10,d1
    sub.b d1,d0
    move.b d0,T6
; T7 = T7 + 1
    move.b T7,d0
    add.b #1,d0
    move.b d0,T7
    jmp aimed_projectile_L21
aimed_projectile_L20:
; T6 = T6 + T0
    move.b T6,d0
    move.b T0,d1
    add.b d1,d0
    move.b d0,T6
aimed_projectile_L21:
; T10 = T4 - T1
    move.b T4,d0
    move.b T1,d1
    sub.b d1,d0
    move.b d0,T10
; if T8 >= T10:
    move.b T8,d0
    move.b T10,d1
    cmp.b d1,d0
    bcc aimed_projectile_L22
    jmp aimed_projectile_L23
aimed_projectile_L22:
; T8 = T8 - T10
    move.b T8,d0
    move.b T10,d1
    sub.b d1,d0
    move.b d0,T8
; T9 = T9 + 1
    move.b T9,d0
    add.b #1,d0
    move.b d0,T9
    jmp aimed_projectile_L24
aimed_projectile_L23:
; T8 = T8 + T1
    move.b T8,d0
    move.b T1,d1
    add.b d1,d0
    move.b d0,T8
aimed_projectile_L24:
; T5 = T5 + 1
    move.b T5,d0
    add.b #1,d0
    move.b d0,T5
    jmp aimed_projectile_L16
aimed_projectile_L18:
; VELOCITY_X = T7
    move.b T7,d0
    move.b d0,VELOCITY_X
; VELOCITY_Y = T9
    move.b T9,d0
    move.b d0,VELOCITY_Y
; if T2 != 0:
    move.b T2,d0
    cmp.b #0,d0
    bne aimed_projectile_L25
    jmp aimed_projectile_L26
aimed_projectile_L25:
; VELOCITY_X = 0 - T7
    move.b #0,d0
    move.b T7,d1
    sub.b d1,d0
    move.b d0,VELOCITY_X
    jmp aimed_projectile_L27
aimed_projectile_L26:
aimed_projectile_L27:
; if T3 != 0:
    move.b T3,d0
    cmp.b #0,d0
    bne aimed_projectile_L28
    jmp aimed_projectile_L29
aimed_projectile_L28:
; VELOCITY_Y = 0 - T9
    move.b #0,d0
    move.b T9,d1
    sub.b d1,d0
    move.b d0,VELOCITY_Y
    jmp aimed_projectile_L30
aimed_projectile_L29:
aimed_projectile_L30:
    rts
component_end:
