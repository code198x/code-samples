; Integration fragment inside an existing ca65 NES program, not a ROM header.
; Include input.inc, presses.inc and tone.inc once in your linked program.
; Caller owns pulse 1; do not let the NMI/music driver write it concurrently.
; This caller assumes no DMC and owns the APU enable shadow from startup.
initialise_input:
    lda #0
    sta previous_controls
    sta apu_enable
    sta $4015
    rts
update_input:
    jsr read_controls
    jsr detect_presses
    lda new_presses
    and #$80                  ; native A-button mask, not C64 Fire=$10
    beq check_release
    jsr tone_on
check_release:
    lda controls
    and #$80
    bne input_done
    jsr tone_off               ; release A to silence pulse 1
input_done:
    rts
