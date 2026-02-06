        ; Clear the screen (fill with spaces)
        ldx #$00
-       lda #$20            ; Space character
        sta $0400,x
        sta $0500,x
        sta $0600,x
        sta $0700,x
        inx
        bne -
