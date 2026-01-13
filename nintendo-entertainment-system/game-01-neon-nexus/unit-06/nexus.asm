; =============================================================================
; NEON NEXUS - Unit 6: Colour and Attributes
; =============================================================================
; Use the attribute table to add colour regions to the arena.
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

; Tile indices (background)
TILE_EMPTY     = 0
TILE_BORDER    = 1
TILE_FLOOR     = 2
TILE_CORNER_TL = 3
TILE_CORNER_TR = 4
TILE_CORNER_BL = 5
TILE_CORNER_BR = 6

; Sprite tiles
SPRITE_PLAYER  = 7

; Arena boundaries
ARENA_LEFT   = 16
ARENA_RIGHT  = 232
ARENA_TOP    = 16
ARENA_BOTTOM = 208

BG_COLOUR = $0F

; -----------------------------------------------------------------------------
; Memory Layout
; -----------------------------------------------------------------------------
.segment "ZEROPAGE"
player_x:    .res 1
player_y:    .res 1
buttons:     .res 1
temp:        .res 1
row_counter: .res 1

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

    jsr load_palette
    jsr draw_arena
    jsr set_attributes

    ; Set up player
    lda #PLAYER_START_X
    sta player_x
    lda #PLAYER_START_Y
    sta player_y

    ; Initialise player sprite
    lda player_y
    sta oam_buffer+0
    lda #SPRITE_PLAYER
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

    lda #0
    sta PPUSCROLL
    sta PPUSCROLL

    ; Enable rendering
    lda #%10000000
    sta PPUCTRL
    lda #%00011110
    sta PPUMASK

main_loop:
    jsr read_controller
    jsr move_player
    jmp main_loop

; -----------------------------------------------------------------------------
; Load Palette - Four distinct background palettes
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
; Draw Arena (same as Unit 5)
; -----------------------------------------------------------------------------
draw_arena:
    bit PPUSTATUS
    lda #$20
    sta PPUADDR
    lda #$00
    sta PPUADDR

    lda #0
    sta row_counter

@draw_row:
    lda row_counter

    cmp #0
    beq @top_row
    cmp #1
    beq @top_row

    cmp #28
    beq @bottom_row
    cmp #29
    beq @bottom_row

    jmp @middle_row

@top_row:
    lda row_counter
    cmp #0
    bne @top_row_inner

    lda #TILE_CORNER_TL
    sta PPUDATA
    lda #TILE_BORDER
    ldx #30
@top_fill:
    sta PPUDATA
    dex
    bne @top_fill
    lda #TILE_CORNER_TR
    sta PPUDATA
    jmp @next_row

@top_row_inner:
    lda #TILE_BORDER
    ldx #32
@top_inner_fill:
    sta PPUDATA
    dex
    bne @top_inner_fill
    jmp @next_row

@bottom_row:
    lda row_counter
    cmp #29
    bne @bottom_row_inner

    lda #TILE_CORNER_BL
    sta PPUDATA
    lda #TILE_BORDER
    ldx #30
@bottom_fill:
    sta PPUDATA
    dex
    bne @bottom_fill
    lda #TILE_CORNER_BR
    sta PPUDATA
    jmp @next_row

@bottom_row_inner:
    lda #TILE_BORDER
    ldx #32
@bottom_inner_fill:
    sta PPUDATA
    dex
    bne @bottom_inner_fill
    jmp @next_row

@middle_row:
    lda #TILE_BORDER
    sta PPUDATA
    sta PPUDATA

    lda #TILE_FLOOR
    ldx #28
@floor_fill:
    sta PPUDATA
    dex
    bne @floor_fill

    lda #TILE_BORDER
    sta PPUDATA
    sta PPUDATA

@next_row:
    inc row_counter
    lda row_counter
    cmp #30
    beq @done_drawing
    jmp @draw_row

@done_drawing:
    rts

; -----------------------------------------------------------------------------
; Set Attribute Table - Different palettes for different regions
; -----------------------------------------------------------------------------
set_attributes:
    bit PPUSTATUS
    lda #$23
    sta PPUADDR
    lda #$C0
    sta PPUADDR

    ; Attribute table: 8 bytes per row, 8 rows = 64 bytes
    ; Each byte controls 4 16x16 pixel areas (32x32 total)
    ; Bits: 76=BR, 54=BL, 32=TR, 10=TL

    ; Row 0-1: All border (palette 0)
    ldx #8
    lda #$00          ; All palette 0
@attr_top:
    sta PPUDATA
    dex
    bne @attr_top

    ; Rows 2-5: Border edges (palette 0), floor varies
    ; Create a gradient effect: palette 1 in centre
    ldx #6            ; 6 rows of attributes for floor area
@attr_floor_rows:
    ; Byte 0: Left edge - palette 0
    lda #$00
    sta PPUDATA

    ; Bytes 1-6: Floor area with palette 1
    lda #%01010101    ; All palette 1
    sta PPUDATA
    sta PPUDATA
    sta PPUDATA
    sta PPUDATA
    sta PPUDATA
    sta PPUDATA

    ; Byte 7: Right edge - palette 0
    lda #$00
    sta PPUDATA

    dex
    bne @attr_floor_rows

    ; Row 7: Bottom border (palette 0)
    ldx #8
    lda #$00
@attr_bottom:
    sta PPUDATA
    dex
    bne @attr_bottom

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

    lda #0
    sta OAMADDR
    lda #>oam_buffer
    sta OAMDMA

    lda player_y
    sta oam_buffer+0
    lda player_x
    sta oam_buffer+3

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
    ; Background palette 0: Blue border
    .byte BG_COLOUR, $11, $21, $31  ; Black, dark blue, light blue, cyan
    ; Background palette 1: Purple floor
    .byte BG_COLOUR, $13, $23, $33  ; Black, dark purple, purple, light purple
    ; Background palette 2: Green (unused for now)
    .byte BG_COLOUR, $19, $29, $39  ; Black, dark green, green, light green
    ; Background palette 3: Red (unused for now)
    .byte BG_COLOUR, $16, $26, $36  ; Black, dark red, red, light red
    ; Sprite palettes
    .byte BG_COLOUR, $30, $27, $17  ; White, orange, brown
    .byte BG_COLOUR, $30, $27, $17
    .byte BG_COLOUR, $30, $27, $17
    .byte BG_COLOUR, $30, $27, $17

; -----------------------------------------------------------------------------
; Vectors
; -----------------------------------------------------------------------------
.segment "VECTORS"
    .word nmi
    .word reset
    .word irq

; -----------------------------------------------------------------------------
; CHR-ROM - Same tiles as Unit 5
; -----------------------------------------------------------------------------
.segment "CHARS"

; Tile 0: Empty
.byte $00,$00,$00,$00,$00,$00,$00,$00
.byte $00,$00,$00,$00,$00,$00,$00,$00

; Tile 1: Border (brick pattern)
.byte %11111111
.byte %10000001
.byte %10000001
.byte %11111111
.byte %11111111
.byte %00010001
.byte %00010001
.byte %11111111
.byte %00000000
.byte %01111110
.byte %01111110
.byte %00000000
.byte %00000000
.byte %11101110
.byte %11101110
.byte %00000000

; Tile 2: Floor (subtle grid)
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000
.byte %10000001
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000

; Tile 3: Corner TL
.byte %11111111
.byte %11000000
.byte %10100000
.byte %10010000
.byte %10001000
.byte %10000100
.byte %10000010
.byte %10000001
.byte %00000000
.byte %00111111
.byte %01011111
.byte %01101111
.byte %01110111
.byte %01111011
.byte %01111101
.byte %01111110

; Tile 4: Corner TR
.byte %11111111
.byte %00000011
.byte %00000101
.byte %00001001
.byte %00010001
.byte %00100001
.byte %01000001
.byte %10000001
.byte %00000000
.byte %11111100
.byte %11111010
.byte %11110110
.byte %11101110
.byte %11011110
.byte %10111110
.byte %01111110

; Tile 5: Corner BL
.byte %10000001
.byte %10000010
.byte %10000100
.byte %10001000
.byte %10010000
.byte %10100000
.byte %11000000
.byte %11111111
.byte %01111110
.byte %01111101
.byte %01111011
.byte %01110111
.byte %01101111
.byte %01011111
.byte %00111111
.byte %00000000

; Tile 6: Corner BR
.byte %10000001
.byte %01000001
.byte %00100001
.byte %00010001
.byte %00001001
.byte %00000101
.byte %00000011
.byte %11111111
.byte %01111110
.byte %10111110
.byte %11011110
.byte %11101110
.byte %11110110
.byte %11111010
.byte %11111100
.byte %00000000

; Tile 7: Player sprite
.byte %00011000
.byte %00011000
.byte %00111100
.byte %01111110
.byte %11111111
.byte %10111101
.byte %00100100
.byte %00100100
.byte %00000000
.byte %00011000
.byte %00011000
.byte %00111100
.byte %01000010
.byte %01000010
.byte %00011000
.byte %00000000

; Fill rest of CHR-ROM
.res 8192 - 128, $00
