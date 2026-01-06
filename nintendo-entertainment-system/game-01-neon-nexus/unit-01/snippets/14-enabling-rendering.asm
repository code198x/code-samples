; Reset scroll
    lda #$00
    sta PPUSCROLL
    sta PPUSCROLL

forever:
    jmp forever
.endproc
