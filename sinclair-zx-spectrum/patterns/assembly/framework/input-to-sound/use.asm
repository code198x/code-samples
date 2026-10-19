; Integration fragment inside your 48K Spectrum program, not a tape loader.
; Include input.inc, presses.inc and ../../audio/sound-beep/sound-beep.inc once.
; Our caller keeps interrupts disabled, including while the blocking beep plays.
initialise_input:
    di
    xor a
    ld (previous_controls),a
    ld (ula_output),a
    ret
update_input:
    call read_controls
    call detect_presses
    ld a,(new_presses)
    and $10
    ret z
    ld a,(ula_output)         ; caller's shared border/MIC output byte
    ld hl,$7f0c              ; short click: delay 127, twelve cycles
    call sound_beep           ; blocks the CPU: update timing lengthens here
    ret
ula_output: defb 0
