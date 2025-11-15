; Minimal test - just try to show ANY tile on screen

.segment "HEADER"
    .byte "NES", $1A
    .byte 2
    .byte 1
    .byte $01, $00

.segment "CODE"

Reset:
    SEI
    CLD

    ; Wait for PPU warmup
    LDX #$00
:   BIT $2002
    BPL :-
:   BIT $2002
    BPL :-

    ; Initialize stack
    LDX #$FF
    TXS

    ; Disable rendering
    LDA #$00
    STA $2000
    STA $2001

    ; Set palette - just one color for tiles
    LDA #$3F
    STA $2006
    LDA #$00
    STA $2006
    LDA #$0F                ; Black background
    STA $2007
    LDA #$30                ; White for color 1
    STA $2007
    LDA #$30                ; White for color 2
    STA $2007
    LDA #$30                ; White for color 3
    STA $2007

    ; Fill entire nametable with tile $00 (blank)
    LDA #$20
    STA $2006
    LDA #$00
    STA $2006

    LDY #$00                ; Initialize Y
    LDX #$04                ; 4 pages of 256 = 1024 tiles
    LDA #$00
:   STA $2007
    INY
    BNE :-
    DEX
    BNE :--

    ; Now write ONE tile ($01) to center of screen
    ; Center is approximately row 15, column 16
    ; Address = $2000 + (15 * 32) + 16 = $2000 + 480 + 16 = $2000 + $1F0 = $21F0
    LDA #$21
    STA $2006
    LDA #$F0
    STA $2006
    LDA #$01                ; Tile $01
    STA $2007

    ; Reset scroll
    LDA #$00
    STA $2005
    STA $2005

    ; Enable rendering
    LDA #%00001000
    STA $2001

MainLoop:
    JMP MainLoop

NMI:
    RTI

IRQ:
    RTI

.segment "VECTORS"
    .word NMI
    .word Reset
    .word IRQ

.segment "CHARS"
    ; Tile $00: All black (color 0)
    .byte $00, $00, $00, $00, $00, $00, $00, $00
    .byte $00, $00, $00, $00, $00, $00, $00, $00

    ; Tile $01: All white (color 3 = both bits set)
    .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF

    .res 8192 - 32, $00
