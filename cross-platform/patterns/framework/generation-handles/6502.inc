; SPDX-License-Identifier: MIT
; Reject Stale Object Handles. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
generation_handles_init:
    lda #0
    sta RESULT
    sta OUT_SLOT
    sta OUT_GENERATION
    sta VALID
    sta MODE
    sta SLOT
    sta GENERATION
    sta ACTIVE
    sta G0
    sta G1
    sta G2
    sta G3
    sta T0
    sta T1
    sta T2
    sta EXPR_SAVE
    rts
generation_handles_step:
; RESULT = 0
    lda #0
    sta RESULT
; OUT_SLOT = 255
    lda #255
    sta OUT_SLOT
; OUT_GENERATION = 0
    lda #0
    sta OUT_GENERATION
; VALID = 0
    lda #0
    sta VALID
; if ACTIVE > 15:
    lda ACTIVE
    cmp #15
    beq generation_handles_L5
    bcs generation_handles_L4
generation_handles_L5:
    jmp generation_handles_L2
generation_handles_L4:
    jmp generation_handles_L1
generation_handles_L1:
; return
    rts
    jmp generation_handles_L3
generation_handles_L2:
generation_handles_L3:
; if MODE >= 3:
    lda MODE
    cmp #3
    bcs generation_handles_L9
generation_handles_L10:
    jmp generation_handles_L7
generation_handles_L9:
    jmp generation_handles_L6
generation_handles_L6:
; return
    rts
    jmp generation_handles_L8
generation_handles_L7:
generation_handles_L8:
; if MODE == 0:
    lda MODE
    cmp #0
    beq generation_handles_L14
generation_handles_L15:
    jmp generation_handles_L12
generation_handles_L14:
    jmp generation_handles_L11
generation_handles_L11:
; VALID = 1
    lda #1
    sta VALID
; T0 = 0
    lda #0
    sta T0
; T1 = 1
    lda #1
    sta T1
; while T0 < 4:
generation_handles_L16:
    lda T0
    cmp #4
    bcc generation_handles_L19
generation_handles_L20:
    jmp generation_handles_L18
generation_handles_L19:
    jmp generation_handles_L17
generation_handles_L17:
; T2 = ACTIVE & T1
    lda ACTIVE
    and T1
    sta T2
; if T2 == 0:
    lda T2
    cmp #0
    beq generation_handles_L24
generation_handles_L25:
    jmp generation_handles_L22
generation_handles_L24:
    jmp generation_handles_L21
generation_handles_L21:
; T2 = G[T0]
    ldx T0
    lda G0,x
    sta T2
; T2 = T2 + 1
    lda T2
    clc
    adc #1
    sta T2
; G[T0] = T2
    lda T2
    sta EXPR_SAVE
    ldx T0
    lda EXPR_SAVE
    sta G0,x
; ACTIVE = ACTIVE | T1
    lda ACTIVE
    ora T1
    sta ACTIVE
; OUT_SLOT = T0
    lda T0
    sta OUT_SLOT
; OUT_GENERATION = T2
    lda T2
    sta OUT_GENERATION
; RESULT = 1
    lda #1
    sta RESULT
; return
    rts
    jmp generation_handles_L23
generation_handles_L22:
generation_handles_L23:
; T0 = T0 + 1
    lda T0
    clc
    adc #1
    sta T0
; T1 = T1 << 1
    lda T1
    asl
    sta T1
    jmp generation_handles_L16
generation_handles_L18:
; return
    rts
    jmp generation_handles_L13
generation_handles_L12:
generation_handles_L13:
; if SLOT >= 4:
    lda SLOT
    cmp #4
    bcs generation_handles_L29
generation_handles_L30:
    jmp generation_handles_L27
generation_handles_L29:
    jmp generation_handles_L26
generation_handles_L26:
; return
    rts
    jmp generation_handles_L28
generation_handles_L27:
generation_handles_L28:
; VALID = 1
    lda #1
    sta VALID
; T0 = 1
    lda #1
    sta T0
; T1 = SLOT
    lda SLOT
    sta T1
; while T1 != 0:
generation_handles_L31:
    lda T1
    cmp #0
    bne generation_handles_L34
generation_handles_L35:
    jmp generation_handles_L33
generation_handles_L34:
    jmp generation_handles_L32
generation_handles_L32:
; T0 = T0 << 1
    lda T0
    asl
    sta T0
; T1 = T1 - 1
    lda T1
    sec
    sbc #1
    sta T1
    jmp generation_handles_L31
generation_handles_L33:
; T1 = ACTIVE & T0
    lda ACTIVE
    and T0
    sta T1
; if T1 == 0:
    lda T1
    cmp #0
    beq generation_handles_L39
generation_handles_L40:
    jmp generation_handles_L37
generation_handles_L39:
    jmp generation_handles_L36
generation_handles_L36:
; return
    rts
    jmp generation_handles_L38
generation_handles_L37:
generation_handles_L38:
; T1 = G[SLOT]
    ldx SLOT
    lda G0,x
    sta T1
; if T1 != GENERATION:
    lda T1
    cmp GENERATION
    bne generation_handles_L44
generation_handles_L45:
    jmp generation_handles_L42
generation_handles_L44:
    jmp generation_handles_L41
generation_handles_L41:
; return
    rts
    jmp generation_handles_L43
generation_handles_L42:
generation_handles_L43:
; OUT_SLOT = SLOT
    lda SLOT
    sta OUT_SLOT
; OUT_GENERATION = T1
    lda T1
    sta OUT_GENERATION
; RESULT = 1
    lda #1
    sta RESULT
; if MODE == 1:
    lda MODE
    cmp #1
    beq generation_handles_L49
generation_handles_L50:
    jmp generation_handles_L47
generation_handles_L49:
    jmp generation_handles_L46
generation_handles_L46:
; T0 = T0 ^ 255
    lda T0
    eor #255
    sta T0
; ACTIVE = ACTIVE & T0
    lda ACTIVE
    and T0
    sta ACTIVE
    jmp generation_handles_L48
generation_handles_L47:
generation_handles_L48:
    rts
component_end:
