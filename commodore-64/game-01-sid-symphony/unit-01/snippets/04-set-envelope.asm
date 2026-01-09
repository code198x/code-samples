                ; Set ADSR envelope
                ; Attack/Decay register: high nibble = Attack, low nibble = Decay
                lda #$00            ; Attack = 0 (instant), Decay = 0 (none)
                sta SID_V1_AD

                ; Sustain/Release register: high nibble = Sustain, low nibble = Release
                lda #$f0            ; Sustain = 15 (full), Release = 0 (instant)
                sta SID_V1_SR
