; SPDX-License-Identifier: MIT
; Trace a Thin Grid Line of Sight. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
grid_line_sight_init:
    lda #0
    sta VISIBLE
    sta VALID
    sta FROM
    sta TO
    sta C0
    sta C1
    sta C2
    sta C3
    sta C4
    sta C5
    sta C6
    sta C7
    sta C8
    sta C9
    sta C10
    sta C11
    sta C12
    sta C13
    sta C14
    sta C15
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
    sta T11
    rts
grid_line_sight_step:
; VISIBLE = 0
    lda #0
    sta VISIBLE
; VALID = 0
    lda #0
    sta VALID
; if FROM >= 16:
    lda FROM
    cmp #16
    bcs grid_line_sight_L4
grid_line_sight_L5:
    jmp grid_line_sight_L2
grid_line_sight_L4:
    jmp grid_line_sight_L1
grid_line_sight_L1:
; return
    rts
    jmp grid_line_sight_L3
grid_line_sight_L2:
grid_line_sight_L3:
; if TO >= 16:
    lda TO
    cmp #16
    bcs grid_line_sight_L9
grid_line_sight_L10:
    jmp grid_line_sight_L7
grid_line_sight_L9:
    jmp grid_line_sight_L6
grid_line_sight_L6:
; return
    rts
    jmp grid_line_sight_L8
grid_line_sight_L7:
grid_line_sight_L8:
; VALID = 1
    lda #1
    sta VALID
; T0 = FROM & 3
    lda FROM
    and #3
    sta T0
; T1 = FROM >> 2
    lda FROM
    lsr
    lsr
    sta T1
; T2 = TO & 3
    lda TO
    and #3
    sta T2
; T3 = TO >> 2
    lda TO
    lsr
    lsr
    sta T3
; T6 = 1
    lda #1
    sta T6
; if T2 >= T0:
    lda T2
    cmp T0
    bcs grid_line_sight_L14
grid_line_sight_L15:
    jmp grid_line_sight_L12
grid_line_sight_L14:
    jmp grid_line_sight_L11
grid_line_sight_L11:
; T4 = T2 - T0
    lda T2
    sec
    sbc T0
    sta T4
    jmp grid_line_sight_L13
grid_line_sight_L12:
; T4 = T0 - T2
    lda T0
    sec
    sbc T2
    sta T4
; T6 = 255
    lda #255
    sta T6
grid_line_sight_L13:
; T7 = 1
    lda #1
    sta T7
; if T3 >= T1:
    lda T3
    cmp T1
    bcs grid_line_sight_L19
grid_line_sight_L20:
    jmp grid_line_sight_L17
grid_line_sight_L19:
    jmp grid_line_sight_L16
grid_line_sight_L16:
; T5 = T3 - T1
    lda T3
    sec
    sbc T1
    sta T5
    jmp grid_line_sight_L18
grid_line_sight_L17:
; T5 = T1 - T3
    lda T1
    sec
    sbc T3
    sta T5
; T7 = 255
    lda #255
    sta T7
grid_line_sight_L18:
; T8 = 128 + T4
    lda #128
    clc
    adc T4
    sta T8
; T8 = T8 - T5
    lda T8
    sec
    sbc T5
    sta T8
; T9 = FROM
    lda FROM
    sta T9
; while T9 != TO:
grid_line_sight_L21:
    lda T9
    cmp TO
    bne grid_line_sight_L24
grid_line_sight_L25:
    jmp grid_line_sight_L23
grid_line_sight_L24:
    jmp grid_line_sight_L22
grid_line_sight_L22:
; T10 = T8 - 128
    lda T8
    sec
    sbc #128
    sta T10
; T10 = T10 << 1
    lda T10
    asl
    sta T10
; T10 = T10 + 128
    lda T10
    clc
    adc #128
    sta T10
; T11 = 128 - T5
    lda #128
    sec
    sbc T5
    sta T11
; if T10 > T11:
    lda T10
    cmp T11
    beq grid_line_sight_L30
    bcs grid_line_sight_L29
grid_line_sight_L30:
    jmp grid_line_sight_L27
grid_line_sight_L29:
    jmp grid_line_sight_L26
grid_line_sight_L26:
; T8 = T8 - T5
    lda T8
    sec
    sbc T5
    sta T8
; T0 = T0 + T6
    lda T0
    clc
    adc T6
    sta T0
    jmp grid_line_sight_L28
grid_line_sight_L27:
grid_line_sight_L28:
; T11 = 128 + T4
    lda #128
    clc
    adc T4
    sta T11
; if T10 < T11:
    lda T10
    cmp T11
    bcc grid_line_sight_L34
grid_line_sight_L35:
    jmp grid_line_sight_L32
grid_line_sight_L34:
    jmp grid_line_sight_L31
grid_line_sight_L31:
; T8 = T8 + T4
    lda T8
    clc
    adc T4
    sta T8
; T1 = T1 + T7
    lda T1
    clc
    adc T7
    sta T1
    jmp grid_line_sight_L33
grid_line_sight_L32:
grid_line_sight_L33:
; T9 = T1 << 2
    lda T1
    asl
    asl
    sta T9
; T9 = T9 + T0
    lda T9
    clc
    adc T0
    sta T9
; T11 = C[T9]
    ldx T9
    lda C0,x
    sta T11
; if T11 != 0:
    lda T11
    cmp #0
    bne grid_line_sight_L39
grid_line_sight_L40:
    jmp grid_line_sight_L37
grid_line_sight_L39:
    jmp grid_line_sight_L36
grid_line_sight_L36:
; return
    rts
    jmp grid_line_sight_L38
grid_line_sight_L37:
grid_line_sight_L38:
    jmp grid_line_sight_L21
grid_line_sight_L23:
; VISIBLE = 1
    lda #1
    sta VISIBLE
    rts
component_end:
