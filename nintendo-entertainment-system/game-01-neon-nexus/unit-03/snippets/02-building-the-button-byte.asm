.proc read_controller
    lda #$01
    sta JOYPAD1             ; Strobe on
    lda #$00
    sta JOYPAD1             ; Strobe off

    ldx #8                  ; Read 8 buttons
@loop:
    lda JOYPAD1             ; Read next button (bit 0)
    lsr a                   ; Shift bit 0 into carry
    rol buttons             ; Roll carry into buttons byte
    dex
    bne @loop
    rts
.endproc
