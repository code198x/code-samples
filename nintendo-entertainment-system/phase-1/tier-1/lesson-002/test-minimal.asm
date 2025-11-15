; Hello, NES World
; Your first NES program
;
; This program initializes the NES and displays a solid background color.
; It demonstrates the minimal structure needed for any NES program.

; iNES Header (tells emulators about this ROM)
.segment "HEADER"
    .byte "NES", $1A        ; iNES magic identifier
    .byte 2                  ; 2 x 16KB PRG-ROM banks
    .byte 1                  ; 1 x 8KB CHR-ROM bank
    .byte $01, $00          ; Mapper 0, vertical mirroring

; PRG-ROM: Program code and data
.segment "CODE"

; Reset vector - execution starts here
Reset:
    SEI                     ; Disable interrupts
    CLD                     ; Clear decimal mode (NES 6502 has no decimal mode)

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
    STA $2000               ; PPUCTRL - disable NMI, sprites, background
    STA $2001               ; PPUMASK - disable rendering during setup

    ; Set background color to dark blue
    LDA #$3F                ; High byte of palette address
    STA $2006               ; PPUADDR
    LDA #$00                ; Low byte of palette address
    STA $2006               ; PPUADDR
    LDA #$02                ; Dark blue color
    STA $2007               ; PPUDATA - write to palette

    ; NEW: Add tile color (auto-increments to $3F01)
    LDA #$30                ; White
    STA $2007

    ; NEW: Clear nametable (fill with tile $00)
    LDA #$20                ; Nametable address high
    STA $2006
    LDA #$00                ; Nametable address low
    STA $2006

    LDX #$04                ; 4 pages (1024 bytes total for nametable + attributes)
    LDY #$00
    LDA #$00                ; Tile $00 (blank) and attribute $00 (palette 0)
ClearLoop:
    STA $2007
    INY
    BNE ClearLoop
    DEX
    BNE ClearLoop

    ; Explicitly clear attribute table at $23C0-$23FF (64 bytes)
    ; Attribute $00 means all tiles use palette 0
    LDA #$23
    STA $2006
    LDA #$C0
    STA $2006

    LDX #64                 ; 64 bytes of attribute table
    LDA #$00                ; Use palette 0 for everything
ClearAttr:
    STA $2007
    DEX
    BNE ClearAttr

    ; NEW: Write ONE tile to top-left of screen
    LDA #$20                ; Nametable address high
    STA $2006
    LDA #$00                ; Nametable address low
    STA $2006
    LDA #$01                ; Tile $01
    STA $2007

    ; Reset scroll position
    LDA #$00
    STA $2005               ; PPUSCROLL X
    STA $2005               ; PPUSCROLL Y (write twice)

    ; Enable rendering
    LDA #%00001010          ; Enable background + show leftmost 8 pixels
    STA $2001               ; PPUMASK

    ; Main loop - just wait forever
MainLoop:
    JMP MainLoop

; NMI vector - called every frame during vblank
NMI:
    RTI                     ; Return from interrupt

; IRQ vector - not used
IRQ:
    RTI

; Interrupt vectors at end of PRG-ROM
.segment "VECTORS"
    .word NMI               ; $FFFA: NMI vector
    .word Reset             ; $FFFC: Reset vector
    .word IRQ               ; $FFFE: IRQ vector

; CHR-ROM: Graphics data
.segment "CHARS"
    ; Tile $00: Empty
    .byte $00, $00, $00, $00, $00, $00, $00, $00
    .byte $00, $00, $00, $00, $00, $00, $00, $00

    ; Tile $01: Solid white (color 1 - only plane 0 set)
    .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    .byte $00, $00, $00, $00, $00, $00, $00, $00

    .res 8192 - 32, $00     ; Fill rest
