.proc nmi
    pha
    txa
    pha
    tya
    pha

    inc frame_counter

    ; OAM DMA transfer
    lda #$00
    sta OAMADDR
    lda #$02
    sta OAMDMA

    ; Update score display
    jsr draw_score

    ; Reset scroll position
    lda #$00
    sta PPUSCROLL
    sta PPUSCROLL

    pla
    tay
    pla
    tax
    pla

    rti
.endproc
