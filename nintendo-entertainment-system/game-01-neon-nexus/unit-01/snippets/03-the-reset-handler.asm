.proc reset
    sei                     ; Disable IRQs
    cld                     ; Disable decimal mode

    ldx #$40
    stx $4017               ; Disable APU frame IRQ

    ldx #$ff
    txs                     ; Set up stack

    inx                     ; X = 0
    stx PPUCTRL             ; Disable NMI
    stx PPUMASK             ; Disable rendering
    stx $4010               ; Disable DMC IRQs
