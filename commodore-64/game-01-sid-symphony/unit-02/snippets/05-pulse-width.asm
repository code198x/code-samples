; Pulse width only affects the pulse waveform
; It's a 12-bit value (0-4095) split across two registers
; $0800 (2048) = 50% duty cycle - balanced, hollow sound
; Lower values = thinner sound
; Higher values = fuller sound

                lda #$00                ; Low byte
                sta SID_V3_PW_LO
                lda #$08                ; High byte ($0800 = 2048 = 50%)
                sta SID_V3_PW_HI
