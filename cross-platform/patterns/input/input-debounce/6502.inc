; SPDX-License-Identifier: MIT
; Debounce a Sampled Input Byte. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
input_debounce_init:
    lda #0
    sta STABLE
    sta CHANGED
    sta CANDIDATE
    sta RUN
    sta RAW
    sta THRESHOLD
    rts
input_debounce_step:
; CHANGED = 0
    lda #0
    sta CHANGED
; if THRESHOLD == 0:
    lda THRESHOLD
    cmp #0
    beq input_debounce_L4
input_debounce_L5:
    jmp input_debounce_L2
input_debounce_L4:
    jmp input_debounce_L1
input_debounce_L1:
; RUN = 0
    lda #0
    sta RUN
; return
    rts
    jmp input_debounce_L3
input_debounce_L2:
input_debounce_L3:
; if RAW != CANDIDATE:
    lda RAW
    cmp CANDIDATE
    bne input_debounce_L9
input_debounce_L10:
    jmp input_debounce_L7
input_debounce_L9:
    jmp input_debounce_L6
input_debounce_L6:
; CANDIDATE = RAW
    lda RAW
    sta CANDIDATE
; RUN = 1
    lda #1
    sta RUN
    jmp input_debounce_L8
input_debounce_L7:
; if RUN < 255:
    lda RUN
    cmp #255
    bcc input_debounce_L14
input_debounce_L15:
    jmp input_debounce_L12
input_debounce_L14:
    jmp input_debounce_L11
input_debounce_L11:
; RUN = RUN + 1
    lda RUN
    clc
    adc #1
    sta RUN
    jmp input_debounce_L13
input_debounce_L12:
input_debounce_L13:
input_debounce_L8:
; if RUN >= THRESHOLD:
    lda RUN
    cmp THRESHOLD
    bcs input_debounce_L19
input_debounce_L20:
    jmp input_debounce_L17
input_debounce_L19:
    jmp input_debounce_L16
input_debounce_L16:
; if STABLE != CANDIDATE:
    lda STABLE
    cmp CANDIDATE
    bne input_debounce_L24
input_debounce_L25:
    jmp input_debounce_L22
input_debounce_L24:
    jmp input_debounce_L21
input_debounce_L21:
; STABLE = CANDIDATE
    lda CANDIDATE
    sta STABLE
; CHANGED = 1
    lda #1
    sta CHANGED
    jmp input_debounce_L23
input_debounce_L22:
input_debounce_L23:
    jmp input_debounce_L18
input_debounce_L17:
input_debounce_L18:
    rts
component_end:
