; 48K PAL, stock ROM/IY retained for IM1/CLS. Own stack and screen; reset to leave.
start:
    di
    ld sp,$ff00
    call $0daf
    xor a
    ld (previous_controls),a
    ld (released_controls),a
    ld (actions),a
    ld hl,trace
    ld b,4
clear_trace:
    ld (hl),a
    inc hl
    djnz clear_trace
    ld a,165
    ld (ready),a
wait_frame:
    ei
    halt
    di
sample:
    call read_controls
    call POLL_ROUTINE
    ld a,(new_presses)
    or a
    jr z,no_press
    ld (last_new),a
    ld a,(press_events)
    inc a
    ld (press_events),a
no_press:
    ld a,(released_controls)
    or a
    jr z,no_release
    ld (last_release),a
    ld a,(release_events)
    inc a
    ld (release_events),a
no_release:
    ld a,(new_presses)
    and ACTION_MASK
    jr z,show_state
    ld a,(actions)
    inc a
    ld (actions),a
show_state:
    ld de,$4000
    ld a,(controls)
    call show_byte
    ld a,32
    call show_char
    ld a,(new_presses)
    call show_byte
    ld a,32
    call show_char
    ld a,(released_controls)
    call show_byte
    ld a,32
    call show_char
    ld a,(actions)
    call show_byte
frame_done:
    jr wait_frame
trace:
last_new: defb 0
last_release: defb 0
press_events: defb 0
release_events: defb 0
actions: defb 0
ready: defb 0
