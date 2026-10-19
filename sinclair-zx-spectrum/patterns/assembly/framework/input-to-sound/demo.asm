; 48K PAL. Load the generated tape or snapshot. QAOP + Space; reset to leave.
; Uses the ROM interrupt only to wait for frames, then disables interrupts
; before input and the blocking beep. Code and stack are in uncontended RAM.
    org $8000
start:
    di
    ld sp,$ff00
    call initialise_input
    xor a
    ld (trigger_count),a
    ld (updates),a
    ld (updates+1),a
    ld a,1
    ld (ula_output),a
    out ($fe),a
wait_frame:
    ei
    halt
    di
    call update_input
    ld a,(new_presses)
    and $10
    jr z,show_state
    ld a,(trigger_count)
    inc a
    ld (trigger_count),a
show_state:
    ld a,(trigger_count)
    and 7
    ld (ula_output),a
    out ($fe),a             ; border changes once per new Space press
    ld hl,(updates)
    inc hl
    ld (updates),hl
frame_done:
    jr wait_frame
trigger_count: defb 0
updates: defw 0
    include "input.inc"
    include "presses.inc"
    include "../../audio/sound-beep/sound-beep.inc"
    include "use.asm"
    end start
