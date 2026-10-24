; SPDX-License-Identifier: MIT
; Capture and Restore a Checked Checkpoint. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
checkpoint_state_init:
    lda #0
    sta RESULT
    sta SAVED
    sta LIVE_X
    sta LIVE_Y
    sta LIVE_RESOURCE
    sta MODE
    sta SAVED_X
    sta SAVED_Y
    sta SAVED_RESOURCE
    sta CHECKSUM
    sta T0
    rts
checkpoint_state_step:
; RESULT = 0
    lda #0
    sta RESULT
; if MODE == 0:
    lda MODE
    cmp #0
    beq checkpoint_state_L4
checkpoint_state_L5:
    jmp checkpoint_state_L2
checkpoint_state_L4:
    jmp checkpoint_state_L1
checkpoint_state_L1:
; SAVED_X = LIVE_X
    lda LIVE_X
    sta SAVED_X
; SAVED_Y = LIVE_Y
    lda LIVE_Y
    sta SAVED_Y
; SAVED_RESOURCE = LIVE_RESOURCE
    lda LIVE_RESOURCE
    sta SAVED_RESOURCE
; CHECKSUM = SAVED_X ^ SAVED_Y
    lda SAVED_X
    eor SAVED_Y
    sta CHECKSUM
; CHECKSUM = CHECKSUM ^ SAVED_RESOURCE
    lda CHECKSUM
    eor SAVED_RESOURCE
    sta CHECKSUM
; SAVED = 1
    lda #1
    sta SAVED
; RESULT = 1
    lda #1
    sta RESULT
; return
    rts
    jmp checkpoint_state_L3
checkpoint_state_L2:
checkpoint_state_L3:
; if MODE != 1:
    lda MODE
    cmp #1
    bne checkpoint_state_L9
checkpoint_state_L10:
    jmp checkpoint_state_L7
checkpoint_state_L9:
    jmp checkpoint_state_L6
checkpoint_state_L6:
; return
    rts
    jmp checkpoint_state_L8
checkpoint_state_L7:
checkpoint_state_L8:
; if SAVED != 1:
    lda SAVED
    cmp #1
    bne checkpoint_state_L14
checkpoint_state_L15:
    jmp checkpoint_state_L12
checkpoint_state_L14:
    jmp checkpoint_state_L11
checkpoint_state_L11:
; return
    rts
    jmp checkpoint_state_L13
checkpoint_state_L12:
checkpoint_state_L13:
; T0 = SAVED_X ^ SAVED_Y
    lda SAVED_X
    eor SAVED_Y
    sta T0
; T0 = T0 ^ SAVED_RESOURCE
    lda T0
    eor SAVED_RESOURCE
    sta T0
; if T0 != CHECKSUM:
    lda T0
    cmp CHECKSUM
    bne checkpoint_state_L19
checkpoint_state_L20:
    jmp checkpoint_state_L17
checkpoint_state_L19:
    jmp checkpoint_state_L16
checkpoint_state_L16:
; return
    rts
    jmp checkpoint_state_L18
checkpoint_state_L17:
checkpoint_state_L18:
; LIVE_X = SAVED_X
    lda SAVED_X
    sta LIVE_X
; LIVE_Y = SAVED_Y
    lda SAVED_Y
    sta LIVE_Y
; LIVE_RESOURCE = SAVED_RESOURCE
    lda SAVED_RESOURCE
    sta LIVE_RESOURCE
; RESULT = 1
    lda #1
    sta RESULT
    rts
component_end:
