; SPDX-License-Identifier: MIT
; Step Towards a Packed Colour. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
packed_colour_step_init:
    lda #0
    sta COLOUR
    sta TARGET
    sta T0
    sta T1
    sta T2
    sta T3
    sta T4
    sta T5
    rts
packed_colour_step_step:
; T0 = COLOUR >> 5
    lda COLOUR
    lsr
    lsr
    lsr
    lsr
    lsr
    sta T0
; T1 = TARGET >> 5
    lda TARGET
    lsr
    lsr
    lsr
    lsr
    lsr
    sta T1
; if T0 < T1:
    lda T0
    cmp T1
    bcc packed_colour_step_L4
packed_colour_step_L5:
    jmp packed_colour_step_L2
packed_colour_step_L4:
    jmp packed_colour_step_L1
packed_colour_step_L1:
; T0 = T0 + 1
    lda T0
    clc
    adc #1
    sta T0
    jmp packed_colour_step_L3
packed_colour_step_L2:
packed_colour_step_L3:
; if T0 > T1:
    lda T0
    cmp T1
    beq packed_colour_step_L10
    bcs packed_colour_step_L9
packed_colour_step_L10:
    jmp packed_colour_step_L7
packed_colour_step_L9:
    jmp packed_colour_step_L6
packed_colour_step_L6:
; T0 = T0 - 1
    lda T0
    sec
    sbc #1
    sta T0
    jmp packed_colour_step_L8
packed_colour_step_L7:
packed_colour_step_L8:
; T2 = COLOUR >> 2
    lda COLOUR
    lsr
    lsr
    sta T2
; T2 = T2 & 7
    lda T2
    and #7
    sta T2
; T3 = TARGET >> 2
    lda TARGET
    lsr
    lsr
    sta T3
; T3 = T3 & 7
    lda T3
    and #7
    sta T3
; if T2 < T3:
    lda T2
    cmp T3
    bcc packed_colour_step_L14
packed_colour_step_L15:
    jmp packed_colour_step_L12
packed_colour_step_L14:
    jmp packed_colour_step_L11
packed_colour_step_L11:
; T2 = T2 + 1
    lda T2
    clc
    adc #1
    sta T2
    jmp packed_colour_step_L13
packed_colour_step_L12:
packed_colour_step_L13:
; if T2 > T3:
    lda T2
    cmp T3
    beq packed_colour_step_L20
    bcs packed_colour_step_L19
packed_colour_step_L20:
    jmp packed_colour_step_L17
packed_colour_step_L19:
    jmp packed_colour_step_L16
packed_colour_step_L16:
; T2 = T2 - 1
    lda T2
    sec
    sbc #1
    sta T2
    jmp packed_colour_step_L18
packed_colour_step_L17:
packed_colour_step_L18:
; T4 = COLOUR & 3
    lda COLOUR
    and #3
    sta T4
; T5 = TARGET & 3
    lda TARGET
    and #3
    sta T5
; if T4 < T5:
    lda T4
    cmp T5
    bcc packed_colour_step_L24
packed_colour_step_L25:
    jmp packed_colour_step_L22
packed_colour_step_L24:
    jmp packed_colour_step_L21
packed_colour_step_L21:
; T4 = T4 + 1
    lda T4
    clc
    adc #1
    sta T4
    jmp packed_colour_step_L23
packed_colour_step_L22:
packed_colour_step_L23:
; if T4 > T5:
    lda T4
    cmp T5
    beq packed_colour_step_L30
    bcs packed_colour_step_L29
packed_colour_step_L30:
    jmp packed_colour_step_L27
packed_colour_step_L29:
    jmp packed_colour_step_L26
packed_colour_step_L26:
; T4 = T4 - 1
    lda T4
    sec
    sbc #1
    sta T4
    jmp packed_colour_step_L28
packed_colour_step_L27:
packed_colour_step_L28:
; COLOUR = T0 << 5
    lda T0
    asl
    asl
    asl
    asl
    asl
    sta COLOUR
; T2 = T2 << 2
    lda T2
    asl
    asl
    sta T2
; COLOUR = COLOUR | T2
    lda COLOUR
    ora T2
    sta COLOUR
; COLOUR = COLOUR | T4
    lda COLOUR
    ora T4
    sta COLOUR
    rts
component_end:
