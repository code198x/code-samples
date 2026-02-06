        ; Score starts at zero (BCD)
        lda #$00
        sta score

        ; Write "00" to screen RAM (top-left corner)
        lda #$30            ; Screen code for '0'
        sta $0400           ; Tens digit (row 0, col 0)
        sta $0401           ; Ones digit (row 0, col 1)

        ; Set score colour to white
        lda #$01
        sta $d800
        sta $d801
