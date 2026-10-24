; SPDX-License-Identifier: MIT
; Gate a Dialogue Choice with Flags. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
dialogue_gates_init:
    lda #0
    sta FLAGS
    sta REQUIRED
    sta FORBIDDEN
    sta SET_MASK
    sta CLEAR_MASK
    sta ACCEPT
    sta AVAILABLE
    sta TAKEN
    sta VALID
    sta T0
    rts
dialogue_gates_step:
; AVAILABLE = 0
    lda #0
    sta AVAILABLE
; TAKEN = 0
    lda #0
    sta TAKEN
; VALID = 0
    lda #0
    sta VALID
; T0 = REQUIRED & FORBIDDEN
    lda REQUIRED
    and FORBIDDEN
    sta T0
; if T0 != 0:
    lda T0
    cmp #0
    bne dialogue_gates_L4
dialogue_gates_L5:
    jmp dialogue_gates_L2
dialogue_gates_L4:
    jmp dialogue_gates_L1
dialogue_gates_L1:
; return
    rts
    jmp dialogue_gates_L3
dialogue_gates_L2:
dialogue_gates_L3:
; VALID = 1
    lda #1
    sta VALID
; T0 = FLAGS & REQUIRED
    lda FLAGS
    and REQUIRED
    sta T0
; if T0 != REQUIRED:
    lda T0
    cmp REQUIRED
    bne dialogue_gates_L9
dialogue_gates_L10:
    jmp dialogue_gates_L7
dialogue_gates_L9:
    jmp dialogue_gates_L6
dialogue_gates_L6:
; return
    rts
    jmp dialogue_gates_L8
dialogue_gates_L7:
dialogue_gates_L8:
; T0 = FLAGS & FORBIDDEN
    lda FLAGS
    and FORBIDDEN
    sta T0
; if T0 != 0:
    lda T0
    cmp #0
    bne dialogue_gates_L14
dialogue_gates_L15:
    jmp dialogue_gates_L12
dialogue_gates_L14:
    jmp dialogue_gates_L11
dialogue_gates_L11:
; return
    rts
    jmp dialogue_gates_L13
dialogue_gates_L12:
dialogue_gates_L13:
; AVAILABLE = 1
    lda #1
    sta AVAILABLE
; if ACCEPT == 0:
    lda ACCEPT
    cmp #0
    beq dialogue_gates_L19
dialogue_gates_L20:
    jmp dialogue_gates_L17
dialogue_gates_L19:
    jmp dialogue_gates_L16
dialogue_gates_L16:
; return
    rts
    jmp dialogue_gates_L18
dialogue_gates_L17:
dialogue_gates_L18:
; T0 = CLEAR_MASK ^ 255
    lda CLEAR_MASK
    eor #255
    sta T0
; FLAGS = FLAGS & T0
    lda FLAGS
    and T0
    sta FLAGS
; FLAGS = FLAGS | SET_MASK
    lda FLAGS
    ora SET_MASK
    sta FLAGS
; TAKEN = 1
    lda #1
    sta TAKEN
    rts
component_end:
