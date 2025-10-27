;===============================================================================
; Lesson 009: Sprite Basics
; Creating paddle and ball graphics in CHR-ROM
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

    ; Load palettes (background + sprites)
    LDA #$3F
    STA $2006
    LDA #$00
    STA $2006

    ; Background palettes
    LDX #$00
LoadBGPalettes:
    LDA BGPalettes,X
    STA $2007
    INX
    CPX #$10
    BNE LoadBGPalettes

    ; Sprite palettes
    LDX #$00
LoadSpritePalettes:
    LDA SpritePalettes,X
    STA $2007
    INX
    CPX #$10
    BNE LoadSpritePalettes

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
BGPalettes:
    .byte $0F, $00, $30, $10
    .byte $0F, $00, $30, $10
    .byte $0F, $00, $30, $10
    .byte $0F, $00, $30, $10

SpritePalettes:
    .byte $0F, $00, $30, $10
    .byte $0F, $00, $30, $10
    .byte $0F, $00, $30, $10
    .byte $0F, $00, $30, $10

.segment "VECTORS"
    .word NMI
    .word Reset
    .word IRQ

.segment "CHARS"
    ; Background tiles (pattern table 0, $0000-$0FFF)
    ; Tiles from previous lessons (border, center line)
    .byte $00,$00,$00,$00,$00,$00,$00,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00

    .byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
    .byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF

    .byte $FF,$FF,$00,$00,$00,$00,$00,$00
    .byte $FF,$FF,$00,$00,$00,$00,$00,$00

    .byte $18,$18,$18,$18,$18,$18,$18,$18
    .byte $18,$18,$18,$18,$18,$18,$18,$18

    .res 252*16, $00

    ; Sprite tiles (pattern table 1, $1000-$1FFF)
    ; Tile $00: Paddle top half (8×8)
    .byte $3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C
    .byte $3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C

    ; Tile $01: Paddle bottom half (8×8)
    .byte $3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C
    .byte $3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C

    ; Tile $02: Ball (8×8)
    .byte $00,$18,$3C,$7E,$7E,$3C,$18,$00
    .byte $00,$18,$3C,$7E,$7E,$3C,$18,$00

    .res 253*16, $00
