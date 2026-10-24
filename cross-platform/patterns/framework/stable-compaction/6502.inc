; SPDX-License-Identifier: MIT
; Compact a Live Object Prefix. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
stable_compaction_init:
    lda #0
    sta COUNT
    sta REMOVED
    sta VALID
    sta F0
    sta F1
    sta F2
    sta F3
    sta F4
    sta F5
    sta F6
    sta F7
    sta I0
    sta I1
    sta I2
    sta I3
    sta I4
    sta I5
    sta I6
    sta I7
    sta T0
    sta T1
    sta T2
    sta T3
    sta T4
    sta EXPR_SAVE
    rts
stable_compaction_step:
; REMOVED = 0
    lda #0
    sta REMOVED
; VALID = 0
    lda #0
    sta VALID
; if COUNT > 8:
    lda COUNT
    cmp #8
    beq stable_compaction_L5
    bcs stable_compaction_L4
stable_compaction_L5:
    jmp stable_compaction_L2
stable_compaction_L4:
    jmp stable_compaction_L1
stable_compaction_L1:
; return
    rts
    jmp stable_compaction_L3
stable_compaction_L2:
stable_compaction_L3:
; VALID = 1
    lda #1
    sta VALID
; T0 = 0
    lda #0
    sta T0
; T1 = 0
    lda #0
    sta T1
; T4 = COUNT
    lda COUNT
    sta T4
; while T0 < T4:
stable_compaction_L6:
    lda T0
    cmp T4
    bcc stable_compaction_L9
stable_compaction_L10:
    jmp stable_compaction_L8
stable_compaction_L9:
    jmp stable_compaction_L7
stable_compaction_L7:
; T2 = F[T0]
    ldx T0
    lda F0,x
    sta T2
; if T2 != 0:
    lda T2
    cmp #0
    bne stable_compaction_L14
stable_compaction_L15:
    jmp stable_compaction_L12
stable_compaction_L14:
    jmp stable_compaction_L11
stable_compaction_L11:
; T3 = I[T0]
    ldx T0
    lda I0,x
    sta T3
; F[T1] = T2
    lda T2
    sta EXPR_SAVE
    ldx T1
    lda EXPR_SAVE
    sta F0,x
; I[T1] = T3
    lda T3
    sta EXPR_SAVE
    ldx T1
    lda EXPR_SAVE
    sta I0,x
; T1 = T1 + 1
    lda T1
    clc
    adc #1
    sta T1
    jmp stable_compaction_L13
stable_compaction_L12:
stable_compaction_L13:
; T0 = T0 + 1
    lda T0
    clc
    adc #1
    sta T0
    jmp stable_compaction_L6
stable_compaction_L8:
; COUNT = T1
    lda T1
    sta COUNT
; REMOVED = T4 - T1
    lda T4
    sec
    sbc T1
    sta REMOVED
; while T1 < T4:
stable_compaction_L16:
    lda T1
    cmp T4
    bcc stable_compaction_L19
stable_compaction_L20:
    jmp stable_compaction_L18
stable_compaction_L19:
    jmp stable_compaction_L17
stable_compaction_L17:
; F[T1] = 0
    lda #0
    sta EXPR_SAVE
    ldx T1
    lda EXPR_SAVE
    sta F0,x
; I[T1] = 0
    lda #0
    sta EXPR_SAVE
    ldx T1
    lda EXPR_SAVE
    sta I0,x
; T1 = T1 + 1
    lda T1
    clc
    adc #1
    sta T1
    jmp stable_compaction_L16
stable_compaction_L18:
    rts
component_end:
