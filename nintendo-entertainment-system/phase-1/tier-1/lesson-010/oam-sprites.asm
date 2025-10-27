;===============================================================================
; Lesson 010: OAM Structure
; Displaying sprites using Object Attribute Memory
;===============================================================================

.segment "HEADER"
    .byte "NES", $1A
    .byte 2
    .byte 1
    .byte $01, $00

.segment "ZEROPAGE"
paddle_y: .res 1

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
    JSR LoadPalettes

    ; Initialize paddle position
    LDA #100
    STA paddle_y

    ; Set up sprite in OAM buffer
    LDA paddle_y
    STA $0200           ; Sprite 0: Y position
    LDA #$00
    STA $0201           ; Tile index $00 (paddle top in 8×16 mode)
    LDA #%00000000      ; Palette 0, no flip
    STA $0202           ; Attributes
    LDA #16
    STA $0203           ; X position

    ; Hide remaining sprites (Y = $FF)
    LDX #$04
    LDA #$FF
:   STA $0200,X
    INX
    INX
    INX
    INX
    BNE :-

    ; Enable rendering (8×16 sprites, pattern table 1)
    LDA #%10100000      ; NMI, 8×16 sprites, sprites use table 1
    STA $2000

    LDA #%00011110      ; Show background and sprites
    STA $2001

Forever:
    JMP Forever

LoadPalettes:
    LDA #$3F
    STA $2006
    LDA #$00
    STA $2006
    LDX #$00
:   LDA Palettes,X
    STA $2007
    INX
    CPX #$20            ; 32 bytes (BG + sprites)
    BNE :-
    RTS

NMI:
    RTI

IRQ:
    RTI

.segment "RODATA"
Palettes:
    ; Background palettes
    .byte $0F, $00, $30, $10
    .byte $0F, $00, $30, $10
    .byte $0F, $00, $30, $10
    .byte $0F, $00, $30, $10
    ; Sprite palettes
    .byte $0F, $00, $30, $10
    .byte $0F, $00, $30, $10
    .byte $0F, $00, $30, $10
    .byte $0F, $00, $30, $10

.segment "VECTORS"
    .word NMI
    .word Reset
    .word IRQ

.segment "CHARS"
    ; Background tiles
    .res 256*16, $00

    ; Sprite tiles
    ; Paddle (8×16)
    .byte $3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C
    .byte $3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C
    .byte $3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C
    .byte $3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C
    ; Ball
    .byte $00,$18,$3C,$7E,$7E,$3C,$18,$00
    .byte $00,$18,$3C,$7E,$7E,$3C,$18,$00

    .res 253*16, $00
