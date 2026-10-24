; SPDX-License-Identifier: MIT
; Test Sight Along a Grid Row or Column. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
cardinal_sight_init:
    lda #0
    sta FROM
    sta TO
    sta VISIBLE
    sta VALID
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
    rts
cardinal_sight_step:
; VISIBLE = 0
    lda #0
    sta VISIBLE
; VALID = 0
    lda #0
    sta VALID
; if FROM >= 16:
    lda FROM
    cmp #16
    bcs cardinal_sight_L4
cardinal_sight_L5:
    jmp cardinal_sight_L2
cardinal_sight_L4:
    jmp cardinal_sight_L1
cardinal_sight_L1:
; return
    rts
    jmp cardinal_sight_L3
cardinal_sight_L2:
cardinal_sight_L3:
; if TO >= 16:
    lda TO
    cmp #16
    bcs cardinal_sight_L9
cardinal_sight_L10:
    jmp cardinal_sight_L7
cardinal_sight_L9:
    jmp cardinal_sight_L6
cardinal_sight_L6:
; return
    rts
    jmp cardinal_sight_L8
cardinal_sight_L7:
cardinal_sight_L8:
; if FROM == TO:
    lda FROM
    cmp TO
    beq cardinal_sight_L14
cardinal_sight_L15:
    jmp cardinal_sight_L12
cardinal_sight_L14:
    jmp cardinal_sight_L11
cardinal_sight_L11:
; VALID = 1
    lda #1
    sta VALID
; VISIBLE = 1
    lda #1
    sta VISIBLE
; return
    rts
    jmp cardinal_sight_L13
cardinal_sight_L12:
cardinal_sight_L13:
; T0 = FROM >> 2
    lda FROM
    lsr
    lsr
    sta T0
; T1 = TO >> 2
    lda TO
    lsr
    lsr
    sta T1
; T2 = 1
    lda #1
    sta T2
; if T0 != T1:
    lda T0
    cmp T1
    bne cardinal_sight_L19
cardinal_sight_L20:
    jmp cardinal_sight_L17
cardinal_sight_L19:
    jmp cardinal_sight_L16
cardinal_sight_L16:
; T0 = FROM & 3
    lda FROM
    and #3
    sta T0
; T1 = TO & 3
    lda TO
    and #3
    sta T1
; if T0 != T1:
    lda T0
    cmp T1
    bne cardinal_sight_L24
cardinal_sight_L25:
    jmp cardinal_sight_L22
cardinal_sight_L24:
    jmp cardinal_sight_L21
cardinal_sight_L21:
; return
    rts
    jmp cardinal_sight_L23
cardinal_sight_L22:
cardinal_sight_L23:
; T2 = 4
    lda #4
    sta T2
    jmp cardinal_sight_L18
cardinal_sight_L17:
cardinal_sight_L18:
; VALID = 1
    lda #1
    sta VALID
; T0 = FROM
    lda FROM
    sta T0
; while T0 != TO:
cardinal_sight_L26:
    lda T0
    cmp TO
    bne cardinal_sight_L29
cardinal_sight_L30:
    jmp cardinal_sight_L28
cardinal_sight_L29:
    jmp cardinal_sight_L27
cardinal_sight_L27:
; if T0 < TO:
    lda T0
    cmp TO
    bcc cardinal_sight_L34
cardinal_sight_L35:
    jmp cardinal_sight_L32
cardinal_sight_L34:
    jmp cardinal_sight_L31
cardinal_sight_L31:
; T0 = T0 + T2
    lda T0
    clc
    adc T2
    sta T0
    jmp cardinal_sight_L33
cardinal_sight_L32:
; T0 = T0 - T2
    lda T0
    sec
    sbc T2
    sta T0
cardinal_sight_L33:
; T1 = C[T0]
    ldx T0
    lda C0,x
    sta T1
; if T1 != 0:
    lda T1
    cmp #0
    bne cardinal_sight_L39
cardinal_sight_L40:
    jmp cardinal_sight_L37
cardinal_sight_L39:
    jmp cardinal_sight_L36
cardinal_sight_L36:
; return
    rts
    jmp cardinal_sight_L38
cardinal_sight_L37:
cardinal_sight_L38:
    jmp cardinal_sight_L26
cardinal_sight_L28:
; VISIBLE = 1
    lda #1
    sta VISIBLE
    rts
component_end:
