;===============================================================================
; Lesson 005: Pattern Tables
; Basic tile graphics in CHR-ROM
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

    LDA #$3F
    STA $2006
    LDA #$00
    STA $2006
    LDA #$0F
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
    ; Tile $00: Blank
    .byte $00,$00,$00,$00,$00,$00,$00,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00

    ; Tile $01: Solid block
    .byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
    .byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF

    ; Tile $02: Top border (2 pixels thick)
    .byte $FF,$FF,$00,$00,$00,$00,$00,$00
    .byte $FF,$FF,$00,$00,$00,$00,$00,$00

    ; Tile $03: Center line
    .byte $18,$18,$18,$18,$18,$18,$18,$18
    .byte $18,$18,$18,$18,$18,$18,$18,$18

    .res 508*16, $00
