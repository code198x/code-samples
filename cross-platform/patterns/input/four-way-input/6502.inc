; SPDX-License-Identifier: MIT
; Resolve Input to Four Directions. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
four_way_input_init:
    lda #0
    sta HELD
    sta LAST_AXIS
    sta DIRECTION
    sta VALID
    sta T0
    sta T1
    sta T2
    rts
four_way_input_step:
; DIRECTION = 0
    lda #0
    sta DIRECTION
; VALID = 0
    lda #0
    sta VALID
; if LAST_AXIS >= 2:
    lda LAST_AXIS
    cmp #2
    bcs four_way_input_L4
four_way_input_L5:
    jmp four_way_input_L2
four_way_input_L4:
    jmp four_way_input_L1
four_way_input_L1:
; return
    rts
    jmp four_way_input_L3
four_way_input_L2:
four_way_input_L3:
; VALID = 1
    lda #1
    sta VALID
; T0 = HELD & 3
    lda HELD
    and #3
    sta T0
; T1 = 0
    lda #0
    sta T1
; if T0 == 1:
    lda T0
    cmp #1
    beq four_way_input_L9
four_way_input_L10:
    jmp four_way_input_L7
four_way_input_L9:
    jmp four_way_input_L6
four_way_input_L6:
; T1 = 1
    lda #1
    sta T1
    jmp four_way_input_L8
four_way_input_L7:
four_way_input_L8:
; if T0 == 2:
    lda T0
    cmp #2
    beq four_way_input_L14
four_way_input_L15:
    jmp four_way_input_L12
four_way_input_L14:
    jmp four_way_input_L11
four_way_input_L11:
; T1 = 2
    lda #2
    sta T1
    jmp four_way_input_L13
four_way_input_L12:
four_way_input_L13:
; T0 = HELD & 12
    lda HELD
    and #12
    sta T0
; T2 = 0
    lda #0
    sta T2
; if T0 == 4:
    lda T0
    cmp #4
    beq four_way_input_L19
four_way_input_L20:
    jmp four_way_input_L17
four_way_input_L19:
    jmp four_way_input_L16
four_way_input_L16:
; T2 = 3
    lda #3
    sta T2
    jmp four_way_input_L18
four_way_input_L17:
four_way_input_L18:
; if T0 == 8:
    lda T0
    cmp #8
    beq four_way_input_L24
four_way_input_L25:
    jmp four_way_input_L22
four_way_input_L24:
    jmp four_way_input_L21
four_way_input_L21:
; T2 = 4
    lda #4
    sta T2
    jmp four_way_input_L23
four_way_input_L22:
four_way_input_L23:
; if T1 != 0:
    lda T1
    cmp #0
    bne four_way_input_L29
four_way_input_L30:
    jmp four_way_input_L27
four_way_input_L29:
    jmp four_way_input_L26
four_way_input_L26:
; if T2 != 0:
    lda T2
    cmp #0
    bne four_way_input_L34
four_way_input_L35:
    jmp four_way_input_L32
four_way_input_L34:
    jmp four_way_input_L31
four_way_input_L31:
; if LAST_AXIS == 1:
    lda LAST_AXIS
    cmp #1
    beq four_way_input_L39
four_way_input_L40:
    jmp four_way_input_L37
four_way_input_L39:
    jmp four_way_input_L36
four_way_input_L36:
; DIRECTION = T2
    lda T2
    sta DIRECTION
; return
    rts
    jmp four_way_input_L38
four_way_input_L37:
four_way_input_L38:
    jmp four_way_input_L33
four_way_input_L32:
four_way_input_L33:
; DIRECTION = T1
    lda T1
    sta DIRECTION
; LAST_AXIS = 0
    lda #0
    sta LAST_AXIS
; return
    rts
    jmp four_way_input_L28
four_way_input_L27:
four_way_input_L28:
; if T2 != 0:
    lda T2
    cmp #0
    bne four_way_input_L44
four_way_input_L45:
    jmp four_way_input_L42
four_way_input_L44:
    jmp four_way_input_L41
four_way_input_L41:
; DIRECTION = T2
    lda T2
    sta DIRECTION
; LAST_AXIS = 1
    lda #1
    sta LAST_AXIS
    jmp four_way_input_L43
four_way_input_L42:
four_way_input_L43:
    rts
component_end:
