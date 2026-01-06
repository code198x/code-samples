setup_screen:
            lda #$00
            sta $d020           ; Border = black
            sta $d021           ; Background = black

            ; Clear all 1000 screen positions
            ldx #$00
clear_loop:
            lda #$20            ; Space character
            sta $0400,x         ; Screen RAM page 1
            sta $0500,x         ; Screen RAM page 2
            sta $0600,x         ; Screen RAM page 3
            sta $06e8,x         ; Screen RAM remaining bytes
            lda #$00            ; Black
            sta $d800,x         ; Colour RAM page 1
            sta $d900,x         ; Colour RAM page 2
            sta $da00,x         ; Colour RAM page 3
            sta $dae8,x         ; Colour RAM remaining
            inx
            bne clear_loop
            rts
