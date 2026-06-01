; =============================================================================
; NEON NEXUS - Unit 1: Hello NES
; =============================================================================
; Your first NES program. A sprite on a coloured background.
; Run it. Change the colours. Move the sprite. Make it yours.
; =============================================================================

; -----------------------------------------------------------------------------
; NES Hardware Addresses
; -----------------------------------------------------------------------------
PPUCTRL   = $2000     ; PPU control register
PPUMASK   = $2001     ; PPU mask register
PPUSTATUS = $2002     ; PPU status register
OAMADDR   = $2003     ; OAM address
PPUADDR   = $2006     ; PPU address
PPUDATA   = $2007     ; PPU data
OAMDMA    = $4014     ; OAM DMA register

; -----------------------------------------------------------------------------
; Game Constants
; -----------------------------------------------------------------------------
; Try changing these values and see what happens!
PLAYER_START_X = 124  ; Player X position (0-247)
PLAYER_START_Y = 116  ; Player Y position (0-231)
PLAYER_TILE    = 1    ; Which tile to use for the player
BG_COLOUR      = $12  ; Background colour (try $01, $21, $31, $0F)

; -----------------------------------------------------------------------------
; Memory Layout
; -----------------------------------------------------------------------------
.segment "ZEROPAGE"
player_x:    .res 1   ; Player X position
player_y:    .res 1   ; Player Y position

.segment "OAM"
oam_buffer:  .res 256 ; Sprite data (copied to PPU each frame)

.segment "BSS"
; General RAM variables go here

; -----------------------------------------------------------------------------
; iNES Header
; -----------------------------------------------------------------------------
.segment "HEADER"
    .byte "NES", $1A  ; iNES identifier
    .byte 2           ; 2x 16KB PRG-ROM = 32KB
    .byte 1           ; 1x 8KB CHR-ROM = 8KB
    .byte $01         ; Mapper 0, vertical mirroring
    .byte $00         ; Mapper 0
    .byte 0,0,0,0,0,0,0,0 ; Padding

; -----------------------------------------------------------------------------
; Code
; -----------------------------------------------------------------------------
.segment "CODE"

; === RESET: Called when NES powers on ===
reset:
    sei              ; Disable interrupts
    cld              ; Clear decimal mode
    ldx #$40
    stx $4017        ; Disable APU frame IRQ
    ldx #$FF
    txs              ; Set up stack
    inx              ; X = 0
    stx PPUCTRL      ; Disable NMI
    stx PPUMASK      ; Disable rendering
    stx $4010        ; Disable DMC IRQs

    ; Wait for PPU to stabilise (first wait)
@vblank1:
    bit PPUSTATUS
    bpl @vblank1

    ; Clear RAM while we wait
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

    ; Wait for PPU (second wait)
@vblank2:
    bit PPUSTATUS
    bpl @vblank2

    ; === PPU is ready - set up graphics ===

    ; Load palette
    bit PPUSTATUS    ; Reset PPU address latch
    lda #$3F
    sta PPUADDR
    lda #$00
    sta PPUADDR      ; PPU address = $3F00 (palette)

    ldx #0
@load_palette:
    lda palette_data, x
    sta PPUDATA
    inx
    cpx #32
    bne @load_palette

    ; Set up player sprite
    lda #PLAYER_START_X
    sta player_x
    lda #PLAYER_START_Y
    sta player_y

    ; Initialise sprite in OAM buffer
    lda player_y
    sta oam_buffer+0  ; Y position
    lda #PLAYER_TILE
    sta oam_buffer+1  ; Tile number
    lda #0
    sta oam_buffer+2  ; Attributes (palette 0, no flip)
    lda player_x
    sta oam_buffer+3  ; X position

    ; Hide all other sprites (move off screen)
    lda #$FF
    ldx #4
@hide_sprites:
    sta oam_buffer, x
    inx
    bne @hide_sprites

    ; Enable rendering
    lda #%10010000    ; Enable NMI, sprites from pattern table 1
    sta PPUCTRL
    lda #%00011110    ; Show sprites and background
    sta PPUMASK

    ; === Main Loop ===
main_loop:
    jmp main_loop     ; Wait for NMI (nothing to do yet!)

; === NMI: Called every frame during VBlank ===
nmi:
    pha              ; Save registers
    txa
    pha
    tya
    pha

    ; Copy sprite data to PPU
    lda #0
    sta OAMADDR
    lda #>oam_buffer ; High byte of $0200
    sta OAMDMA       ; Triggers DMA transfer

    ; Update sprite position from variables
    lda player_y
    sta oam_buffer+0
    lda player_x
    sta oam_buffer+3

    pla              ; Restore registers
    tay
    pla
    tax
    pla
    rti

; === IRQ: Not used ===
irq:
    rti

; -----------------------------------------------------------------------------
; Data
; -----------------------------------------------------------------------------

; Palette data: 4 background palettes + 4 sprite palettes
palette_data:
    ; Background palettes
    .byte BG_COLOUR, $00, $10, $20  ; Palette 0 (background colour)
    .byte BG_COLOUR, $00, $10, $20  ; Palette 1
    .byte BG_COLOUR, $00, $10, $20  ; Palette 2
    .byte BG_COLOUR, $00, $10, $20  ; Palette 3
    ; Sprite palettes
    .byte BG_COLOUR, $30, $20, $0F  ; Palette 0 (player: white, red, black)
    .byte BG_COLOUR, $30, $16, $0F  ; Palette 1
    .byte BG_COLOUR, $30, $12, $0F  ; Palette 2
    .byte BG_COLOUR, $30, $14, $0F  ; Palette 3

; -----------------------------------------------------------------------------
; Vectors
; -----------------------------------------------------------------------------
.segment "VECTORS"
    .word nmi        ; NMI vector
    .word reset      ; Reset vector
    .word irq        ; IRQ vector

; -----------------------------------------------------------------------------
; CHR-ROM (Graphics)
; -----------------------------------------------------------------------------
.segment "CHARS"

; Tile 0: Empty (8x8 pixels, all zeros)
.byte $00,$00,$00,$00,$00,$00,$00,$00
.byte $00,$00,$00,$00,$00,$00,$00,$00

; Tile 1: Player sprite (simple arrow shape)
; Each tile is 16 bytes: 8 bytes low plane + 8 bytes high plane
; Colours: 00=transparent, 01=colour 1, 10=colour 2, 11=colour 3
.byte %00011000  ; Row 0
.byte %00111100  ; Row 1
.byte %01111110  ; Row 2
.byte %11111111  ; Row 3
.byte %00111100  ; Row 4
.byte %00111100  ; Row 5
.byte %00111100  ; Row 6
.byte %00111100  ; Row 7
; High plane (all zeros = use colour 1 only)
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000

; Fill rest of CHR-ROM with empty tiles
.res 8192 - 32, $00
