;===============================================================================
; Lesson 007: Nametables
; Writing tiles to the 32×30 tile grid
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

    ; Load palettes
    LDA #$3F
    STA $2006
    LDA #$00
    STA $2006
    LDA #$0F
    STA $2007
    LDA #$00
    STA $2007
    LDA #$30
    STA $2007
    LDA #$10
    STA $2007

    ; Write some tiles to nametable
    LDA #$20
    STA $2006
    LDA #$00
    STA $2006

    ; Fill first row with solid tiles (tile $01)
    LDX #$00
FirstRow:
    LDA #$01
    STA $2007
    INX
    CPX #$20                ; 32 tiles per row
    BNE FirstRow

    ; Write a few specific tiles
    LDA #$20
    STA $2006
    LDA #$42                ; Row 2, column 2
    STA $2006
    LDA #$01                ; Solid tile
    STA $2007

    LDA #$20
    STA $2006
    LDA #$84                ; Row 4, column 4
    STA $2006
    LDA #$01
    STA $2007

    LDA #%10000000
    STA $2000
    LDA #%00001010          ; Show background
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
    ; Tile $00: Blank
    .byte $00,$00,$00,$00,$00,$00,$00,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00

    ; Tile $01: Solid block
    .byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
    .byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF

    .res 510*16, $00
