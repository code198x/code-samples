    ; --- Read controller ---
    lda #1
    sta JOYPAD1             ; Strobe on: latch button states
    lda #0
    sta JOYPAD1             ; Strobe off: begin serial output

    ldx #8                  ; 8 buttons to read
@read_pad:
    lda JOYPAD1             ; Read next button (bit 0)
    lsr a                   ; Shift bit 0 into carry
    rol buttons             ; Roll carry into buttons byte
    dex
    bne @read_pad
