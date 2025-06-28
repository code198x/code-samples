; Byte Blaster - Lesson 1 Step 1
; Basic NES program structure

; iNES header for emulators
.segment "HEADER"
        .byte "NES", $1A    ; Magic number
        .byte 2             ; 2 × 16KB PRG ROM banks
        .byte 1             ; 1 × 8KB CHR ROM bank  
        .byte $01           ; Mapper 0, vertical mirroring
        .byte $00, $00, $00, $00, $00, $00, $00, $00

; Include standard NES definitions
.include "nes.inc"

; Variables in zero page (fast access)
.segment "ZEROPAGE"
temp:           .res 1

; Main program code
.segment "CODE"

RESET:
        ; Initialize the NES
        SEI             ; Disable interrupts
        CLD             ; Clear decimal mode
        LDX #$40
        STX $4017       ; Disable APU frame IRQ
        LDX #$FF
        TXS             ; Set up stack
        INX             ; X = 0
        STX $2000       ; Disable NMI
        STX $2001       ; Disable rendering
        STX $4010       ; Disable DMC IRQ

        ; Wait for PPU to stabilize
        BIT $2002       ; Clear VBlank flag
vblankwait1:
        BIT $2002       ; Wait for VBlank
        BPL vblankwait1

        ; Clear RAM
clrmem:
        LDA #0
        STA $0000, X
        STA $0100, X
        STA $0200, X
        STA $0300, X
        STA $0400, X
        STA $0500, X
        STA $0600, X
        STA $0700, X
        INX
        BNE clrmem

        ; Wait for second VBlank
vblankwait2:
        BIT $2002
        BPL vblankwait2

        ; Initialize basic setup
        JSR load_simple_palette
        JSR clear_screen
        
        ; Enable rendering
        LDA #%10000000  ; Enable NMI
        STA $2000
        LDA #%00011110  ; Enable sprites and background
        STA $2001

game_loop:
        ; Simple infinite loop
        JMP game_loop

load_simple_palette:
        ; Set PPU address to palette RAM
        LDA $2002       ; Read to reset address latch
        LDA #$3F        ; High byte of palette address
        STA $2006
        LDA #$00        ; Low byte
        STA $2006

        ; Load a simple 4-color background palette
        LDA #$0F        ; Black
        STA $2007
        LDA #$21        ; Blue
        STA $2007
        LDA #$11        ; Light blue
        STA $2007
        LDA #$30        ; White
        STA $2007

        ; Fill remaining background palettes with same colors
        LDX #12         ; 3 more palettes × 4 colors
fill_bg_pal:
        LDA #$0F
        STA $2007
        DEX
        BNE fill_bg_pal

        ; Load a simple sprite palette
        LDA #$0F        ; Black (transparent)
        STA $2007
        LDA #$16        ; Red
        STA $2007
        LDA #$27        ; Orange
        STA $2007
        LDA #$18        ; Yellow
        STA $2007

        ; Fill remaining sprite palettes
        LDX #12
fill_spr_pal:
        LDA #$0F
        STA $2007
        DEX
        BNE fill_spr_pal

        RTS

clear_screen:
        ; Clear nametable (background tiles)
        LDA $2002       ; Reset address latch
        LDA #$20        ; Nametable 0 address
        STA $2006
        LDA #$00
        STA $2006

        ; Fill with tile 0 (blank)
        LDA #$00        ; Tile number 0
        LDX #4          ; 4 pages (1024 bytes total)
        LDY #$00

clear_loop:
        STA $2007       ; Write tile
        INY
        BNE clear_loop  ; 256 times
        DEX
        BNE clear_loop  ; 4 times = 1024 bytes

        RTS

NMI:
        ; Minimal NMI handler
        RTI

IRQ:
        ; IRQ not used
        RTI

; Interrupt vectors
.segment "VECTORS"
        .word NMI       ; NMI vector
        .word RESET     ; Reset vector
        .word IRQ       ; IRQ vector

; Character ROM placeholder
.segment "CHARS"
        .incbin "graphics.chr"