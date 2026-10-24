; SPDX-License-Identifier: MIT
; Five caller-owned byte fields: state/events/changed/fresh/error.
; D0/CCR may change; D1-D7/A0-A6 survive. No chipset or IRQ operations.
; States Title0 Play1 Over2 Paused3; events Start1 Pause2 Loss4 Restart8.
; One decision per update. Loss beats Pause; Over/Restart beats Start.
; FRESH asks the owner to reset session data once, never on resume.
; Error1 invalid state or2 high event bits: preserve state, clear pulses.
flow_init:
    clr.b flow_state
    clr.b flow_events
    clr.b flow_changed
    clr.b flow_fresh
    clr.b flow_error
    rts
flow_step:
    clr.b flow_changed
    clr.b flow_fresh
    clr.b flow_error
    move.b flow_state,d0
    cmpi.b #4,d0
    blo.s flow_valid_state
    move.b #1,flow_error
    rts
flow_valid_state:
    move.b flow_events,d0
    andi.b #$f0,d0
    beq.s flow_valid_events
    move.b #2,flow_error
    rts
flow_valid_events:
    move.b flow_state,d0
    tst.b d0
    beq.s flow_title
    cmpi.b #1,d0
    beq.s flow_playing
    cmpi.b #2,d0
    beq.s flow_over
    move.b flow_events,d0
    andi.b #2,d0
    beq.s flow_done
    moveq #1,d0
    bra.s flow_commit
flow_title:
    move.b flow_events,d0
    andi.b #1,d0
    bne.s flow_new_game
    rts
flow_playing:
    move.b flow_events,d0
    andi.b #4,d0
    beq.s flow_check_pause
    moveq #2,d0
    bra.s flow_commit
flow_check_pause:
    move.b flow_events,d0
    andi.b #2,d0
    beq.s flow_done
    moveq #3,d0
    bra.s flow_commit
flow_over:
    move.b flow_events,d0
    andi.b #8,d0
    bne.s flow_new_game
    move.b flow_events,d0
    andi.b #1,d0
    beq.s flow_done
    moveq #0,d0
    bra.s flow_commit
flow_new_game:
    move.b #1,flow_fresh
    moveq #1,d0
flow_commit:
    move.b d0,flow_state
    move.b #1,flow_changed
flow_done:
    rts
component_end:
