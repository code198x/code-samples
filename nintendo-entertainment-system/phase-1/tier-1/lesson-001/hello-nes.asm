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

    ; Set background color to dark blue
    LDA #$3F                ; High byte of palette address
    STA $2006               ; PPUADDR
    LDA #$00                ; Low byte of palette address
    STA $2006               ; PPUADDR
    LDA #$02                ; Dark blue color
    STA $2007               ; PPUDATA - write to palette

    ; Enable rendering
    LDA #%00001000          ; Enable background rendering
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

; CHR-ROM: Graphics data (empty for now)
.segment "CHARS"
    .res 8192, $00          ; 8KB of blank tile data
