; The gate controls when ADSR cycles begin and end
;
; Gate ON (bit 0 = 1):
;   - Starts the Attack phase
;   - Sound rises to full volume
;   - Then decays to Sustain level
;   - Holds at Sustain while gate stays open
;
; Gate OFF (bit 0 = 0):
;   - Starts the Release phase
;   - Sound fades from current level to silence

; Trigger the note
lda #WAVE_PULSE | GATE_ON       ; Waveform + gate on
sta SID_V1_CTRL

; ... wait while note plays ...

; Release the note
lda #WAVE_PULSE                 ; Same waveform, gate off
sta SID_V1_CTRL
