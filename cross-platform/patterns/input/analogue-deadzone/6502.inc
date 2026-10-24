; SPDX-License-Identifier: MIT
; Turn an Analogue Axis into Intent. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
analogue_deadzone_init:
    lda #0
    sta SAMPLE
    sta CENTRE
    sta RADIUS
    sta DIRECTION
    sta MAGNITUDE
    sta VALID
    sta T0
    rts
analogue_deadzone_step:
; DIRECTION = 0
    lda #0
    sta DIRECTION
; MAGNITUDE = 0
    lda #0
    sta MAGNITUDE
; VALID = 0
    lda #0
    sta VALID
; if RADIUS >= 128:
    lda RADIUS
    cmp #128
    bcs analogue_deadzone_L4
analogue_deadzone_L5:
    jmp analogue_deadzone_L2
analogue_deadzone_L4:
    jmp analogue_deadzone_L1
analogue_deadzone_L1:
; return
    rts
    jmp analogue_deadzone_L3
analogue_deadzone_L2:
analogue_deadzone_L3:
; VALID = 1
    lda #1
    sta VALID
; if SAMPLE >= CENTRE:
    lda SAMPLE
    cmp CENTRE
    bcs analogue_deadzone_L9
analogue_deadzone_L10:
    jmp analogue_deadzone_L7
analogue_deadzone_L9:
    jmp analogue_deadzone_L6
analogue_deadzone_L6:
; T0 = SAMPLE - CENTRE
    lda SAMPLE
    sec
    sbc CENTRE
    sta T0
; if T0 > RADIUS:
    lda T0
    cmp RADIUS
    beq analogue_deadzone_L15
    bcs analogue_deadzone_L14
analogue_deadzone_L15:
    jmp analogue_deadzone_L12
analogue_deadzone_L14:
    jmp analogue_deadzone_L11
analogue_deadzone_L11:
; MAGNITUDE = T0 - RADIUS
    lda T0
    sec
    sbc RADIUS
    sta MAGNITUDE
; DIRECTION = 2
    lda #2
    sta DIRECTION
    jmp analogue_deadzone_L13
analogue_deadzone_L12:
analogue_deadzone_L13:
    jmp analogue_deadzone_L8
analogue_deadzone_L7:
; T0 = CENTRE - SAMPLE
    lda CENTRE
    sec
    sbc SAMPLE
    sta T0
; if T0 > RADIUS:
    lda T0
    cmp RADIUS
    beq analogue_deadzone_L20
    bcs analogue_deadzone_L19
analogue_deadzone_L20:
    jmp analogue_deadzone_L17
analogue_deadzone_L19:
    jmp analogue_deadzone_L16
analogue_deadzone_L16:
; MAGNITUDE = T0 - RADIUS
    lda T0
    sec
    sbc RADIUS
    sta MAGNITUDE
; DIRECTION = 1
    lda #1
    sta DIRECTION
    jmp analogue_deadzone_L18
analogue_deadzone_L17:
analogue_deadzone_L18:
analogue_deadzone_L8:
    rts
component_end:
