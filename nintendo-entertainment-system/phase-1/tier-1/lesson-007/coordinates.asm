;===============================================================================
; Lesson 007: Nametables
; Addressing tiles by row and column coordinates
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

    ; Write tile at row 5, column 10
    ; Address = $2000 + (row × 32) + column
    ; Address = $2000 + (5 × 32) + 10
    ; Address = $2000 + 160 + 10 = $2000 + 170 = $20AA

    LDA #$20
    STA $2006
    LDA #$AA
    STA $2006
    LDA #$01                ; Solid tile
    STA $2007

    ; Write tile at row 10, column 15
    ; Address = $2000 + (10 × 32) + 15
    ; Address = $2000 + 320 + 15 = $2000 + 335 = $214F

    LDA #$21
    STA $2006
    LDA #$4F
    STA $2006
    LDA #$01
    STA $2007

    ; Write tile at row 15, column 20
    ; Address = $2000 + (15 × 32) + 20
    ; Address = $2000 + 480 + 20 = $2000 + 500 = $21F4

    LDA #$21
    STA $2006
    LDA #$F4
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
