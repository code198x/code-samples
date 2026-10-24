; SPDX-License-Identifier: MIT
; Capture and Restore a Checked Checkpoint. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
checkpoint_state_init:
    ld a,0
    ld (RESULT),a
    ld (SAVED),a
    ld (LIVE_X),a
    ld (LIVE_Y),a
    ld (LIVE_RESOURCE),a
    ld (MODE),a
    ld (SAVED_X),a
    ld (SAVED_Y),a
    ld (SAVED_RESOURCE),a
    ld (CHECKSUM),a
    ld (T0),a
    ret
checkpoint_state_step:
; RESULT = 0
    ld a,0
    ld (RESULT),a
; if MODE == 0:
    ld a,(MODE)
    cp 0
    jp z,checkpoint_state_L1
    jp checkpoint_state_L2
checkpoint_state_L1:
; SAVED_X = LIVE_X
    ld a,(LIVE_X)
    ld (SAVED_X),a
; SAVED_Y = LIVE_Y
    ld a,(LIVE_Y)
    ld (SAVED_Y),a
; SAVED_RESOURCE = LIVE_RESOURCE
    ld a,(LIVE_RESOURCE)
    ld (SAVED_RESOURCE),a
; CHECKSUM = SAVED_X ^ SAVED_Y
    ld a,(SAVED_X)
    ld b,a
    ld a,(SAVED_Y)
    ld c,a
    ld a,b
    xor c
    ld (CHECKSUM),a
; CHECKSUM = CHECKSUM ^ SAVED_RESOURCE
    ld a,(CHECKSUM)
    ld b,a
    ld a,(SAVED_RESOURCE)
    ld c,a
    ld a,b
    xor c
    ld (CHECKSUM),a
; SAVED = 1
    ld a,1
    ld (SAVED),a
; RESULT = 1
    ld a,1
    ld (RESULT),a
; return
    ret
    jp checkpoint_state_L3
checkpoint_state_L2:
checkpoint_state_L3:
; if MODE != 1:
    ld a,(MODE)
    cp 1
    jp nz,checkpoint_state_L4
    jp checkpoint_state_L5
checkpoint_state_L4:
; return
    ret
    jp checkpoint_state_L6
checkpoint_state_L5:
checkpoint_state_L6:
; if SAVED != 1:
    ld a,(SAVED)
    cp 1
    jp nz,checkpoint_state_L7
    jp checkpoint_state_L8
checkpoint_state_L7:
; return
    ret
    jp checkpoint_state_L9
checkpoint_state_L8:
checkpoint_state_L9:
; T0 = SAVED_X ^ SAVED_Y
    ld a,(SAVED_X)
    ld b,a
    ld a,(SAVED_Y)
    ld c,a
    ld a,b
    xor c
    ld (T0),a
; T0 = T0 ^ SAVED_RESOURCE
    ld a,(T0)
    ld b,a
    ld a,(SAVED_RESOURCE)
    ld c,a
    ld a,b
    xor c
    ld (T0),a
; if T0 != CHECKSUM:
    ld a,(T0)
    ld b,a
    ld a,(CHECKSUM)
    ld c,a
    ld a,b
    cp c
    jp nz,checkpoint_state_L10
    jp checkpoint_state_L11
checkpoint_state_L10:
; return
    ret
    jp checkpoint_state_L12
checkpoint_state_L11:
checkpoint_state_L12:
; LIVE_X = SAVED_X
    ld a,(SAVED_X)
    ld (LIVE_X),a
; LIVE_Y = SAVED_Y
    ld a,(SAVED_Y)
    ld (LIVE_Y),a
; LIVE_RESOURCE = SAVED_RESOURCE
    ld a,(SAVED_RESOURCE)
    ld (LIVE_RESOURCE),a
; RESULT = 1
    ld a,1
    ld (RESULT),a
    ret
component_end:
