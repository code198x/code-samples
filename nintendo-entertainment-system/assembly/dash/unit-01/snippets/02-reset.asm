reset:
    sei                     ; Disable interrupts
    cld                     ; Clear decimal mode (6502 habit, not used on NES)
    ldx #$40
    stx $4017               ; Disable APU frame IRQ
    ldx #$FF
    txs                     ; Set up stack pointer
    inx                     ; X = 0
    stx PPUCTRL             ; Disable NMI
    stx PPUMASK             ; Disable rendering
    stx $4010               ; Disable DMC IRQs

    ; Wait for PPU to stabilise (first vblank)
@vblank1:
    bit PPUSTATUS
    bpl @vblank1

    ; Clear all RAM while we wait for the second vblank
    lda #0
@clear_ram:
    sta $0000, x
    sta $0100, x
    sta $0200, x
    sta $0300, x
    sta $0400, x
    sta $0500, x
    sta $0600, x
    sta $0700, x
    inx
    bne @clear_ram

    ; Wait for PPU (second vblank)
@vblank2:
    bit PPUSTATUS
    bpl @vblank2
