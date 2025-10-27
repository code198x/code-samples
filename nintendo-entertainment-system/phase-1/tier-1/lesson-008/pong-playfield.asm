;===============================================================================
; Lesson 008: Playfield
; Complete Pong court with borders and center line
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
    JSR LoadPalettes

    ; Draw playfield
    JSR DrawPlayfield

    ; Enable rendering
    LDA #%10000000
    STA $2000
    LDA #%00001010
    STA $2001

Forever:
    JMP Forever

;===============================================================================
; LoadPalettes - Load background palettes
;===============================================================================
LoadPalettes:
    LDA #$3F
    STA $2006
    LDA #$00
    STA $2006

    LDX #$00
LoadPalettesLoop:
    LDA PongPalettes,X
    STA $2007
    INX
    CPX #$10
    BNE LoadPalettesLoop
    RTS

;===============================================================================
; DrawPlayfield - Draw complete Pong court
;===============================================================================
DrawPlayfield:
    ; Clear nametable
    JSR ClearNametable

    ; Draw top border (2 rows)
    LDA #$20
    STA $2006
    LDA #$00
    STA $2006
    LDX #$00
TopBorder1:
    LDA #$02                ; Top border tile
    STA $2007
    INX
    CPX #$20
    BNE TopBorder1

    LDA #$20
    STA $2006
    LDA #$20
    STA $2006
    LDX #$00
TopBorder2:
    LDA #$02
    STA $2007
    INX
    CPX #$20
    BNE TopBorder2

    ; Draw bottom border (2 rows)
    LDA #$23
    STA $2006
    LDA #$60
    STA $2006
    LDX #$00
BottomBorder1:
    LDA #$02
    STA $2007
    INX
    CPX #$20
    BNE BottomBorder1

    LDA #$23
    STA $2006
    LDA #$80
    STA $2006
    LDX #$00
BottomBorder2:
    LDA #$02
    STA $2007
    INX
    CPX #$20
    BNE BottomBorder2

    ; Draw center line (column 15, rows 2-27)
    LDY #$02
CenterLineLoop:
    LDA #$20
    STA $2006
    TYA
    ASL
    ASL
    ASL
    ASL
    ASL                     ; Y × 32
    CLC
    ADC #$0F                ; Add column 15
    STA $2006
    LDA #$03                ; Center line tile
    STA $2007
    INY
    CPY #$1C                ; Row 28
    BNE CenterLineLoop
    RTS

;===============================================================================
; ClearNametable - Fill nametable with blank tiles
;===============================================================================
ClearNametable:
    LDA #$20
    STA $2006
    LDA #$00
    STA $2006
    LDX #$00
    LDY #$00
ClearLoop:
    LDA #$00
    STA $2007
    INX
    BNE ClearLoop
    INY
    CPY #$04
    BNE ClearLoop
    RTS

NMI:
    RTI

IRQ:
    RTI

.segment "RODATA"
PongPalettes:
    .byte $0F               ; Universal background (black)
    .byte $00, $30, $10     ; Palette 0 (black/white/grey)
    .byte $00, $30, $10     ; Palette 1 (same)
    .byte $00, $30, $10     ; Palette 2 (same)
    .byte $00, $30, $10     ; Palette 3 (same)

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

    ; Tile $03: Center line (2 pixels wide)
    .byte $18,$18,$18,$18,$18,$18,$18,$18
    .byte $18,$18,$18,$18,$18,$18,$18,$18

    .res 508*16, $00
