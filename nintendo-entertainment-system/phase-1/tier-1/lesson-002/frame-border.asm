; Understanding PPU - Example 2: Frame Border
; Lesson 002 - Drawing a complete frame around the screen
;
; Based on lesson 1, drawing borders on all four edges

; iNES Header
.segment "HEADER"
    .byte "NES", $1A        ; iNES magic identifier
    .byte 2                  ; 2 x 16KB PRG-ROM banks
    .byte 1                  ; 1 x 8KB CHR-ROM bank
    .byte $01, $00          ; Mapper 0, vertical mirroring

; Program code
.segment "CODE"

Reset:
    SEI                     ; Disable interrupts
    CLD                     ; Clear decimal mode

    ; Wait for PPU to be ready (2 vblanks)
    LDX #$00
VBlank1:
    BIT $2002
    BPL VBlank1

VBlank2:
    BIT $2002
    BPL VBlank2

    ; Initialize stack
    LDX #$FF
    TXS

    ; Initialize PPU registers
    LDA #$00
    STA $2000               ; PPUCTRL
    STA $2001               ; PPUMASK

    ; Set palette colors
    LDA #$3F
    STA $2006
    LDA #$00
    STA $2006
    LDA #$02                ; Dark blue background
    STA $2007
    LDA #$30                ; White for tiles
    STA $2007

    ; Clear nametable
    LDA #$20
    STA $2006
    LDA #$00
    STA $2006

    LDX #$04
    LDY #$00
    LDA #$00
ClearLoop:
    STA $2007
    INY
    BNE ClearLoop
    DEX
    BNE ClearLoop

    ; Clear attribute table
    LDA #$23
    STA $2006
    LDA #$C0
    STA $2006

    LDX #64
    LDA #$00
ClearAttr:
    STA $2007
    DEX
    BNE ClearAttr

    ; Draw top border (row 0, all 32 tiles)
    LDA #$20
    STA $2006
    LDA #$00
    STA $2006

    LDX #32
    LDA #$01
DrawTop:
    STA $2007
    DEX
    BNE DrawTop

    ; Draw bottom border (row 29)
    ; Address = $2000 + (29 * 32) = $23A0
    LDA #$23
    STA $2006
    LDA #$A0
    STA $2006

    LDX #32
    LDA #$01
DrawBottom:
    STA $2007
    DEX
    BNE DrawBottom

    ; Draw left side (rows 1-28, column 0)
    LDY #1                  ; Start at row 1

DrawLeft:
    ; Address = $2000 + (Y * 32)
    ; Need to calculate high byte based on row
    LDA #$20
    CPY #8                  ; Rows 8-15 need $21xx
    BCC :+
    LDA #$21
:   CPY #16                 ; Rows 16-23 need $22xx
    BCC :+
    LDA #$22
:   CPY #24                 ; Rows 24-29 need $23xx
    BCC :+
    LDA #$23
:   STA $2006               ; Write high byte

    TYA                     ; Y * 32
    ASL
    ASL
    ASL
    ASL
    ASL
    STA $2006               ; Write low byte

    LDA #$01
    STA $2007

    INY
    CPY #29                 ; Stop before row 29
    BNE DrawLeft

    ; Draw right side (rows 1-28, column 31)
    LDY #1

DrawRight:
    ; Address = $2000 + (Y * 32) + 31
    LDA #$20
    CPY #8
    BCC :+
    LDA #$21
:   CPY #16
    BCC :+
    LDA #$22
:   CPY #24
    BCC :+
    LDA #$23
:   STA $2006

    TYA
    ASL
    ASL
    ASL
    ASL
    ASL
    CLC
    ADC #31
    STA $2006

    LDA #$01
    STA $2007

    INY
    CPY #29
    BNE DrawRight

    ; Reset scroll
    LDA #$00
    STA $2005
    STA $2005

    ; Enable rendering
    LDA #%00001010          ; Enable background + leftmost 8 pixels
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
    ; Tile $00: Blank
    .byte $00, $00, $00, $00, $00, $00, $00, $00
    .byte $00, $00, $00, $00, $00, $00, $00, $00

    ; Tile $01: Solid white (color 1)
    .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    .byte $00, $00, $00, $00, $00, $00, $00, $00

    .res 8192 - 32, $00
