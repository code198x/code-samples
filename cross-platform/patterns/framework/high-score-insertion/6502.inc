; SPDX-License-Identifier: MIT
; Insert into a High-score Table. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
high_score_insertion_init:
    lda #0
    sta RANK
    sta INSERTED
    sta VALID
    sta SCORE
    sta TAG
    sta COUNT
    sta S0
    sta S1
    sta S2
    sta S3
    sta I0
    sta I1
    sta I2
    sta I3
    sta T0
    sta T1
    sta T2
    sta T3
    sta EXPR_SAVE
    rts
high_score_insertion_step:
; RANK = 255
    lda #255
    sta RANK
; INSERTED = 0
    lda #0
    sta INSERTED
; VALID = 0
    lda #0
    sta VALID
; if COUNT > 4:
    lda COUNT
    cmp #4
    beq high_score_insertion_L5
    bcs high_score_insertion_L4
high_score_insertion_L5:
    jmp high_score_insertion_L2
high_score_insertion_L4:
    jmp high_score_insertion_L1
high_score_insertion_L1:
; return
    rts
    jmp high_score_insertion_L3
high_score_insertion_L2:
high_score_insertion_L3:
; VALID = 1
    lda #1
    sta VALID
; T0 = 0
    lda #0
    sta T0
; while T0 < COUNT:
high_score_insertion_L6:
    lda T0
    cmp COUNT
    bcc high_score_insertion_L9
high_score_insertion_L10:
    jmp high_score_insertion_L8
high_score_insertion_L9:
    jmp high_score_insertion_L7
high_score_insertion_L7:
; T1 = S[T0]
    ldx T0
    lda S0,x
    sta T1
; if SCORE > T1:
    lda SCORE
    cmp T1
    beq high_score_insertion_L15
    bcs high_score_insertion_L14
high_score_insertion_L15:
    jmp high_score_insertion_L12
high_score_insertion_L14:
    jmp high_score_insertion_L11
high_score_insertion_L11:
; break
    jmp high_score_insertion_L8
    jmp high_score_insertion_L13
high_score_insertion_L12:
high_score_insertion_L13:
; T0 = T0 + 1
    lda T0
    clc
    adc #1
    sta T0
    jmp high_score_insertion_L6
high_score_insertion_L8:
; if T0 >= 4:
    lda T0
    cmp #4
    bcs high_score_insertion_L19
high_score_insertion_L20:
    jmp high_score_insertion_L17
high_score_insertion_L19:
    jmp high_score_insertion_L16
high_score_insertion_L16:
; return
    rts
    jmp high_score_insertion_L18
high_score_insertion_L17:
high_score_insertion_L18:
; RANK = T0
    lda T0
    sta RANK
; if COUNT < 4:
    lda COUNT
    cmp #4
    bcc high_score_insertion_L24
high_score_insertion_L25:
    jmp high_score_insertion_L22
high_score_insertion_L24:
    jmp high_score_insertion_L21
high_score_insertion_L21:
; COUNT = COUNT + 1
    lda COUNT
    clc
    adc #1
    sta COUNT
    jmp high_score_insertion_L23
high_score_insertion_L22:
high_score_insertion_L23:
; T1 = COUNT - 1
    lda COUNT
    sec
    sbc #1
    sta T1
; while T1 > T0:
high_score_insertion_L26:
    lda T1
    cmp T0
    beq high_score_insertion_L30
    bcs high_score_insertion_L29
high_score_insertion_L30:
    jmp high_score_insertion_L28
high_score_insertion_L29:
    jmp high_score_insertion_L27
high_score_insertion_L27:
; T2 = T1 - 1
    lda T1
    sec
    sbc #1
    sta T2
; T3 = S[T2]
    ldx T2
    lda S0,x
    sta T3
; S[T1] = T3
    lda T3
    sta EXPR_SAVE
    ldx T1
    lda EXPR_SAVE
    sta S0,x
; T3 = I[T2]
    ldx T2
    lda I0,x
    sta T3
; I[T1] = T3
    lda T3
    sta EXPR_SAVE
    ldx T1
    lda EXPR_SAVE
    sta I0,x
; T1 = T1 - 1
    lda T1
    sec
    sbc #1
    sta T1
    jmp high_score_insertion_L26
high_score_insertion_L28:
; S[T0] = SCORE
    lda SCORE
    sta EXPR_SAVE
    ldx T0
    lda EXPR_SAVE
    sta S0,x
; I[T0] = TAG
    lda TAG
    sta EXPR_SAVE
    ldx T0
    lda EXPR_SAVE
    sta I0,x
; INSERTED = 1
    lda #1
    sta INSERTED
    rts
component_end:
