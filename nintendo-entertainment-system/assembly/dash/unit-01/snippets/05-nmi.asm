nmi:
    pha                     ; Save A
    txa
    pha                     ; Save X
    tya
    pha                     ; Save Y

    ; Copy OAM buffer to PPU via DMA
    lda #0
    sta OAMADDR
    lda #>oam_buffer        ; High byte of buffer address ($02)
    sta OAMDMA              ; Triggers 256-byte DMA transfer

    pla                     ; Restore Y
    tay
    pla                     ; Restore X
    tax
    pla                     ; Restore A
    rti
