; =============================================================================
; DASH - Unit 1: See Your Character
; =============================================================================
; A running figure on a black screen. The first step toward a platformer.
; =============================================================================

; -----------------------------------------------------------------------------
; NES Hardware Addresses
; -----------------------------------------------------------------------------
PPUCTRL   = $2000           ; PPU control register
PPUMASK   = $2001           ; PPU mask register
PPUSTATUS = $2002           ; PPU status register
OAMADDR   = $2003           ; OAM address
PPUADDR   = $2006           ; PPU address
PPUDATA   = $2007           ; PPU data
OAMDMA    = $4014           ; OAM DMA register

; -----------------------------------------------------------------------------
; Game Constants
; -----------------------------------------------------------------------------
PLAYER_X    = 124           ; Starting X position
PLAYER_Y    = 120           ; Starting Y position
PLAYER_TILE = 1             ; Tile number for the player sprite

; -----------------------------------------------------------------------------
; Memory
; -----------------------------------------------------------------------------
.segment "ZEROPAGE"
player_x:   .res 1          ; Player X position
player_y:   .res 1          ; Player Y position

.segment "OAM"
oam_buffer: .res 256        ; Sprite data (DMA'd to PPU each frame)

.segment "BSS"
; General RAM variables go here

; =============================================================================
; iNES Header
; =============================================================================
.segment "HEADER"
    .byte "NES", $1A        ; Magic number — every NES ROM starts with this
    .byte 2                 ; 2 x 16KB PRG-ROM = 32KB
    .byte 1                 ; 1 x 8KB CHR-ROM = 8KB
    .byte $01               ; Vertical mirroring, Mapper 0
    .byte $00               ; Mapper 0 (NROM)
    .byte 0,0,0,0,0,0,0,0  ; Padding

; =============================================================================
; Code
; =============================================================================
.segment "CODE"

; --- Reset: runs when the NES powers on ---
reset:
    sei                     ; Disable interrupts
    cld                     ; Clear decimal mode (6502 habit, not used on NES)
    ldx #$40
    stx $4017               ; Disable APU frame IRQ
    ldx #$FF
    txs                     ; Set up stack pointer
    inx                     ; X = 0
    stx PPUCTRL             ; Disable NMI
    stx PPUMASK             ; Disable rendering
    stx $4010               ; Disable DMC IRQs

    ; Wait for PPU to stabilise (first vblank)
@vblank1:
    bit PPUSTATUS
    bpl @vblank1

    ; Clear all RAM while we wait for the second vblank
    lda #0
@clear_ram:
    sta $0000, x
    sta $0100, x
    sta $0200, x
    sta $0300, x
    sta $0400, x
    sta $0500, x
    sta $0600, x
    sta $0700, x
    inx
    bne @clear_ram

    ; Wait for PPU (second vblank)
@vblank2:
    bit PPUSTATUS
    bpl @vblank2

    ; === PPU is ready ===

    ; Load palette data into PPU
    bit PPUSTATUS           ; Reset address latch
    lda #$3F
    sta PPUADDR
    lda #$00
    sta PPUADDR             ; PPU address = $3F00 (palette)

    ldx #0
@load_palette:
    lda palette_data, x
    sta PPUDATA
    inx
    cpx #32
    bne @load_palette

    ; Set up player sprite in OAM buffer
    lda #PLAYER_Y
    sta oam_buffer+0        ; Y position
    lda #PLAYER_TILE
    sta oam_buffer+1        ; Tile number
    lda #0
    sta oam_buffer+2        ; Attributes (palette 0, no flip)
    lda #PLAYER_X
    sta oam_buffer+3        ; X position

    ; Store position in variables
    lda #PLAYER_X
    sta player_x
    lda #PLAYER_Y
    sta player_y

    ; Hide all other sprites (Y = $EF moves off visible screen)
    lda #$EF
    ldx #4
@hide_sprites:
    sta oam_buffer, x
    inx
    bne @hide_sprites

    ; Enable rendering
    lda #%10000000          ; Enable NMI
    sta PPUCTRL
    lda #%00011110          ; Show background and sprites
    sta PPUMASK

; --- Main loop ---
main_loop:
    jmp main_loop           ; Nothing to do yet — wait for NMI

; --- NMI: runs every frame during vblank ---
nmi:
    pha                     ; Save A
    txa
    pha                     ; Save X
    tya
    pha                     ; Save Y

    ; Copy OAM buffer to PPU via DMA
    lda #0
    sta OAMADDR
    lda #>oam_buffer        ; High byte of buffer address ($02)
    sta OAMDMA              ; Triggers 256-byte DMA transfer

    pla                     ; Restore Y
    tay
    pla                     ; Restore X
    tax
    pla                     ; Restore A
    rti

; --- IRQ: not used ---
irq:
    rti

; =============================================================================
; Data
; =============================================================================

palette_data:
    ; Background palettes
    .byte $0F, $00, $10, $20   ; Palette 0: black, dark grey, grey, light grey
    .byte $0F, $00, $10, $20   ; Palette 1
    .byte $0F, $00, $10, $20   ; Palette 2
    .byte $0F, $00, $10, $20   ; Palette 3
    ; Sprite palettes
    .byte $0F, $30, $16, $27   ; Palette 0: transparent, white, red, orange
    .byte $0F, $30, $16, $27   ; Palette 1
    .byte $0F, $30, $16, $27   ; Palette 2
    .byte $0F, $30, $16, $27   ; Palette 3

; =============================================================================
; Vectors
; =============================================================================
.segment "VECTORS"
    .word nmi               ; NMI vector (called every vblank)
    .word reset             ; Reset vector (called on power-on)
    .word irq               ; IRQ vector (not used)

; =============================================================================
; CHR-ROM (Graphics)
; =============================================================================
.segment "CHARS"

; Tile 0: Empty (all transparent)
.byte $00,$00,$00,$00,$00,$00,$00,$00  ; Plane 0
.byte $00,$00,$00,$00,$00,$00,$00,$00  ; Plane 1

; Tile 1: Running figure
;
;   ..##....    Head
;   ..##....    Head
;   .####...    Arms + body
;   ..##....    Torso
;   ..##....    Hips
;   ..#.#...    Legs mid-stride
;   .#...#..    Legs apart
;   .#...#..    Feet
;
.byte %00110000             ; Plane 0 (bit 0 of each pixel)
.byte %00110000
.byte %01111000
.byte %00110000
.byte %00110000
.byte %00101000
.byte %01000100
.byte %01000100
.byte %00000000             ; Plane 1 (bit 1 — all zero = colour 1 only)
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000

; Fill rest of CHR-ROM with empty tiles
.res 8192 - 32, $00
