; =============================================================================
; NEON NEXUS - Unit 4: The Background
; =============================================================================
; Add a bordered arena using the nametable.
; =============================================================================

; -----------------------------------------------------------------------------
; NES Hardware Addresses
; -----------------------------------------------------------------------------
PPUCTRL   = $2000
PPUMASK   = $2001
PPUSTATUS = $2002
OAMADDR   = $2003
PPUSCROLL = $2005
PPUADDR   = $2006
PPUDATA   = $2007
OAMDMA    = $4014

JOYPAD1   = $4016
JOYPAD2   = $4017

; Controller buttons
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
PLAYER_START_X = 124
PLAYER_START_Y = 116
PLAYER_SPEED   = 2

; Tile indices
TILE_EMPTY  = 0
TILE_BORDER = 1
TILE_FLOOR  = 2
TILE_PLAYER = 3

; Arena boundaries (in pixels, accounting for border)
ARENA_LEFT   = 16    ; 2 border tiles × 8
ARENA_RIGHT  = 232   ; 256 - 16 - 8 (sprite width)
ARENA_TOP    = 16
ARENA_BOTTOM = 208   ; 240 - 16 - 16 (overscan + border)

; Palette
BG_COLOUR = $0F      ; Black background

; -----------------------------------------------------------------------------
; Memory Layout
; -----------------------------------------------------------------------------
.segment "ZEROPAGE"
player_x:    .res 1
player_y:    .res 1
buttons:     .res 1
temp:        .res 1

.segment "OAM"
oam_buffer:  .res 256

.segment "BSS"

; -----------------------------------------------------------------------------
; iNES Header
; -----------------------------------------------------------------------------
.segment "HEADER"
    .byte "NES", $1A
    .byte 2
    .byte 1
    .byte $01
    .byte $00
    .byte 0,0,0,0,0,0,0,0

; -----------------------------------------------------------------------------
; Code
; -----------------------------------------------------------------------------
.segment "CODE"

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
    jsr load_palette

    ; Draw the arena
    jsr draw_arena

    ; Set up player
    lda #PLAYER_START_X
    sta player_x
    lda #PLAYER_START_Y
    sta player_y

    ; Initialise player sprite
    lda player_y
    sta oam_buffer+0
    lda #TILE_PLAYER
    sta oam_buffer+1
    lda #0
    sta oam_buffer+2
    lda player_x
    sta oam_buffer+3

    ; Hide other sprites
    lda #$FF
    ldx #4
@hide_sprites:
    sta oam_buffer, x
    inx
    bne @hide_sprites

    ; Reset scroll
    lda #0
    sta PPUSCROLL
    sta PPUSCROLL

    ; Enable rendering
    lda #%10000000    ; NMI on, background and sprites from pattern table 0
    sta PPUCTRL
    lda #%00011110    ; Show sprites and background
    sta PPUMASK

; === Main Loop ===
main_loop:
    jsr read_controller
    jsr move_player
    jmp main_loop

; -----------------------------------------------------------------------------
; Load Palette
; -----------------------------------------------------------------------------
load_palette:
    bit PPUSTATUS
    lda #$3F
    sta PPUADDR
    lda #$00
    sta PPUADDR

    ldx #0
@loop:
    lda palette_data, x
    sta PPUDATA
    inx
    cpx #32
    bne @loop
    rts

; -----------------------------------------------------------------------------
; Draw Arena
; -----------------------------------------------------------------------------
draw_arena:
    ; Set PPU address to start of nametable ($2000)
    bit PPUSTATUS
    lda #$20
    sta PPUADDR
    lda #$00
    sta PPUADDR

    ; Draw 30 rows
    ldy #0              ; Row counter

@draw_row:
    ; Check if first row, last row, or middle
    cpy #0
    beq @border_row
    cpy #1
    beq @border_row
    cpy #28
    beq @border_row
    cpy #29
    beq @border_row

    ; Middle row: border + floor + border
    jmp @middle_row

@border_row:
    ; All border tiles
    ldx #32
@border_loop:
    lda #TILE_BORDER
    sta PPUDATA
    dex
    bne @border_loop
    jmp @next_row

@middle_row:
    ; Left border (2 tiles)
    lda #TILE_BORDER
    sta PPUDATA
    sta PPUDATA

    ; Floor (28 tiles)
    ldx #28
@floor_loop:
    lda #TILE_FLOOR
    sta PPUDATA
    dex
    bne @floor_loop

    ; Right border (2 tiles)
    lda #TILE_BORDER
    sta PPUDATA
    sta PPUDATA

@next_row:
    iny
    cpy #30
    bne @draw_row

    rts

; -----------------------------------------------------------------------------
; Read Controller
; -----------------------------------------------------------------------------
read_controller:
    lda #1
    sta JOYPAD1
    lda #0
    sta JOYPAD1

    ldx #8
@read_loop:
    lda JOYPAD1
    lsr a
    rol buttons
    dex
    bne @read_loop
    rts

; -----------------------------------------------------------------------------
; Move Player
; -----------------------------------------------------------------------------
move_player:
    ; UP
    lda buttons
    and #BTN_UP
    beq @check_down
    lda player_y
    sec
    sbc #PLAYER_SPEED
    cmp #ARENA_TOP
    bcc @check_down
    sta player_y

@check_down:
    lda buttons
    and #BTN_DOWN
    beq @check_left
    lda player_y
    clc
    adc #PLAYER_SPEED
    cmp #ARENA_BOTTOM
    bcs @check_left
    sta player_y

@check_left:
    lda buttons
    and #BTN_LEFT
    beq @check_right
    lda player_x
    sec
    sbc #PLAYER_SPEED
    cmp #ARENA_LEFT
    bcc @check_right
    sta player_x

@check_right:
    lda buttons
    and #BTN_RIGHT
    beq @done
    lda player_x
    clc
    adc #PLAYER_SPEED
    cmp #ARENA_RIGHT
    bcs @done
    sta player_x

@done:
    rts

; === NMI ===
nmi:
    pha
    txa
    pha
    tya
    pha

    ; DMA sprites
    lda #0
    sta OAMADDR
    lda #>oam_buffer
    sta OAMDMA

    ; Update sprite position
    lda player_y
    sta oam_buffer+0
    lda player_x
    sta oam_buffer+3

    ; Reset scroll (important after any PPU access)
    lda #0
    sta PPUSCROLL
    sta PPUSCROLL

    pla
    tay
    pla
    tax
    pla
    rti

irq:
    rti

; -----------------------------------------------------------------------------
; Data
; -----------------------------------------------------------------------------
palette_data:
    ; Background palettes
    .byte BG_COLOUR, $12, $21, $30  ; Palette 0: black, blue, cyan (border), white
    .byte BG_COLOUR, $12, $21, $30  ; Palette 1
    .byte BG_COLOUR, $12, $21, $30  ; Palette 2
    .byte BG_COLOUR, $12, $21, $30  ; Palette 3
    ; Sprite palettes
    .byte BG_COLOUR, $30, $20, $16  ; Palette 0: black, white, red, orange
    .byte BG_COLOUR, $30, $20, $16  ; Palette 1
    .byte BG_COLOUR, $30, $20, $16  ; Palette 2
    .byte BG_COLOUR, $30, $20, $16  ; Palette 3

; -----------------------------------------------------------------------------
; Vectors
; -----------------------------------------------------------------------------
.segment "VECTORS"
    .word nmi
    .word reset
    .word irq

; -----------------------------------------------------------------------------
; CHR-ROM
; -----------------------------------------------------------------------------
.segment "CHARS"

; Tile 0: Empty (transparent)
.byte $00,$00,$00,$00,$00,$00,$00,$00
.byte $00,$00,$00,$00,$00,$00,$00,$00

; Tile 1: Border (solid cyan block)
.byte $00,$00,$00,$00,$00,$00,$00,$00  ; Low plane = 0
.byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF  ; High plane = 1 (colour 2 = cyan)

; Tile 2: Floor (empty/dark)
.byte $00,$00,$00,$00,$00,$00,$00,$00
.byte $00,$00,$00,$00,$00,$00,$00,$00

; Tile 3: Player sprite (arrow)
.byte %00011000
.byte %00111100
.byte %01111110
.byte %11111111
.byte %00111100
.byte %00111100
.byte %00111100
.byte %00111100
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000

; Fill rest of CHR-ROM
.res 8192 - 64, $00
