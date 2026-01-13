; =============================================================================
; NEON NEXUS - Unit 16: Phase 1 Complete
; =============================================================================
; The complete Phase 1 game. Title screen, gameplay, game over, and win.
; Navigate the neon grid. Avoid enemies. Collect items. Survive.
; =============================================================================

PPUCTRL   = $2000
PPUMASK   = $2001
PPUSTATUS = $2002
OAMADDR   = $2003
PPUSCROLL = $2005
PPUADDR   = $2006
PPUDATA   = $2007
OAMDMA    = $4014
APUSTATUS = $4015
JOYPAD1   = $4016

; APU Pulse 1 registers
APU_PULSE1_CTRL = $4000
APU_PULSE1_SWEEP = $4001
APU_PULSE1_LO = $4002
APU_PULSE1_HI = $4003

BTN_START  = %00010000
BTN_UP     = %00001000
BTN_DOWN   = %00000100
BTN_LEFT   = %00000010
BTN_RIGHT  = %00000001

; Game states
STATE_TITLE    = 0
STATE_PLAYING  = 1
STATE_GAMEOVER = 2
STATE_WIN      = 3

PLAYER_START_X  = 124
PLAYER_START_Y  = 116
PLAYER_SPEED    = 2
ENEMY_SPEED     = 1
NUM_ENEMIES     = 4
NUM_ITEMS       = 4
STARTING_LIVES  = 3
COLLISION_DIST  = 6
COLLECT_DIST    = 8
INVULN_TIME     = 90

TILE_BORDER    = 1
TILE_FLOOR     = 2
TILE_CORNER_TL = 3
TILE_CORNER_TR = 4
TILE_CORNER_BL = 5
TILE_CORNER_BR = 6
SPRITE_PLAYER  = 7
SPRITE_ENEMY   = 8
SPRITE_LIFE    = 9
SPRITE_ITEM    = 10

ARENA_LEFT   = 16
ARENA_RIGHT  = 232
ARENA_TOP    = 24
ARENA_BOTTOM = 208

DIR_RIGHT = 1
DIR_LEFT  = $FF
DIR_DOWN  = 1
DIR_UP    = $FF
BG_COLOUR = $0F

.segment "ZEROPAGE"
player_x:       .res 1
player_y:       .res 1
buttons:        .res 1
buttons_prev:   .res 1      ; Previous frame buttons (for edge detection)
temp:           .res 1
row_counter:    .res 1
frame_count:    .res 1
lives:          .res 1
invuln_timer:   .res 1
game_state:     .res 1      ; Current game state
items_collected: .res 1
score_lo:       .res 1
score_hi:       .res 1

enemy_x:        .res NUM_ENEMIES
enemy_y:        .res NUM_ENEMIES
enemy_dir_x:    .res NUM_ENEMIES
enemy_dir_y:    .res NUM_ENEMIES

item_x:         .res NUM_ITEMS
item_y:         .res NUM_ITEMS
item_active:    .res NUM_ITEMS

.segment "OAM"
oam_buffer:     .res 256

.segment "BSS"

.segment "HEADER"
    .byte "NES", $1A, 2, 1, $01, $00, 0,0,0,0,0,0,0,0

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

    ; Hide all sprites initially
    lda #$FF
    ldx #0
@hide_all:
    sta oam_buffer, x
    inx
    bne @hide_all

    lda #0
    sta PPUSCROLL
    sta PPUSCROLL

    ; Enable APU channels
    lda #%00000001
    sta APUSTATUS

    ; Start in title state
    lda #STATE_TITLE
    sta game_state

    lda #%10000000
    sta PPUCTRL
    lda #%00011110
    sta PPUMASK

; =============================================================================
; Main Loop - State Machine
; =============================================================================
main_loop:
    jsr read_controller

    lda game_state
    cmp #STATE_TITLE
    beq @title_state
    cmp #STATE_PLAYING
    beq @playing_state
    cmp #STATE_GAMEOVER
    beq @gameover_state
    cmp #STATE_WIN
    beq @win_state
    jmp main_loop

@title_state:
    jsr handle_title
    jmp main_loop

@playing_state:
    jsr handle_playing
    jmp main_loop

@gameover_state:
    jsr handle_gameover
    jmp main_loop

@win_state:
    jsr handle_win
    jmp main_loop

; =============================================================================
; State Handlers
; =============================================================================

handle_title:
    ; Show title screen sprites
    jsr show_title_sprites

    ; Check for Start button press (new press only)
    lda buttons
    and #BTN_START
    beq @no_start
    lda buttons_prev
    and #BTN_START
    bne @no_start           ; Already pressed last frame

    ; Start pressed! Begin game
    jsr init_game
    lda #STATE_PLAYING
    sta game_state
    jsr play_collect_sound  ; Start game sound

@no_start:
    ; Store previous buttons
    lda buttons
    sta buttons_prev
    rts

handle_playing:
    jsr move_player
    jsr move_enemies
    jsr check_enemy_collisions
    jsr check_item_collisions
    jsr check_win_condition
    jsr update_all_sprites

    ; Store previous buttons
    lda buttons
    sta buttons_prev
    rts

handle_gameover:
    ; Show game over display
    jsr show_gameover_sprites

    ; Check for Start to restart
    lda buttons
    and #BTN_START
    beq @no_restart
    lda buttons_prev
    and #BTN_START
    bne @no_restart

    ; Restart game
    lda #STATE_TITLE
    sta game_state

@no_restart:
    lda buttons
    sta buttons_prev
    rts

handle_win:
    ; Show win display
    jsr show_win_sprites

    ; Check for Start to restart
    lda buttons
    and #BTN_START
    beq @no_restart
    lda buttons_prev
    and #BTN_START
    bne @no_restart

    ; Back to title
    lda #STATE_TITLE
    sta game_state

@no_restart:
    lda buttons
    sta buttons_prev
    rts

; =============================================================================
; Display Routines
; =============================================================================

show_title_sprites:
    ; Hide all sprites first
    lda #$FF
    ldx #0
@hide_loop:
    sta oam_buffer, x
    inx
    bne @hide_loop

    ; Show player sprite in center as "logo"
    lda #100                ; Y position
    sta oam_buffer+0
    lda #SPRITE_PLAYER
    sta oam_buffer+1
    lda #0
    sta oam_buffer+2
    lda #124                ; X position
    sta oam_buffer+3

    ; Show some items as decoration
    lda #100
    sta oam_buffer+4
    lda #SPRITE_ITEM
    sta oam_buffer+5
    lda #%00000010
    sta oam_buffer+6
    lda #100
    sta oam_buffer+7

    lda #100
    sta oam_buffer+8
    lda #SPRITE_ITEM
    sta oam_buffer+9
    lda #%00000010
    sta oam_buffer+10
    lda #148
    sta oam_buffer+11
    rts

show_gameover_sprites:
    ; Hide all sprites
    lda #$FF
    ldx #0
@hide_loop:
    sta oam_buffer, x
    inx
    bne @hide_loop

    ; Show enemies as "defeat" indicator
    lda #100
    sta oam_buffer+0
    lda #SPRITE_ENEMY
    sta oam_buffer+1
    lda #%00000001
    sta oam_buffer+2
    lda #112
    sta oam_buffer+3

    lda #100
    sta oam_buffer+4
    lda #SPRITE_ENEMY
    sta oam_buffer+5
    lda #%00000001
    sta oam_buffer+6
    lda #128
    sta oam_buffer+7

    lda #100
    sta oam_buffer+8
    lda #SPRITE_ENEMY
    sta oam_buffer+9
    lda #%00000001
    sta oam_buffer+10
    lda #144
    sta oam_buffer+11
    rts

show_win_sprites:
    ; Hide all sprites
    lda #$FF
    ldx #0
@hide_loop:
    sta oam_buffer, x
    inx
    bne @hide_loop

    ; Show player and items as "victory" indicator
    lda #100
    sta oam_buffer+0
    lda #SPRITE_PLAYER
    sta oam_buffer+1
    lda #0
    sta oam_buffer+2
    lda #124
    sta oam_buffer+3

    ; Items around player
    lda #92
    sta oam_buffer+4
    lda #SPRITE_ITEM
    sta oam_buffer+5
    lda #%00000010
    sta oam_buffer+6
    lda #116
    sta oam_buffer+7

    lda #92
    sta oam_buffer+8
    lda #SPRITE_ITEM
    sta oam_buffer+9
    lda #%00000010
    sta oam_buffer+10
    lda #132
    sta oam_buffer+11

    lda #108
    sta oam_buffer+12
    lda #SPRITE_ITEM
    sta oam_buffer+13
    lda #%00000010
    sta oam_buffer+14
    lda #116
    sta oam_buffer+15

    lda #108
    sta oam_buffer+16
    lda #SPRITE_ITEM
    sta oam_buffer+17
    lda #%00000010
    sta oam_buffer+18
    lda #132
    sta oam_buffer+19
    rts

; =============================================================================
; Game Initialisation
; =============================================================================

init_game:
    lda #STARTING_LIVES
    sta lives
    lda #0
    sta invuln_timer
    sta items_collected
    sta score_lo
    sta score_hi

    lda #PLAYER_START_X
    sta player_x
    lda #PLAYER_START_Y
    sta player_y

    jsr init_enemies
    jsr init_items
    rts

init_enemies:
    lda #48
    sta enemy_x+0
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

init_items:
    lda #80
    sta item_x+0
    lda #64
    sta item_y+0
    lda #1
    sta item_active+0

    lda #168
    sta item_x+1
    lda #64
    sta item_y+1
    lda #1
    sta item_active+1

    lda #80
    sta item_x+2
    lda #160
    sta item_y+2
    lda #1
    sta item_active+2

    lda #168
    sta item_x+3
    lda #160
    sta item_y+3
    lda #1
    sta item_active+3
    rts

; =============================================================================
; Collision Detection
; =============================================================================

check_enemy_collisions:
    lda invuln_timer
    beq @check
    dec invuln_timer
    rts

@check:
    ldx #0
@check_enemy:
    lda player_x
    sec
    sbc enemy_x, x
    bpl @check_x_pos
    eor #$FF
    clc
    adc #1
@check_x_pos:
    cmp #COLLISION_DIST
    bcs @next_enemy

    lda player_y
    sec
    sbc enemy_y, x
    bpl @check_y_pos
    eor #$FF
    clc
    adc #1
@check_y_pos:
    cmp #COLLISION_DIST
    bcs @next_enemy

    jsr player_hit
    rts

@next_enemy:
    inx
    cpx #NUM_ENEMIES
    bne @check_enemy
    rts

check_item_collisions:
    ldx #0
@check_item:
    lda item_active, x
    beq @next_item

    lda player_x
    sec
    sbc item_x, x
    bpl @item_x_pos
    eor #$FF
    clc
    adc #1
@item_x_pos:
    cmp #COLLECT_DIST
    bcs @next_item

    lda player_y
    sec
    sbc item_y, x
    bpl @item_y_pos
    eor #$FF
    clc
    adc #1
@item_y_pos:
    cmp #COLLECT_DIST
    bcs @next_item

    ; Collected!
    lda #0
    sta item_active, x
    inc items_collected
    lda score_lo
    clc
    adc #100
    sta score_lo
    lda score_hi
    adc #0
    sta score_hi
    jsr play_collect_sound

@next_item:
    inx
    cpx #NUM_ITEMS
    bne @check_item
    rts

player_hit:
    jsr play_death_sound
    dec lives
    lda lives
    beq @game_over

    lda #PLAYER_START_X
    sta player_x
    lda #PLAYER_START_Y
    sta player_y

    lda #INVULN_TIME
    sta invuln_timer
    rts

@game_over:
    lda #STATE_GAMEOVER
    sta game_state
    rts

; =============================================================================
; Win Condition
; =============================================================================

check_win_condition:
    lda items_collected
    cmp #NUM_ITEMS
    bne @not_yet
    lda game_state
    cmp #STATE_WIN
    beq @not_yet            ; Already won
    lda #STATE_WIN
    sta game_state
    jsr play_victory_sound
@not_yet:
    rts

; =============================================================================
; Sound Effects
; =============================================================================

play_collect_sound:
    lda #%10011111
    sta APU_PULSE1_CTRL
    lda #0
    sta APU_PULSE1_SWEEP
    lda #$C4
    sta APU_PULSE1_LO
    lda #%00001000
    sta APU_PULSE1_HI
    rts

play_death_sound:
    lda #%10011111
    sta APU_PULSE1_CTRL
    lda #%10001111
    sta APU_PULSE1_SWEEP
    lda #$00
    sta APU_PULSE1_LO
    lda #%00001011
    sta APU_PULSE1_HI
    rts

play_victory_sound:
    lda #%10011111
    sta APU_PULSE1_CTRL
    lda #%10000111
    sta APU_PULSE1_SWEEP
    lda #$FF
    sta APU_PULSE1_LO
    lda #%00000011
    sta APU_PULSE1_HI
    rts

; =============================================================================
; Sprite Updates
; =============================================================================

update_all_sprites:
    jsr update_player_sprite
    jsr update_enemy_sprites
    jsr update_item_sprites
    jsr update_lives_display
    rts

update_player_sprite:
    lda game_state
    cmp #STATE_PLAYING
    bne @hide

    lda invuln_timer
    beq @show
    and #%00000100
    beq @show

@hide:
    lda #$FF
    sta oam_buffer+0
    rts

@show:
    lda player_y
    sta oam_buffer+0
    lda #SPRITE_PLAYER
    sta oam_buffer+1
    lda #0
    sta oam_buffer+2
    lda player_x
    sta oam_buffer+3
    rts

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

update_item_sprites:
    ldx #0
    ldy #20
@loop:
    lda item_active, x
    beq @hide_item

    lda item_y, x
    sta oam_buffer, y
    iny
    lda #SPRITE_ITEM
    sta oam_buffer, y
    iny
    lda #%00000010
    sta oam_buffer, y
    iny
    lda item_x, x
    sta oam_buffer, y
    iny
    jmp @next_item

@hide_item:
    lda #$FF
    sta oam_buffer, y
    iny
    iny
    iny
    iny

@next_item:
    inx
    cpx #NUM_ITEMS
    bne @loop
    rts

update_lives_display:
    ldy #36
    ldx lives
    beq @hide_all

    lda #8
    sta oam_buffer, y
    iny
    lda #SPRITE_LIFE
    sta oam_buffer, y
    iny
    lda #0
    sta oam_buffer, y
    iny
    lda #16
    sta oam_buffer, y
    iny

    cpx #1
    beq @hide_rest

    lda #8
    sta oam_buffer, y
    iny
    lda #SPRITE_LIFE
    sta oam_buffer, y
    iny
    lda #0
    sta oam_buffer, y
    iny
    lda #26
    sta oam_buffer, y
    iny

    cpx #2
    beq @hide_rest

    lda #8
    sta oam_buffer, y
    iny
    lda #SPRITE_LIFE
    sta oam_buffer, y
    iny
    lda #0
    sta oam_buffer, y
    iny
    lda #36
    sta oam_buffer, y
    rts

@hide_rest:
@hide_all:
    rts

; =============================================================================
; Enemy Movement
; =============================================================================

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

; =============================================================================
; PPU Setup
; =============================================================================

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
@attr_floor:
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
    bne @attr_floor
    ldx #8
    lda #$00
@attr_bottom:
    sta PPUDATA
    dex
    bne @attr_bottom
    rts

; =============================================================================
; Input
; =============================================================================

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

; =============================================================================
; NMI Handler
; =============================================================================

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

; =============================================================================
; Data
; =============================================================================

palette_data:
    .byte BG_COLOUR, $11, $21, $31
    .byte BG_COLOUR, $13, $23, $33
    .byte BG_COLOUR, $19, $29, $39
    .byte BG_COLOUR, $16, $26, $36
    .byte BG_COLOUR, $30, $27, $17    ; Player
    .byte BG_COLOUR, $16, $26, $36    ; Enemies
    .byte BG_COLOUR, $1A, $2A, $3A    ; Items (green)
    .byte BG_COLOUR, $30, $27, $17

.segment "VECTORS"
    .word nmi
    .word reset
    .word irq

.segment "CHARS"
; Tile 0: Empty
.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
; Tile 1: Border
.byte %11111111,%10000001,%10000001,%11111111,%11111111,%00010001,%00010001,%11111111
.byte %00000000,%01111110,%01111110,%00000000,%00000000,%11101110,%11101110,%00000000
; Tile 2: Floor
.byte %00000000,%00000000,%00000000,%00000000,%00000000,%00000000,%00000000,%10000001
.byte %00000000,%00000000,%00000000,%00000000,%00000000,%00000000,%00000000,%00000000
; Tile 3: Corner TL
.byte %11111111,%11000000,%10100000,%10010000,%10001000,%10000100,%10000010,%10000001
.byte %00000000,%00111111,%01011111,%01101111,%01110111,%01111011,%01111101,%01111110
; Tile 4: Corner TR
.byte %11111111,%00000011,%00000101,%00001001,%00010001,%00100001,%01000001,%10000001
.byte %00000000,%11111100,%11111010,%11110110,%11101110,%11011110,%10111110,%01111110
; Tile 5: Corner BL
.byte %10000001,%10000010,%10000100,%10001000,%10010000,%10100000,%11000000,%11111111
.byte %01111110,%01111101,%01111011,%01110111,%01101111,%01011111,%00111111,%00000000
; Tile 6: Corner BR
.byte %10000001,%01000001,%00100001,%00010001,%00001001,%00000101,%00000011,%11111111
.byte %01111110,%10111110,%11011110,%11101110,%11110110,%11111010,%11111100,%00000000
; Tile 7: Player (sprite)
.byte %00011000,%00011000,%00111100,%01111110,%11111111,%10111101,%00100100,%00100100
.byte %00000000,%00011000,%00011000,%00111100,%01000010,%01000010,%00011000,%00000000
; Tile 8: Enemy (sprite)
.byte %00011000,%00111100,%01111110,%11111111,%11111111,%01111110,%00111100,%00011000
.byte %00000000,%00011000,%00100100,%01000010,%01000010,%00100100,%00011000,%00000000
; Tile 9: Life icon (sprite)
.byte %00000000,%00100100,%01111110,%01111110,%00111100,%00011000,%00000000,%00000000
.byte %00000000,%00000000,%00000000,%00100100,%00011000,%00000000,%00000000,%00000000
; Tile 10: Item (data core - diamond)
.byte %00000000,%00011000,%00111100,%01111110,%01111110,%00111100,%00011000,%00000000
.byte %00000000,%00000000,%00011000,%00100100,%00100100,%00011000,%00000000,%00000000

.res 8192 - 176, $00
