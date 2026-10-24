; SPDX-License-Identifier: MIT
; Keep a Stable Priority Event Queue. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
priority_event_queue_init:
    lda #0
    sta EVENT
    sta PRIORITY
    sta RESULT
    sta VALID
    sta COUNT
    sta MODE
    sta NEW_EVENT
    sta NEW_PRIORITY
    sta E0
    sta E1
    sta E2
    sta E3
    sta P0
    sta P1
    sta P2
    sta P3
    sta T0
    sta T1
    sta T2
    sta EXPR_SAVE
    rts
priority_event_queue_step:
; EVENT = 255
    lda #255
    sta EVENT
; PRIORITY = 0
    lda #0
    sta PRIORITY
; RESULT = 0
    lda #0
    sta RESULT
; VALID = 0
    lda #0
    sta VALID
; if COUNT > 4:
    lda COUNT
    cmp #4
    beq priority_event_queue_L5
    bcs priority_event_queue_L4
priority_event_queue_L5:
    jmp priority_event_queue_L2
priority_event_queue_L4:
    jmp priority_event_queue_L1
priority_event_queue_L1:
; return
    rts
    jmp priority_event_queue_L3
priority_event_queue_L2:
priority_event_queue_L3:
; if MODE > 1:
    lda MODE
    cmp #1
    beq priority_event_queue_L10
    bcs priority_event_queue_L9
priority_event_queue_L10:
    jmp priority_event_queue_L7
priority_event_queue_L9:
    jmp priority_event_queue_L6
priority_event_queue_L6:
; return
    rts
    jmp priority_event_queue_L8
priority_event_queue_L7:
priority_event_queue_L8:
; VALID = 1
    lda #1
    sta VALID
; if MODE == 0:
    lda MODE
    cmp #0
    beq priority_event_queue_L14
priority_event_queue_L15:
    jmp priority_event_queue_L12
priority_event_queue_L14:
    jmp priority_event_queue_L11
priority_event_queue_L11:
; if COUNT == 4:
    lda COUNT
    cmp #4
    beq priority_event_queue_L19
priority_event_queue_L20:
    jmp priority_event_queue_L17
priority_event_queue_L19:
    jmp priority_event_queue_L16
priority_event_queue_L16:
; return
    rts
    jmp priority_event_queue_L18
priority_event_queue_L17:
priority_event_queue_L18:
; T0 = COUNT
    lda COUNT
    sta T0
; while T0 != 0:
priority_event_queue_L21:
    lda T0
    cmp #0
    bne priority_event_queue_L24
priority_event_queue_L25:
    jmp priority_event_queue_L23
priority_event_queue_L24:
    jmp priority_event_queue_L22
priority_event_queue_L22:
; T1 = T0 - 1
    lda T0
    sec
    sbc #1
    sta T1
; T2 = P[T1]
    ldx T1
    lda P0,x
    sta T2
; if NEW_PRIORITY <= T2:
    lda NEW_PRIORITY
    cmp T2
    bcc priority_event_queue_L29
    beq priority_event_queue_L29
priority_event_queue_L30:
    jmp priority_event_queue_L27
priority_event_queue_L29:
    jmp priority_event_queue_L26
priority_event_queue_L26:
; break
    jmp priority_event_queue_L23
    jmp priority_event_queue_L28
priority_event_queue_L27:
priority_event_queue_L28:
; P[T0] = T2
    lda T2
    sta EXPR_SAVE
    ldx T0
    lda EXPR_SAVE
    sta P0,x
; T2 = E[T1]
    ldx T1
    lda E0,x
    sta T2
; E[T0] = T2
    lda T2
    sta EXPR_SAVE
    ldx T0
    lda EXPR_SAVE
    sta E0,x
; T0 = T0 - 1
    lda T0
    sec
    sbc #1
    sta T0
    jmp priority_event_queue_L21
priority_event_queue_L23:
; E[T0] = NEW_EVENT
    lda NEW_EVENT
    sta EXPR_SAVE
    ldx T0
    lda EXPR_SAVE
    sta E0,x
; P[T0] = NEW_PRIORITY
    lda NEW_PRIORITY
    sta EXPR_SAVE
    ldx T0
    lda EXPR_SAVE
    sta P0,x
; COUNT = COUNT + 1
    lda COUNT
    clc
    adc #1
    sta COUNT
; EVENT = NEW_EVENT
    lda NEW_EVENT
    sta EVENT
; PRIORITY = NEW_PRIORITY
    lda NEW_PRIORITY
    sta PRIORITY
    jmp priority_event_queue_L13
priority_event_queue_L12:
; if COUNT == 0:
    lda COUNT
    cmp #0
    beq priority_event_queue_L34
priority_event_queue_L35:
    jmp priority_event_queue_L32
priority_event_queue_L34:
    jmp priority_event_queue_L31
priority_event_queue_L31:
; return
    rts
    jmp priority_event_queue_L33
priority_event_queue_L32:
priority_event_queue_L33:
; EVENT = E0
    lda E0
    sta EVENT
; PRIORITY = P0
    lda P0
    sta PRIORITY
; COUNT = COUNT - 1
    lda COUNT
    sec
    sbc #1
    sta COUNT
; T0 = 0
    lda #0
    sta T0
; while T0 < COUNT:
priority_event_queue_L36:
    lda T0
    cmp COUNT
    bcc priority_event_queue_L39
priority_event_queue_L40:
    jmp priority_event_queue_L38
priority_event_queue_L39:
    jmp priority_event_queue_L37
priority_event_queue_L37:
; T1 = T0 + 1
    lda T0
    clc
    adc #1
    sta T1
; T2 = E[T1]
    ldx T1
    lda E0,x
    sta T2
; E[T0] = T2
    lda T2
    sta EXPR_SAVE
    ldx T0
    lda EXPR_SAVE
    sta E0,x
; T2 = P[T1]
    ldx T1
    lda P0,x
    sta T2
; P[T0] = T2
    lda T2
    sta EXPR_SAVE
    ldx T0
    lda EXPR_SAVE
    sta P0,x
; T0 = T0 + 1
    lda T0
    clc
    adc #1
    sta T0
    jmp priority_event_queue_L36
priority_event_queue_L38:
; E[T0] = 0
    lda #0
    sta EXPR_SAVE
    ldx T0
    lda EXPR_SAVE
    sta E0,x
; P[T0] = 0
    lda #0
    sta EXPR_SAVE
    ldx T0
    lda EXPR_SAVE
    sta P0,x
priority_event_queue_L13:
; RESULT = 1
    lda #1
    sta RESULT
    rts
component_end:
