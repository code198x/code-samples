;===============================================================================
; Lesson 006: Palettes
; Loading background palettes for NES graphics
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

    ; Load background palettes
    LDA #$3F
    STA $2006
    LDA #$00
    STA $2006

    ; Universal background colour
    LDA #$0F                ; Black
    STA $2007

    ; Palette 0 (Pong classic: black/white/grey)
    LDA #$00                ; Black (transparent)
    STA $2007
    LDA #$30                ; White
    STA $2007
    LDA #$10                ; Light grey
    STA $2007

    ; Palette 1 (unused for now)
    LDA #$00
    STA $2007
    LDA #$00
    STA $2007
    LDA #$00
    STA $2007

    ; Palette 2 (unused)
    LDA #$00
    STA $2007
    LDA #$00
    STA $2007
    LDA #$00
    STA $2007

    ; Palette 3 (unused)
    LDA #$00
    STA $2007
    LDA #$00
    STA $2007
    LDA #$00
    STA $2007

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

.segment "VECTORS"
    .word NMI
    .word Reset
    .word IRQ

.segment "CHARS"
    .res 8192, $00
