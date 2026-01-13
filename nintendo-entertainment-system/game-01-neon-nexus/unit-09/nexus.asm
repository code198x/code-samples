; =============================================================================
; NEON NEXUS - Unit 9: Collision Detection
; =============================================================================
; Detect when player touches enemies. Visual feedback on collision.
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
ENEMY_SPEED    = 1

NUM_ENEMIES    = 4
SPRITE_SIZE    = 8       ; 8x8 pixel sprites
COLLISION_DIST = 6       ; Overlap distance for collision

; Tile indices
TILE_EMPTY     = 0
TILE_BORDER    = 1
TILE_FLOOR     = 2
TILE_CORNER_TL = 3
TILE_CORNER_TR = 4
TILE_CORNER_BL = 5
TILE_CORNER_BR = 6

SPRITE_PLAYER  = 7
SPRITE_ENEMY   = 8

; Arena boundaries
ARENA_LEFT   = 16
ARENA_RIGHT  = 232
ARENA_TOP    = 16
ARENA_BOTTOM = 208

DIR_RIGHT = 1
DIR_LEFT  = $FF
DIR_DOWN  = 1
DIR_UP    = $FF

BG_COLOUR = $0F

; -----------------------------------------------------------------------------
; Memory Layout
; -----------------------------------------------------------------------------
.segment "ZEROPAGE"
player_x:      .res 1
player_y:      .res 1
buttons:       .res 1
temp:          .res 1
temp2:         .res 1
row_counter:   .res 1
frame_count:   .res 1
collision_flag: .res 1     ; Non-zero if collision detected
flash_timer:   .res 1      ; Timer for visual feedback

enemy_x:       .res NUM_ENEMIES
enemy_y:       .res NUM_ENEMIES
enemy_dir_x:   .res NUM_ENEMIES
enemy_dir_y:   .res NUM_ENEMIES

.segment "OAM"
oam_buffer:    .res 256

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
    jsr init_enemies

    lda #PLAYER_START_X
    sta player_x
    lda #PLAYER_START_Y
    sta player_y

    lda #0
    sta collision_flag
    sta flash_timer

    ; Player sprite
    lda player_y
    sta oam_buffer+0
    lda #SPRITE_PLAYER
    sta oam_buffer+1
    lda #0
    sta oam_buffer+2
    lda player_x
    sta oam_buffer+3

    jsr update_enemy_sprites

    ; Hide remaining sprites
    lda #$FF
    ldx #20
@hide_sprites:
    sta oam_buffer, x
    inx
    bne @hide_sprites

    lda #0
    sta PPUSCROLL
    sta PPUSCROLL
    sta frame_count

    lda #%10000000
    sta PPUCTRL
    lda #%00011110
    sta PPUMASK

main_loop:
    jsr read_controller
    jsr move_player
    jsr move_enemies
    jsr check_collisions
    jsr update_player_sprite
    jsr update_enemy_sprites
    jmp main_loop

; -----------------------------------------------------------------------------
; Check Collisions - Player vs all enemies
; -----------------------------------------------------------------------------
check_collisions:
    lda #0
    sta collision_flag

    ldx #0
@check_enemy:
    ; Check X overlap
    ; |player_x - enemy_x| < COLLISION_DIST
    lda player_x
    sec
    sbc enemy_x, x
    bpl @check_x_positive
    ; Negative - negate it
    eor #$FF
    clc
    adc #1
@check_x_positive:
    cmp #COLLISION_DIST
    bcs @next_enemy      ; No X overlap

    ; Check Y overlap
    lda player_y
    sec
    sbc enemy_y, x
    bpl @check_y_positive
    eor #$FF
    clc
    adc #1
@check_y_positive:
    cmp #COLLISION_DIST
    bcs @next_enemy      ; No Y overlap

    ; Collision detected!
    lda #1
    sta collision_flag
    lda #30              ; Flash for 30 frames
    sta flash_timer
    rts                  ; Exit early on first collision

@next_enemy:
    inx
    cpx #NUM_ENEMIES
    bne @check_enemy
    rts

; -----------------------------------------------------------------------------
; Update Player Sprite - Flash when hit
; -----------------------------------------------------------------------------
update_player_sprite:
    ; Update position
    lda player_y
    sta oam_buffer+0
    lda player_x
    sta oam_buffer+3

    ; Check if flashing
    lda flash_timer
    beq @no_flash

    ; Decrement timer
    dec flash_timer

    ; Flash by toggling visibility every 4 frames
    and #%00000100
    beq @show_player
    ; Hide player (move off screen)
    lda #$FF
    sta oam_buffer+0
    rts

@show_player:
    lda player_y
    sta oam_buffer+0
    rts

@no_flash:
    rts

; -----------------------------------------------------------------------------
; Initialise Enemies
; -----------------------------------------------------------------------------
init_enemies:
    lda #48
    sta enemy_x+0
    lda #48
    sta enemy_y+0
    lda #DIR_RIGHT
    sta enemy_dir_x+0
    lda #DIR_DOWN
    sta enemy_dir_y+0

    lda #200
    sta enemy_x+1
    lda #48
    sta enemy_y+1
    lda #DIR_LEFT
    sta enemy_dir_x+1
    lda #DIR_DOWN
    sta enemy_dir_y+1

    lda #48
    sta enemy_x+2
    lda #176
    sta enemy_y+2
    lda #DIR_RIGHT
    sta enemy_dir_x+2
    lda #DIR_UP
    sta enemy_dir_y+2

    lda #200
    sta enemy_x+3
    lda #176
    sta enemy_y+3
    lda #DIR_LEFT
    sta enemy_dir_x+3
    lda #DIR_UP
    sta enemy_dir_y+3

    rts

; -----------------------------------------------------------------------------
; Move Enemies
; -----------------------------------------------------------------------------
move_enemies:
    ldx #0

@enemy_loop:
    lda enemy_x, x
    clc
    adc enemy_dir_x, x
    sta enemy_x, x

    cmp #ARENA_LEFT
    bcs @check_right
    lda #DIR_RIGHT
    sta enemy_dir_x, x
    lda #ARENA_LEFT
    sta enemy_x, x
    jmp @move_y

@check_right:
    cmp #ARENA_RIGHT
    bcc @move_y
    lda #DIR_LEFT
    sta enemy_dir_x, x
    lda #ARENA_RIGHT
    sec
    sbc #1
    sta enemy_x, x

@move_y:
    lda enemy_y, x
    clc
    adc enemy_dir_y, x
    sta enemy_y, x

    cmp #ARENA_TOP
    bcs @check_bottom
    lda #DIR_DOWN
    sta enemy_dir_y, x
    lda #ARENA_TOP
    sta enemy_y, x
    jmp @next_enemy

@check_bottom:
    cmp #ARENA_BOTTOM
    bcc @next_enemy
    lda #DIR_UP
    sta enemy_dir_y, x
    lda #ARENA_BOTTOM
    sec
    sbc #1
    sta enemy_y, x

@next_enemy:
    inx
    cpx #NUM_ENEMIES
    bne @enemy_loop
    rts

; -----------------------------------------------------------------------------
; Update Enemy Sprites
; -----------------------------------------------------------------------------
update_enemy_sprites:
    ldx #0
    ldy #4

@loop:
    lda enemy_y, x
    sta oam_buffer, y
    iny
    lda #SPRITE_ENEMY
    sta oam_buffer, y
    iny
    lda #%00000001
    sta oam_buffer, y
    iny
    lda enemy_x, x
    sta oam_buffer, y
    iny
    inx
    cpx #NUM_ENEMIES
    bne @loop
    rts

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
; Set Attribute Table
; -----------------------------------------------------------------------------
set_attributes:
    bit PPUSTATUS
    lda #$23
    sta PPUADDR
    lda #$C0
    sta PPUADDR

    ldx #8
    lda #$00
@attr_top:
    sta PPUDATA
    dex
    bne @attr_top

    ldx #6
@attr_floor_rows:
    lda #$00
    sta PPUDATA
    lda #%01010101
    sta PPUDATA
    sta PPUDATA
    sta PPUDATA
    sta PPUDATA
    sta PPUDATA
    sta PPUDATA
    lda #$00
    sta PPUDATA
    dex
    bne @attr_floor_rows

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

    inc frame_count

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
    .byte BG_COLOUR, $11, $21, $31
    .byte BG_COLOUR, $13, $23, $33
    .byte BG_COLOUR, $19, $29, $39
    .byte BG_COLOUR, $16, $26, $36
    .byte BG_COLOUR, $30, $27, $17
    .byte BG_COLOUR, $16, $26, $36
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
; CHR-ROM
; -----------------------------------------------------------------------------
.segment "CHARS"

; Tile 0: Empty
.byte $00,$00,$00,$00,$00,$00,$00,$00
.byte $00,$00,$00,$00,$00,$00,$00,$00

; Tile 1: Border
.byte %11111111,%10000001,%10000001,%11111111
.byte %11111111,%00010001,%00010001,%11111111
.byte %00000000,%01111110,%01111110,%00000000
.byte %00000000,%11101110,%11101110,%00000000

; Tile 2: Floor
.byte %00000000,%00000000,%00000000,%00000000
.byte %00000000,%00000000,%00000000,%10000001
.byte %00000000,%00000000,%00000000,%00000000
.byte %00000000,%00000000,%00000000,%00000000

; Tile 3: Corner TL
.byte %11111111,%11000000,%10100000,%10010000
.byte %10001000,%10000100,%10000010,%10000001
.byte %00000000,%00111111,%01011111,%01101111
.byte %01110111,%01111011,%01111101,%01111110

; Tile 4: Corner TR
.byte %11111111,%00000011,%00000101,%00001001
.byte %00010001,%00100001,%01000001,%10000001
.byte %00000000,%11111100,%11111010,%11110110
.byte %11101110,%11011110,%10111110,%01111110

; Tile 5: Corner BL
.byte %10000001,%10000010,%10000100,%10001000
.byte %10010000,%10100000,%11000000,%11111111
.byte %01111110,%01111101,%01111011,%01110111
.byte %01101111,%01011111,%00111111,%00000000

; Tile 6: Corner BR
.byte %10000001,%01000001,%00100001,%00010001
.byte %00001001,%00000101,%00000011,%11111111
.byte %01111110,%10111110,%11011110,%11101110
.byte %11110110,%11111010,%11111100,%00000000

; Tile 7: Player
.byte %00011000,%00011000,%00111100,%01111110
.byte %11111111,%10111101,%00100100,%00100100
.byte %00000000,%00011000,%00011000,%00111100
.byte %01000010,%01000010,%00011000,%00000000

; Tile 8: Enemy
.byte %00011000,%00111100,%01111110,%11111111
.byte %11111111,%01111110,%00111100,%00011000
.byte %00000000,%00011000,%00100100,%01000010
.byte %01000010,%00100100,%00011000,%00000000

; Fill rest
.res 8192 - 144, $00
