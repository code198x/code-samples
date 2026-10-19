; Integration fragment inside a hardware-owning Amiga program, not a boot disk.
; A5=$dff000. Include input.inc, presses.inc and paula-sample.inc once.
; Caller owns physical port 2, audio channel 0 and its interrupt/DMA state.
initialise_input:
    clr.w previous_controls
    bclr #7,$bfe201            ; fire line input; preserve other CIA-A directions
    bsr stop_sample
    rts
update_input:
    bsr read_controls
    bsr detect_presses
    btst #4,new_presses+1      ; byte BTST: low byte of the stored word
    beq.s input_check_release
    lea waveform,a0           ; waveform must be in even-aligned CHIP RAM
    moveq #8,d0               ; sixteen bytes = eight words
    move.w #424,d1            ; chosen PAL period
    moveq #64,d2
    bsr play_sample            ; loops until stop_sample
input_check_release:
    btst #4,controls+1
    bne.s input_done
    bsr stop_sample
input_done:
    rts
; Wait at least a frame after initialise_input before first update_input.
; This caller samples once per PAL frame; with period 424 a frame exceeds
; the driver's required two-period off interval before a new Fire press.
