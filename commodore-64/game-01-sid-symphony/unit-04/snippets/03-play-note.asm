; Play note at index X from the frequency table
; Preserves X for the caller
play_note:
                stx temp_x          ; Save X

                ; Load frequency from table
                lda freq_lo,x
                sta SID_V1_FREQ_LO
                lda freq_hi,x
                sta SID_V1_FREQ_HI

                ; Gate on - start the note
                lda #WAVE_PULSE | GATE_ON
                sta SID_V1_CTRL

                ; Hold for NOTE_DURATION frames
                ldy #NOTE_DURATION
.hold:          jsr wait_frame
                dey
                bne .hold

                ; Gate off - release the note
                lda #WAVE_PULSE
                sta SID_V1_CTRL

                ; Brief gap between notes
                ldy #5
.gap:           jsr wait_frame
                dey
                bne .gap

                ldx temp_x          ; Restore X
                rts

temp_x:         !byte 0             ; Temporary storage
