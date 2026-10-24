; SPDX-License-Identifier: MIT
; Caller owns FLOW_STATE/EVENTS/CHANGED/FRESH/ERROR (five private bytes).
; States TITLE0 PLAY1 OVER2 PAUSED3. Events START1 PAUSE2 LOSS4 RESTART8.
; step performs at most one transition; LOSS wins PAUSE, RESTART wins START.
; CHANGED is an entry pulse; FRESH asks the caller to reset session data once.
; Invalid state -> ERROR1, high event bits -> ERROR2; state stays unchanged.
; All calls change A/flags, preserve X/Y and decimal mode. Single owner.
flow_init:
    lda #0
    sta FLOW_STATE
    sta FLOW_EVENTS
    sta FLOW_CHANGED
    sta FLOW_FRESH
    sta FLOW_ERROR
    rts
flow_step:
    lda #0
    sta FLOW_CHANGED
    sta FLOW_FRESH
    sta FLOW_ERROR
    lda FLOW_STATE
    cmp #4
    bcc flow_valid_state
    lda #1
    sta FLOW_ERROR
    rts
flow_valid_state:
    lda FLOW_EVENTS
    and #$f0
    beq flow_valid_events
    lda #2
    sta FLOW_ERROR
    rts
flow_valid_events:
    lda FLOW_STATE
    beq flow_title
    cmp #1
    beq flow_playing
    cmp #2
    beq flow_over
; paused: resume the current session, not a new one.
    lda FLOW_EVENTS
    and #2
    beq flow_done
    lda #1
    bne flow_commit
flow_title:
    lda FLOW_EVENTS
    and #1
    bne flow_new_game
    rts
flow_playing:
    lda FLOW_EVENTS
    and #4
    beq flow_check_pause
    lda #2
    bne flow_commit
flow_check_pause:
    lda FLOW_EVENTS
    and #2
    beq flow_done
    lda #3
    bne flow_commit
flow_over:
    lda FLOW_EVENTS
    and #8
    bne flow_new_game
    lda FLOW_EVENTS
    and #1
    beq flow_done
    lda #0
    beq flow_commit
flow_new_game:
    lda #1
    sta FLOW_FRESH
flow_commit:
    cmp FLOW_STATE
    beq flow_done
    sta FLOW_STATE
    lda #1
    sta FLOW_CHANGED
flow_done:
    rts
component_end:
