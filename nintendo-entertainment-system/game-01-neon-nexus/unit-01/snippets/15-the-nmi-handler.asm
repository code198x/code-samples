.proc nmi
    inc frame_counter

    ; Reset scroll (important!)
    lda #$00
    sta PPUSCROLL
    sta PPUSCROLL

    rti
.endproc
