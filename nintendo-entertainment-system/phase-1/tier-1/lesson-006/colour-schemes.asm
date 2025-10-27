;===============================================================================
; Lesson 006: Palettes
; Different colour schemes using palette data
;===============================================================================

.segment "HEADER"
    .byte "NES", $1A
    .byte 2
    .byte 1
    .byte $01, $00

.segment "CODE"
Reset:
    SEI
    CLD
    BIT $2002
:   BIT $2002
    BPL :-
:   BIT $2002
    BPL :-
    LDX #$FF
    TXS

    ; Load all background palettes from table
    LDA #$3F
    STA $2006
    LDA #$00
    STA $2006

    LDX #$00
LoadPalettes:
    LDA PongPalettes,X
    STA $2007
    INX
    CPX #$10
    BNE LoadPalettes

    LDA #%10000000
    STA $2000
    LDA #%00001000
    STA $2001

Forever:
    JMP Forever

NMI:
    RTI

IRQ:
    RTI

.segment "RODATA"
PongPalettes:
    ; Universal background
    .byte $0F               ; Black

    ; Palette 0: Playfield (black/white)
    .byte $00, $30, $10

    ; Palette 1: Borders (black/cyan/white)
    .byte $00, $2C, $30

    ; Palette 2: Center line (black/red/white)
    .byte $00, $16, $30

    ; Palette 3: Unused
    .byte $00, $00, $00

.segment "VECTORS"
    .word NMI
    .word Reset
    .word IRQ

.segment "CHARS"
    .res 8192, $00
