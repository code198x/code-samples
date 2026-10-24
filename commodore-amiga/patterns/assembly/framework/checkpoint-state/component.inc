; SPDX-License-Identifier: MIT
; Capture and Restore a Checked Checkpoint. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
checkpoint_state_init:
    move.b #0,d0
    move.b d0,RESULT
    move.b d0,SAVED
    move.b d0,LIVE_X
    move.b d0,LIVE_Y
    move.b d0,LIVE_RESOURCE
    move.b d0,MODE
    move.b d0,SAVED_X
    move.b d0,SAVED_Y
    move.b d0,SAVED_RESOURCE
    move.b d0,CHECKSUM
    move.b d0,T0
    rts
checkpoint_state_step:
; RESULT = 0
    move.b #0,d0
    move.b d0,RESULT
; if MODE == 0:
    move.b MODE,d0
    cmp.b #0,d0
    beq checkpoint_state_L1
    jmp checkpoint_state_L2
checkpoint_state_L1:
; SAVED_X = LIVE_X
    move.b LIVE_X,d0
    move.b d0,SAVED_X
; SAVED_Y = LIVE_Y
    move.b LIVE_Y,d0
    move.b d0,SAVED_Y
; SAVED_RESOURCE = LIVE_RESOURCE
    move.b LIVE_RESOURCE,d0
    move.b d0,SAVED_RESOURCE
; CHECKSUM = SAVED_X ^ SAVED_Y
    move.b SAVED_X,d0
    move.b SAVED_Y,d1
    eor.b d1,d0
    move.b d0,CHECKSUM
; CHECKSUM = CHECKSUM ^ SAVED_RESOURCE
    move.b CHECKSUM,d0
    move.b SAVED_RESOURCE,d1
    eor.b d1,d0
    move.b d0,CHECKSUM
; SAVED = 1
    move.b #1,d0
    move.b d0,SAVED
; RESULT = 1
    move.b #1,d0
    move.b d0,RESULT
; return
    rts
    jmp checkpoint_state_L3
checkpoint_state_L2:
checkpoint_state_L3:
; if MODE != 1:
    move.b MODE,d0
    cmp.b #1,d0
    bne checkpoint_state_L4
    jmp checkpoint_state_L5
checkpoint_state_L4:
; return
    rts
    jmp checkpoint_state_L6
checkpoint_state_L5:
checkpoint_state_L6:
; if SAVED != 1:
    move.b SAVED,d0
    cmp.b #1,d0
    bne checkpoint_state_L7
    jmp checkpoint_state_L8
checkpoint_state_L7:
; return
    rts
    jmp checkpoint_state_L9
checkpoint_state_L8:
checkpoint_state_L9:
; T0 = SAVED_X ^ SAVED_Y
    move.b SAVED_X,d0
    move.b SAVED_Y,d1
    eor.b d1,d0
    move.b d0,T0
; T0 = T0 ^ SAVED_RESOURCE
    move.b T0,d0
    move.b SAVED_RESOURCE,d1
    eor.b d1,d0
    move.b d0,T0
; if T0 != CHECKSUM:
    move.b T0,d0
    move.b CHECKSUM,d1
    cmp.b d1,d0
    bne checkpoint_state_L10
    jmp checkpoint_state_L11
checkpoint_state_L10:
; return
    rts
    jmp checkpoint_state_L12
checkpoint_state_L11:
checkpoint_state_L12:
; LIVE_X = SAVED_X
    move.b SAVED_X,d0
    move.b d0,LIVE_X
; LIVE_Y = SAVED_Y
    move.b SAVED_Y,d0
    move.b d0,LIVE_Y
; LIVE_RESOURCE = SAVED_RESOURCE
    move.b SAVED_RESOURCE,d0
    move.b d0,LIVE_RESOURCE
; RESULT = 1
    move.b #1,d0
    move.b d0,RESULT
    rts
component_end:
