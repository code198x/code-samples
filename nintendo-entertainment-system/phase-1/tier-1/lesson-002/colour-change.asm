;===============================================================================
; Lesson 002: Understanding PPU
; Example 1: Change Background Colour
;
; Demonstrates:
; - PPU register usage ($2006, $2007)
; - Palette memory access ($3F00)
; - Setting background colour
;===============================================================================

.segment "HEADER"
    .byte "NES", $1A        ; iNES magic identifier
    .byte 2                  ; 2 x 16KB PRG-ROM banks
    .byte 1                  ; 1 x 8KB CHR-ROM bank
    .byte $01, $00          ; Mapper 0, vertical mirroring

.segment "CODE"
Reset:
    SEI                     ; Disable interrupts
    CLD                     ; Clear decimal mode

    ; Wait for PPU warmup (2 VBlanks)
    BIT $2002
:   BIT $2002
    BPL :-
:   BIT $2002
    BPL :-

    ; Set PPU address to palette memory
    LDA #$3F                ; High byte of $3F00
    STA $2006               ; Write to PPUADDR
    LDA #$00                ; Low byte of $3F00
    STA $2006               ; Write to PPUADDR again

    ; Write colour to palette
    LDA #$12                ; Colour $12 (blue)
    STA $2007               ; Write to PPUDATA

    ; Enable rendering
    LDA #%00001000          ; Enable background rendering
    STA $2001               ; Write to PPUMASK

Forever:
    JMP Forever

NMI:
    RTI                     ; Return from interrupt (placeholder)

IRQ:
    RTI                     ; Return from interrupt (placeholder)

.segment "VECTORS"
    .word NMI               ; $FFFA: NMI handler
    .word Reset             ; $FFFC: Reset handler
    .word IRQ               ; $FFFE: IRQ handler

.segment "CHARS"
    .res 8192, $00          ; 8KB CHR-ROM (blank for now)
