; Frequency table - C major scale (C4 to C5)
; Split into two tables: low bytes and high bytes
;
; Why two tables? The 6502 can only load one byte at a time.
; Keeping low and high bytes separate lets us use indexed addressing:
;   lda freq_lo,x    ; Load low byte for note X
;   lda freq_hi,x    ; Load high byte for note X

freq_lo:
                !byte $16           ; C4  - 261.63 Hz
                !byte $27           ; D4  - 293.66 Hz
                !byte $5b           ; E4  - 329.63 Hz
                !byte $8f           ; F4  - 349.23 Hz
                !byte $e1           ; G4  - 392.00 Hz
                !byte $57           ; A4  - 440.00 Hz
                !byte $f4           ; B4  - 493.88 Hz
                !byte $2c           ; C5  - 523.25 Hz

freq_hi:
                !byte $11           ; C4
                !byte $13           ; D4
                !byte $15           ; E4
                !byte $16           ; F4
                !byte $18           ; G4
                !byte $1b           ; A4
                !byte $1d           ; B4
                !byte $22           ; C5
