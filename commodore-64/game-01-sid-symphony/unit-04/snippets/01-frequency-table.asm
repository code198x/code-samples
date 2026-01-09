; Frequency table - C major scale (C4 to C5)
; Split into two tables: low bytes and high bytes
;
; Why two tables? The 6502 can only load one byte at a time.
; Keeping low and high bytes separate lets us use indexed addressing:
;   lda freq_lo,x    ; Load low byte for note X
;   lda freq_hi,x    ; Load high byte for note X
;
; Formula: freq_value = (note_hz * 16777216) / 985248

freq_lo:
                !byte $67           ; C4  - 261.63 Hz = $1167
                !byte $89           ; D4  - 293.66 Hz = $1389
                !byte $ed           ; E4  - 329.63 Hz = $15ed
                !byte $3b           ; F4  - 349.23 Hz = $173b
                !byte $13           ; G4  - 392.00 Hz = $1a13
                !byte $45           ; A4  - 440.00 Hz = $1d45
                !byte $da           ; B4  - 493.88 Hz = $20da
                !byte $ce           ; C5  - 523.25 Hz = $22ce

freq_hi:
                !byte $11           ; C4
                !byte $13           ; D4
                !byte $15           ; E4
                !byte $17           ; F4
                !byte $1a           ; G4
                !byte $1d           ; A4
                !byte $20           ; B4
                !byte $22           ; C5
