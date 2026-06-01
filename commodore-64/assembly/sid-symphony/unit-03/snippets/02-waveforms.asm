; SID Waveforms - Each has a distinct character
;
; $11 = Triangle - Pure, soft, flute-like
;       Smooth wave with no harsh harmonics
;       Good for bass and mellow leads
;
; $21 = Sawtooth - Bright, buzzy, aggressive
;       Rich in harmonics, sounds "sharp"
;       Good for leads and brass-like sounds
;
; $41 = Pulse (square) - Hollow, woody, reedy
;       Character changes with pulse width
;       50% = pure square, other widths = more nasal
;
; $81 = Noise - Hiss, crash, explosion
;       Random waveform, no pitch
;       Good for drums, percussion, effects
;
; The waveform value goes in the control register (SID_V1_CTRL etc.)
; Add $01 (gate bit) to trigger the sound: $21 + $01 = $22 won't work!
; Must OR the gate bit: $21 OR $01 = $21 (waveform already has bit 0 clear)

play_voice1:
            lda #VOICE1_WAVE    ; e.g., $21 for sawtooth
            ora #$01            ; Add gate bit to trigger
            sta SID_V1_CTRL
            rts
