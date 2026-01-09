                ; Set frequency for middle C (C4)
                ; Frequency is a 16-bit value split across two registers
                lda #$67            ; Low byte of $1167
                sta SID_V1_FREQ_LO
                lda #$11            ; High byte of $1167
                sta SID_V1_FREQ_HI
