; =============================================================================
; DASH - Unit 2: Controller Input
; =============================================================================
; The figure moves. Read the NES controller to walk left and right.
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
JOYPAD1   = $4016           ; Controller port 1

; -----------------------------------------------------------------------------
; Button Masks
; -----------------------------------------------------------------------------
; After reading all 8 buttons into one byte, each bit maps to a button:
BTN_A      = %10000000
BTN_B      = %01000000
BTN_SELECT = %00100000
BTN_START  = %00010000
BTN_UP     = %00001000
BTN_DOWN   = %00000100
BTN_LEFT   = %00000010
BTN_RIGHT  = %00000001

; -----------------------------------------------------------------------------
; Game Constants
; -----------------------------------------------------------------------------
PLAYER_X    = 124           ; Starting X position
PLAYER_Y    = 120           ; Starting Y position
PLAYER_TILE = 1             ; Tile number for the player sprite
RIGHT_WALL  = 248           ; Rightmost X position (256 - 8px sprite width)

; -----------------------------------------------------------------------------
; Memory
; -----------------------------------------------------------------------------
.segment "ZEROPAGE"
player_x:   .res 1          ; Player X position
player_y:   .res 1          ; Player Y position
buttons:    .res 1          ; Current button state (packed byte)
nmi_flag:   .res 1          ; Set by NMI, cleared by main loop

.segment "OAM"
oam_buffer: .res 256        ; Sprite data (DMA'd to PPU each frame)

.segment "BSS"

; =============================================================================
; iNES Header
; =============================================================================
.segment "HEADER"
    .byte "NES", $1A        ; Magic number
    .byte 2                 ; 2 x 16KB PRG-ROM = 32KB
    .byte 1                 ; 1 x 8KB CHR-ROM = 8KB
    .byte $01               ; Vertical mirroring, Mapper 0
    .byte $00               ; Mapper 0 (NROM)
    .byte 0,0,0,0,0,0,0,0  ; Padding

; =============================================================================
; Code
; =============================================================================
.segment "CODE"

; --- Reset ---
reset:
    sei
    cld
    ldx #$40
    stx $4017
    ldx #$FF
    txs
    inx
    stx PPUCTRL
    stx PPUMASK
    stx $4010

@vblank1:
    bit PPUSTATUS
    bpl @vblank1

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

@vblank2:
    bit PPUSTATUS
    bpl @vblank2

    ; Load palette
    bit PPUSTATUS
    lda #$3F
    sta PPUADDR
    lda #$00
    sta PPUADDR

    ldx #0
@load_palette:
    lda palette_data, x
    sta PPUDATA
    inx
    cpx #32
    bne @load_palette

    ; Set up player sprite
    lda #PLAYER_Y
    sta oam_buffer+0
    lda #PLAYER_TILE
    sta oam_buffer+1
    lda #0
    sta oam_buffer+2
    lda #PLAYER_X
    sta oam_buffer+3

    lda #PLAYER_X
    sta player_x
    lda #PLAYER_Y
    sta player_y

    ; Hide other sprites
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

; =============================================================================
; Main Loop
; =============================================================================
main_loop:
    lda nmi_flag            ; Has a new frame started?
    beq main_loop           ; No — keep waiting
    lda #0
    sta nmi_flag            ; Clear the flag

    ; --- Read controller ---
    lda #1
    sta JOYPAD1             ; Strobe on: latch button states
    lda #0
    sta JOYPAD1             ; Strobe off: begin serial output

    ldx #8                  ; 8 buttons to read
@read_pad:
    lda JOYPAD1             ; Read next button (bit 0)
    lsr a                   ; Shift bit 0 into carry
    rol buttons             ; Roll carry into buttons byte
    dex
    bne @read_pad

    ; --- Move player left/right ---
    lda buttons
    and #BTN_LEFT           ; Left pressed?
    beq @not_left
    lda player_x
    beq @not_left           ; Already at left edge (X = 0)
    dec player_x
@not_left:

    lda buttons
    and #BTN_RIGHT          ; Right pressed?
    beq @not_right
    lda player_x
    cmp #RIGHT_WALL
    bcs @not_right          ; At or past right edge
    inc player_x
@not_right:

    ; --- Update sprite position in OAM buffer ---
    lda player_y
    sta oam_buffer+0        ; Y position
    lda player_x
    sta oam_buffer+3        ; X position

    jmp main_loop

; =============================================================================
; NMI Handler
; =============================================================================
nmi:
    pha
    txa
    pha
    tya
    pha

    ; OAM DMA
    lda #0
    sta OAMADDR
    lda #>oam_buffer
    sta OAMDMA

    ; Signal the main loop that a frame has passed
    lda #1
    sta nmi_flag

    pla
    tay
    pla
    tax
    pla
    rti

; --- IRQ: not used ---
irq:
    rti

; =============================================================================
; Data
; =============================================================================

palette_data:
    ; Background palettes
    .byte $0F, $00, $10, $20
    .byte $0F, $00, $10, $20
    .byte $0F, $00, $10, $20
    .byte $0F, $00, $10, $20
    ; Sprite palettes
    .byte $0F, $30, $16, $27   ; Palette 0: white, red, orange
    .byte $0F, $30, $16, $27
    .byte $0F, $30, $16, $27
    .byte $0F, $30, $16, $27

; =============================================================================
; Vectors
; =============================================================================
.segment "VECTORS"
    .word nmi
    .word reset
    .word irq

; =============================================================================
; CHR-ROM
; =============================================================================
.segment "CHARS"

; Tile 0: Empty
.byte $00,$00,$00,$00,$00,$00,$00,$00
.byte $00,$00,$00,$00,$00,$00,$00,$00

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
.byte %00110000
.byte %00110000
.byte %01111000
.byte %00110000
.byte %00110000
.byte %00101000
.byte %01000100
.byte %01000100
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000

; Fill rest of CHR-ROM
.res 8192 - 32, $00
