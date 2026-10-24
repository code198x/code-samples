; SPDX-License-Identifier: MIT
; Aim a Projectile with Bounded Integer Speed. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
aimed_projectile_init:
    lda #0
    sta VELOCITY_X
    sta VELOCITY_Y
    sta VALID
    sta ORIGIN_X
    sta ORIGIN_Y
    sta TARGET_X
    sta TARGET_Y
    sta SPEED
    sta T0
    sta T1
    sta T2
    sta T3
    sta T4
    sta T5
    sta T6
    sta T7
    sta T8
    sta T9
    sta T10
    rts
aimed_projectile_step:
; VELOCITY_X = 0
    lda #0
    sta VELOCITY_X
; VELOCITY_Y = 0
    lda #0
    sta VELOCITY_Y
; VALID = 0
    lda #0
    sta VALID
; if SPEED > 15:
    lda SPEED
    cmp #15
    beq aimed_projectile_L5
    bcs aimed_projectile_L4
aimed_projectile_L5:
    jmp aimed_projectile_L2
aimed_projectile_L4:
    jmp aimed_projectile_L1
aimed_projectile_L1:
; return
    rts
    jmp aimed_projectile_L3
aimed_projectile_L2:
aimed_projectile_L3:
; VALID = 1
    lda #1
    sta VALID
; if TARGET_X >= ORIGIN_X:
    lda TARGET_X
    cmp ORIGIN_X
    bcs aimed_projectile_L9
aimed_projectile_L10:
    jmp aimed_projectile_L7
aimed_projectile_L9:
    jmp aimed_projectile_L6
aimed_projectile_L6:
; T0 = TARGET_X - ORIGIN_X
    lda TARGET_X
    sec
    sbc ORIGIN_X
    sta T0
; T2 = 0
    lda #0
    sta T2
    jmp aimed_projectile_L8
aimed_projectile_L7:
; T0 = ORIGIN_X - TARGET_X
    lda ORIGIN_X
    sec
    sbc TARGET_X
    sta T0
; T2 = 1
    lda #1
    sta T2
aimed_projectile_L8:
; if TARGET_Y >= ORIGIN_Y:
    lda TARGET_Y
    cmp ORIGIN_Y
    bcs aimed_projectile_L14
aimed_projectile_L15:
    jmp aimed_projectile_L12
aimed_projectile_L14:
    jmp aimed_projectile_L11
aimed_projectile_L11:
; T1 = TARGET_Y - ORIGIN_Y
    lda TARGET_Y
    sec
    sbc ORIGIN_Y
    sta T1
; T3 = 0
    lda #0
    sta T3
    jmp aimed_projectile_L13
aimed_projectile_L12:
; T1 = ORIGIN_Y - TARGET_Y
    lda ORIGIN_Y
    sec
    sbc TARGET_Y
    sta T1
; T3 = 1
    lda #1
    sta T3
aimed_projectile_L13:
; T4 = T0
    lda T0
    sta T4
; if T1 > T4:
    lda T1
    cmp T4
    beq aimed_projectile_L20
    bcs aimed_projectile_L19
aimed_projectile_L20:
    jmp aimed_projectile_L17
aimed_projectile_L19:
    jmp aimed_projectile_L16
aimed_projectile_L16:
; T4 = T1
    lda T1
    sta T4
    jmp aimed_projectile_L18
aimed_projectile_L17:
aimed_projectile_L18:
; if T4 == 0:
    lda T4
    cmp #0
    beq aimed_projectile_L24
aimed_projectile_L25:
    jmp aimed_projectile_L22
aimed_projectile_L24:
    jmp aimed_projectile_L21
aimed_projectile_L21:
; return
    rts
    jmp aimed_projectile_L23
aimed_projectile_L22:
aimed_projectile_L23:
; T5 = 0
    lda #0
    sta T5
; T6 = 0
    lda #0
    sta T6
; T7 = 0
    lda #0
    sta T7
; T8 = 0
    lda #0
    sta T8
; T9 = 0
    lda #0
    sta T9
; while T5 < SPEED:
aimed_projectile_L26:
    lda T5
    cmp SPEED
    bcc aimed_projectile_L29
aimed_projectile_L30:
    jmp aimed_projectile_L28
aimed_projectile_L29:
    jmp aimed_projectile_L27
aimed_projectile_L27:
; T10 = T4 - T0
    lda T4
    sec
    sbc T0
    sta T10
; if T6 >= T10:
    lda T6
    cmp T10
    bcs aimed_projectile_L34
aimed_projectile_L35:
    jmp aimed_projectile_L32
aimed_projectile_L34:
    jmp aimed_projectile_L31
aimed_projectile_L31:
; T6 = T6 - T10
    lda T6
    sec
    sbc T10
    sta T6
; T7 = T7 + 1
    lda T7
    clc
    adc #1
    sta T7
    jmp aimed_projectile_L33
aimed_projectile_L32:
; T6 = T6 + T0
    lda T6
    clc
    adc T0
    sta T6
aimed_projectile_L33:
; T10 = T4 - T1
    lda T4
    sec
    sbc T1
    sta T10
; if T8 >= T10:
    lda T8
    cmp T10
    bcs aimed_projectile_L39
aimed_projectile_L40:
    jmp aimed_projectile_L37
aimed_projectile_L39:
    jmp aimed_projectile_L36
aimed_projectile_L36:
; T8 = T8 - T10
    lda T8
    sec
    sbc T10
    sta T8
; T9 = T9 + 1
    lda T9
    clc
    adc #1
    sta T9
    jmp aimed_projectile_L38
aimed_projectile_L37:
; T8 = T8 + T1
    lda T8
    clc
    adc T1
    sta T8
aimed_projectile_L38:
; T5 = T5 + 1
    lda T5
    clc
    adc #1
    sta T5
    jmp aimed_projectile_L26
aimed_projectile_L28:
; VELOCITY_X = T7
    lda T7
    sta VELOCITY_X
; VELOCITY_Y = T9
    lda T9
    sta VELOCITY_Y
; if T2 != 0:
    lda T2
    cmp #0
    bne aimed_projectile_L44
aimed_projectile_L45:
    jmp aimed_projectile_L42
aimed_projectile_L44:
    jmp aimed_projectile_L41
aimed_projectile_L41:
; VELOCITY_X = 0 - T7
    lda #0
    sec
    sbc T7
    sta VELOCITY_X
    jmp aimed_projectile_L43
aimed_projectile_L42:
aimed_projectile_L43:
; if T3 != 0:
    lda T3
    cmp #0
    bne aimed_projectile_L49
aimed_projectile_L50:
    jmp aimed_projectile_L47
aimed_projectile_L49:
    jmp aimed_projectile_L46
aimed_projectile_L46:
; VELOCITY_Y = 0 - T9
    lda #0
    sec
    sbc T9
    sta VELOCITY_Y
    jmp aimed_projectile_L48
aimed_projectile_L47:
aimed_projectile_L48:
    rts
component_end:
