lda #$01
    sta $4016       ; Strobe on - capture button states
    lda #$00
    sta $4016       ; Strobe off - lock them in
