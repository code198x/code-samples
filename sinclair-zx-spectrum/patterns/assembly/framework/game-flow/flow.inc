; SPDX-License-Identifier: MIT
; Five private bytes: state/events/changed/fresh/error. AF changes only.
; State Title0 Play1 Over2 Paused3; events Start1 Pause2 Loss4 Restart8.
; One transition per call, Loss wins Pause, Restart wins Start in Over.
; Error1 bad state,2 high event bits; preserve state, clear pulses on error.
; Single owner; caller consumes fresh for session reset, preserves sampler.
flow_init:
    xor a
    ld (flow_state),a
    ld (flow_events),a
    ld (flow_changed),a
    ld (flow_fresh),a
    ld (flow_error),a
    ret
flow_step:
    xor a
    ld (flow_changed),a
    ld (flow_fresh),a
    ld (flow_error),a
    ld a,(flow_state)
    cp 4
    jr c,flow_valid_state
    ld a,1
    ld (flow_error),a
    ret
flow_valid_state:
    ld a,(flow_events)
    and $f0
    jr z,flow_valid_events
    ld a,2
    ld (flow_error),a
    ret
flow_valid_events:
    ld a,(flow_state)
    or a
    jr z,flow_title
    cp 1
    jr z,flow_playing
    cp 2
    jr z,flow_over
    ld a,(flow_events)
    and 2
    jr z,flow_done
    ld a,1
    jr flow_commit
flow_title:
    ld a,(flow_events)
    and 1
    jr nz,flow_new_game
    ret
flow_playing:
    ld a,(flow_events)
    and 4
    jr z,flow_check_pause
    ld a,2
    jr flow_commit
flow_check_pause:
    ld a,(flow_events)
    and 2
    jr z,flow_done
    ld a,3
    jr flow_commit
flow_over:
    ld a,(flow_events)
    and 8
    jr nz,flow_new_game
    ld a,(flow_events)
    and 1
    jr z,flow_done
    xor a
    jr flow_commit
flow_new_game:
    ld a,1
    ld (flow_fresh),a
flow_commit:
    ld (flow_state),a
    ld a,1
    ld (flow_changed),a
flow_done:
    ret
component_end:
