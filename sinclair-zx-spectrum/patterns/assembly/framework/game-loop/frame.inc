; 48K ROM IM1 service must stay enabled, including during game work.
; ROM FRAMES low byte counts serviced interrupts, not game updates.
; AF/B change, other registers survive. IFF must be enabled; returns enabled.
; Work must take fewer than 256 frames; no unbounded catch-up replay.
initialise_clock:
    ld a,($5c78)
    ld (last_frame),a
    ret
wait_frame:
    di
    ld a,($5c78)
    ld b,a
    ld a,(last_frame)
    cp b
    jr nz,accept_frame
    ei
    halt
    jr wait_frame
accept_frame:
    ld a,(last_frame)
    neg
    add a,b
    ld (frame_delta),a
    ld a,b
    ld (last_frame),a
    ei
    ret
last_frame: defb 0
frame_delta: defb 0
