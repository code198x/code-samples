.proc nmi
    ; Preserve registers
    pha
    txa
    pha
    tya
    pha

    inc frame_counter

    ; OAM DMA transfer
    lda #$00
    sta OAMADDR             ; Set OAM address to 0
    lda #$02                ; High byte of $0200
    sta OAMDMA              ; Trigger DMA copy

    ; Reset scroll position
    lda #$00
    sta PPUSCROLL
    sta PPUSCROLL

    ; Restore registers
    pla
    tay
    pla
    tax
    pla

    rti
.endproc
