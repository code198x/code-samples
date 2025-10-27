;===============================================================================
; Lesson 002: Understanding PPU
; Example 2: Full Palette Setup
;
; Demonstrates:
; - Loading multiple palette colours
; - Understanding palette structure (4 colours each)
; - Background palette $3F00-$3F0F
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

    ; Set PPU address to background palette 0
    LDA #$3F                ; High byte of $3F00
    STA $2006               ; Write to PPUADDR
    LDA #$00                ; Low byte of $3F00
    STA $2006               ; Write to PPUADDR again

    ; Load palette 0 (4 colours)
    LDA #$0F                ; Colour 0: Black
    STA $2007
    LDA #$12                ; Colour 1: Blue
    STA $2007
    LDA #$16                ; Colour 2: Red
    STA $2007
    LDA #$27                ; Colour 3: Orange
    STA $2007

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
