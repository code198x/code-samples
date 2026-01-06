init_sid:
            ; Master volume to maximum
            lda #$0f
            sta $d418

            ; Voice 1 ADSR: instant attack, short release
            lda #$00            ; Attack=0, Decay=0
            sta $d405
            lda #$f9            ; Sustain=15, Release=9
            sta $d406

            ; Pulse width (needed for pulse wave)
            lda #$00
            sta $d402
            lda #$08            ; 50% duty cycle
            sta $d403

            ; Frequency for middle C (approximately)
            lda #$12
            sta $d400
            lda #$11
            sta $d401

            rts
