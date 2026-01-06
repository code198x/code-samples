; Enable rendering
    lda #%10000000          ; Enable NMI
    sta PPUCTRL
    lda #%00011110          ; Enable sprites and background
    sta PPUMASK
