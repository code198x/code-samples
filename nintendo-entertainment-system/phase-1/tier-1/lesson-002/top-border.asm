; Understanding PPU - Example 1: Top Border
; Lesson 002 - Drawing a border across the top
;
; Based on lesson 1, adding a full row of tiles at the top

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
    BIT $2002               ; Read PPUSTATUS
    BPL VBlank1             ; Wait for bit 7 to be set

VBlank2:
    BIT $2002
    BPL VBlank2

    ; Initialize stack
    LDX #$FF
    TXS

    ; Initialize PPU registers
    LDA #$00
    STA $2000               ; PPUCTRL - disable NMI
    STA $2001               ; PPUMASK - disable rendering during setup

    ; Set palette colors
    LDA #$3F                ; Palette address
    STA $2006
    LDA #$00
    STA $2006
    LDA #$02                ; Dark blue background
    STA $2007
    LDA #$30                ; White for tiles
    STA $2007

    ; Clear nametable and attributes
    LDA #$20
    STA $2006
    LDA #$00
    STA $2006

    LDX #$04                ; 4 pages (1024 bytes)
    LDY #$00
    LDA #$00
ClearLoop:
    STA $2007
    INY
    BNE ClearLoop
    DEX
    BNE ClearLoop

    ; Clear attribute table explicitly
    LDA #$23
    STA $2006
    LDA #$C0
    STA $2006

    LDX #64                 ; 64 bytes
    LDA #$00
ClearAttr:
    STA $2007
    DEX
    BNE ClearAttr

    ; Draw top border - 32 tiles across row 0
    LDA #$20
    STA $2006
    LDA #$00
    STA $2006

    LDX #32                 ; 32 tiles wide
    LDA #$01                ; Tile $01 (solid white)
DrawTop:
    STA $2007
    DEX
    BNE DrawTop

    ; Reset scroll position
    LDA #$00
    STA $2005               ; PPUSCROLL X
    STA $2005               ; PPUSCROLL Y

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
    .word NMI               ; $FFFA: NMI vector
    .word Reset             ; $FFFC: Reset vector
    .word IRQ               ; $FFFE: IRQ vector

.segment "CHARS"
    ; Tile $00: Blank
    .byte $00, $00, $00, $00, $00, $00, $00, $00
    .byte $00, $00, $00, $00, $00, $00, $00, $00

    ; Tile $01: Solid white (color 1)
    .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    .byte $00, $00, $00, $00, $00, $00, $00, $00

    .res 8192 - 32, $00
