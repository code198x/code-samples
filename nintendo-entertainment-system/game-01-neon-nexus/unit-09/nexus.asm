;
; Neon Nexus - Unit 9: Title Screen
; Complete game with title, gameplay, and game over states
;

; ============================================================================
; iNES Header
; ============================================================================

.segment "HEADER"
    .byte "NES", $1A    ; iNES identifier
    .byte 2             ; 2x 16KB PRG-ROM
    .byte 1             ; 1x 8KB CHR-ROM
    .byte $01           ; Mapper 0, vertical mirroring
    .byte $00           ; Mapper 0

; ============================================================================
; Hardware Constants
; ============================================================================

PPUCTRL   = $2000
PPUMASK   = $2001
PPUSTATUS = $2002
PPUADDR   = $2006
PPUDATA   = $2007
PPUSCROLL = $2005
OAMDMA    = $4014
JOYPAD1   = $4016

; Controller button masks
BTN_RIGHT  = %00000001
BTN_LEFT   = %00000010
BTN_DOWN   = %00000100
BTN_UP     = %00001000
BTN_START  = %00010000
BTN_SELECT = %00100000
BTN_B      = %01000000
BTN_A      = %10000000

; Game constants
PLAYER_SPEED  = 2
ENEMY_SPEED   = 1
NUM_ENEMIES   = 4
SPAWN_X       = 120
SPAWN_Y       = 120
INVULN_TIME   = 60

; Collision box sizes
HITBOX_SIZE = 6

; Game state constants
STATE_TITLE    = 0
STATE_PLAYING  = 1
STATE_GAMEOVER = 2

; Tile indices for letters (matching CHR-ROM layout)
TILE_A = 14
TILE_E = 15
TILE_G = 16
TILE_M = 17
TILE_N = 18
TILE_O = 19
TILE_P = 20
TILE_R = 21
TILE_S = 22
TILE_T = 23
TILE_U = 24
TILE_V = 25
TILE_X = 26

; ============================================================================
; Zero Page Variables
; ============================================================================

.segment "ZEROPAGE"
nmi_ready:      .res 1      ; flag set by NMI
buttons:        .res 1      ; controller state
player_x:       .res 1      ; player X position
player_y:       .res 1      ; player Y position
enemy_x:        .res 4      ; enemy X positions
enemy_y:        .res 4      ; enemy Y positions
item_x:         .res 1      ; item X position
item_y:         .res 1      ; item Y position
score:          .res 2      ; 16-bit score (low, high)
game_state:     .res 1      ; current game state
lives:          .res 1      ; remaining lives
invuln_timer:   .res 1      ; invulnerability countdown
screen_drawn:   .res 1      ; has current screen been drawn?
temp:           .res 1      ; temporary for division

; ============================================================================
; OAM Buffer
; ============================================================================

.segment "OAM"
oam: .res 256               ; shadow OAM at $0200

; ============================================================================
; Main Code
; ============================================================================

.segment "CODE"

; ----------------------------------------------------------------------------
; reset - Entry point, called on power-on and reset
; ----------------------------------------------------------------------------
reset:
    sei                     ; disable interrupts
    cld                     ; clear decimal mode

    ldx #$40
    stx $4017               ; disable APU frame IRQ
    ldx #$FF
    txs                     ; setup stack
    inx                     ; X = 0
    stx PPUCTRL             ; disable NMI
    stx PPUMASK             ; disable rendering
    stx $4010               ; disable DMC IRQs

    ; Wait for PPU to stabilise (first vblank)
@vblank1:
    bit PPUSTATUS
    bpl @vblank1

    ; Clear RAM
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

    ; Hide all sprites initially
    ldx #0
    lda #$FF
@hide_sprites:
    sta oam, x
    inx
    bne @hide_sprites

    ; Load palette
    jsr load_palette

    ; Start at title screen
    lda #STATE_TITLE
    sta game_state
    lda #0
    sta screen_drawn

    ; Enable rendering
    lda #%10010000          ; enable NMI, sprites from table 0
    sta PPUCTRL
    lda #%00011110          ; enable sprites and background
    sta PPUMASK

    ; Fall through to game loop

; ----------------------------------------------------------------------------
; game_loop - Main loop, dispatches based on game state
; ----------------------------------------------------------------------------
game_loop:
    lda nmi_ready
    beq game_loop           ; wait for vblank
    lda #0
    sta nmi_ready

    ; Dispatch based on state
    lda game_state

    cmp #STATE_TITLE
    beq title_state

    cmp #STATE_PLAYING
    beq playing_state

    jmp gameover_state

; --- Title State ---
title_state:
    ; Draw title screen if not already drawn
    lda screen_drawn
    bne @check_input
    jsr draw_title_screen
    lda #1
    sta screen_drawn

@check_input:
    jsr read_controller
    lda buttons
    and #BTN_START
    beq game_loop           ; wait for Start

    ; Start pressed - begin game
    jsr clear_playfield
    jsr init_game
    lda #STATE_PLAYING
    sta game_state
    lda #0
    sta screen_drawn
    jmp game_loop

; --- Playing State ---
playing_state:
    ; Decrement invulnerability timer
    lda invuln_timer
    beq @no_invuln
    dec invuln_timer
@no_invuln:

    jsr read_controller
    jsr update_player
    jsr move_enemies
    jsr check_item_collision
    jsr check_enemy_collision
    jsr update_player_sprite
    jsr update_enemy_sprites
    jsr update_item_sprite

    jmp game_loop

; --- Game Over State ---
gameover_state:
    ; Draw game over screen if not already drawn
    lda screen_drawn
    bne @check_restart
    jsr draw_game_over
    lda #1
    sta screen_drawn

@check_restart:
    jsr read_controller
    lda buttons
    and #BTN_START
    beq game_loop           ; wait for Start

    ; Restart game
    jsr clear_playfield
    jsr init_game
    lda #STATE_PLAYING
    sta game_state
    lda #0
    sta screen_drawn
    jmp game_loop

; ----------------------------------------------------------------------------
; nmi - Called every vblank (60 times per second)
; ----------------------------------------------------------------------------
nmi:
    pha
    txa
    pha
    tya
    pha

    ; DMA copy shadow OAM to PPU
    lda #$00
    sta $2003               ; OAM address = 0
    lda #$02                ; page $0200
    sta OAMDMA              ; start DMA

    ; Only draw HUD during gameplay
    lda game_state
    cmp #STATE_PLAYING
    bne @skip_hud
    jsr draw_hud
@skip_hud:

    lda #1
    sta nmi_ready

    pla
    tay
    pla
    tax
    pla
    rti

; ----------------------------------------------------------------------------
; irq - Not used
; ----------------------------------------------------------------------------
irq:
    rti

; ----------------------------------------------------------------------------
; init_game - Initialise all game variables for new game
; ----------------------------------------------------------------------------
init_game:
    lda #SPAWN_X
    sta player_x
    lda #SPAWN_Y
    sta player_y

    lda #3
    sta lives

    lda #0
    sta score
    sta score+1
    sta invuln_timer

    jsr init_enemies
    jsr respawn_item

    rts

; ----------------------------------------------------------------------------
; init_enemies - Set initial enemy positions
; ----------------------------------------------------------------------------
init_enemies:
    lda #30
    sta enemy_x
    lda #50
    sta enemy_y

    lda #200
    sta enemy_x+1
    lda #50
    sta enemy_y+1

    lda #30
    sta enemy_x+2
    lda #180
    sta enemy_y+2

    lda #200
    sta enemy_x+3
    lda #180
    sta enemy_y+3

    rts

; ----------------------------------------------------------------------------
; respawn_item - Place item at new position
; ----------------------------------------------------------------------------
respawn_item:
    lda item_x
    clc
    adc #67
    and #%01111111
    clc
    adc #60
    sta item_x

    lda item_y
    clc
    adc #53
    and #%01111111
    clc
    adc #40
    sta item_y

    rts

; ----------------------------------------------------------------------------
; draw_title_screen - Draw "NEON NEXUS" and "PRESS START"
; ----------------------------------------------------------------------------
draw_title_screen:
    ; Hide all sprites on title
    ldx #0
    lda #$FF
@hide:
    sta oam, x
    inx
    bne @hide

    ; "NEON NEXUS" at row 10, column 11 = $2000 + 320 + 11 = $214B
    lda PPUSTATUS
    lda #$21
    sta PPUADDR
    lda #$4B
    sta PPUADDR

    ldx #0
@title_loop:
    lda title_text, x
    beq @draw_press
    sta PPUDATA
    inx
    bne @title_loop

@draw_press:
    ; "PRESS START" at row 14, column 10 = $2000 + 448 + 10 = $21CA
    lda #$21
    sta PPUADDR
    lda #$CA
    sta PPUADDR

    ldx #0
@press_loop:
    lda press_text, x
    beq @done
    sta PPUDATA
    inx
    bne @press_loop

@done:
    lda #0
    sta PPUSCROLL
    sta PPUSCROLL
    rts

; Title text: "NEON NEXUS" (with space)
title_text:
    .byte TILE_N, TILE_E, TILE_O, TILE_N  ; NEON
    .byte 0                                ; space
    .byte TILE_N, TILE_E, TILE_X, TILE_U, TILE_S  ; NEXUS
    .byte 0                                ; terminator

; Press text: "PRESS START"
press_text:
    .byte TILE_P, TILE_R, TILE_E, TILE_S, TILE_S  ; PRESS
    .byte 0                                        ; space
    .byte TILE_S, TILE_T, TILE_A, TILE_R, TILE_T  ; START
    .byte 0                                        ; terminator

; ----------------------------------------------------------------------------
; draw_game_over - Draw "GAME OVER" message
; ----------------------------------------------------------------------------
draw_game_over:
    ; Hide sprites
    ldx #0
    lda #$FF
@hide:
    sta oam, x
    inx
    bne @hide

    ; "GAME OVER" at row 12, column 11 = $2000 + 384 + 11 = $218B
    lda PPUSTATUS
    lda #$21
    sta PPUADDR
    lda #$8B
    sta PPUADDR

    ldx #0
@loop:
    lda gameover_text, x
    beq @done
    sta PPUDATA
    inx
    bne @loop

@done:
    lda #0
    sta PPUSCROLL
    sta PPUSCROLL
    rts

; Game over text: "GAME OVER"
gameover_text:
    .byte TILE_G, TILE_A, TILE_M, TILE_E  ; GAME
    .byte 0                                ; space
    .byte TILE_O, TILE_V, TILE_E, TILE_R  ; OVER
    .byte 0                                ; terminator

; ----------------------------------------------------------------------------
; clear_playfield - Clear text area of nametable
; ----------------------------------------------------------------------------
clear_playfield:
    lda PPUSTATUS

    ; Clear rows 8-16 ($2100-$2200)
    lda #$21
    sta PPUADDR
    lda #$00
    sta PPUADDR

    lda #0                  ; blank tile
    ldx #0
@loop:
    sta PPUDATA
    sta PPUDATA
    sta PPUDATA
    sta PPUDATA
    inx
    cpx #64                 ; 256 tiles
    bne @loop

    lda #0
    sta PPUSCROLL
    sta PPUSCROLL
    rts

; ----------------------------------------------------------------------------
; read_controller - Read joypad state into buttons variable
; ----------------------------------------------------------------------------
read_controller:
    lda #1
    sta JOYPAD1
    lda #0
    sta JOYPAD1

    ldx #8
@loop:
    lda JOYPAD1
    lsr a
    rol buttons
    dex
    bne @loop

    rts

; ----------------------------------------------------------------------------
; update_player - Move player based on controller input
; ----------------------------------------------------------------------------
update_player:
    lda buttons
    and #BTN_RIGHT
    beq @check_left
    lda player_x
    clc
    adc #PLAYER_SPEED
    cmp #248
    bcs @check_left
    sta player_x

@check_left:
    lda buttons
    and #BTN_LEFT
    beq @check_down
    lda player_x
    sec
    sbc #PLAYER_SPEED
    bcc @check_down
    sta player_x

@check_down:
    lda buttons
    and #BTN_DOWN
    beq @check_up
    lda player_y
    clc
    adc #PLAYER_SPEED
    cmp #224
    bcs @check_up
    sta player_y

@check_up:
    lda buttons
    and #BTN_UP
    beq @done
    lda player_y
    sec
    sbc #PLAYER_SPEED
    cmp #16
    bcc @done
    sta player_y

@done:
    rts

; ----------------------------------------------------------------------------
; move_enemies - Update enemy positions
; ----------------------------------------------------------------------------
move_enemies:
    ldx #0

@loop:
    lda enemy_x, x
    sec
    sbc #ENEMY_SPEED
    sta enemy_x, x

    cmp #250
    bcc @next

    lda #248
    sta enemy_x, x

@next:
    inx
    cpx #NUM_ENEMIES
    bne @loop

    rts

; ----------------------------------------------------------------------------
; check_item_collision - Test player/item overlap
; ----------------------------------------------------------------------------
check_item_collision:
    lda player_x
    sec
    sbc item_x
    bcs @check_x_pos
    eor #$FF
    clc
    adc #1
@check_x_pos:
    cmp #HITBOX_SIZE
    bcs @no_collision

    lda player_y
    sec
    sbc item_y
    bcs @check_y_pos
    eor #$FF
    clc
    adc #1
@check_y_pos:
    cmp #HITBOX_SIZE
    bcs @no_collision

    jsr collect_item

@no_collision:
    rts

; ----------------------------------------------------------------------------
; collect_item - Handle item pickup
; ----------------------------------------------------------------------------
collect_item:
    lda score
    clc
    adc #10
    sta score
    lda score+1
    adc #0
    sta score+1

    jsr respawn_item
    rts

; ----------------------------------------------------------------------------
; check_enemy_collision - Test player/enemy overlap
; ----------------------------------------------------------------------------
check_enemy_collision:
    lda invuln_timer
    bne @done

    ldx #0

@loop:
    lda player_x
    sec
    sbc enemy_x, x
    bcs @check_x
    eor #$FF
    clc
    adc #1
@check_x:
    cmp #HITBOX_SIZE
    bcs @next

    lda player_y
    sec
    sbc enemy_y, x
    bcs @check_y
    eor #$FF
    clc
    adc #1
@check_y:
    cmp #HITBOX_SIZE
    bcs @next

    jsr lose_life
    rts

@next:
    inx
    cpx #NUM_ENEMIES
    bne @loop

@done:
    rts

; ----------------------------------------------------------------------------
; lose_life - Handle player death
; ----------------------------------------------------------------------------
lose_life:
    dec lives

    lda lives
    beq @game_over

    jsr respawn_player
    rts

@game_over:
    lda #STATE_GAMEOVER
    sta game_state
    lda #0
    sta screen_drawn
    rts

; ----------------------------------------------------------------------------
; respawn_player - Reset player position with invulnerability
; ----------------------------------------------------------------------------
respawn_player:
    lda #SPAWN_X
    sta player_x
    lda #SPAWN_Y
    sta player_y

    lda #INVULN_TIME
    sta invuln_timer
    rts

; ----------------------------------------------------------------------------
; update_player_sprite - Write player to shadow OAM with flicker
; ----------------------------------------------------------------------------
update_player_sprite:
    lda invuln_timer
    beq @visible

    and #%00000100
    beq @hidden

@visible:
    lda player_y
    sta oam
    lda #1
    sta oam+1
    lda #0
    sta oam+2
    lda player_x
    sta oam+3
    rts

@hidden:
    lda #$FF
    sta oam
    rts

; ----------------------------------------------------------------------------
; update_enemy_sprites - Write enemies to shadow OAM
; ----------------------------------------------------------------------------
update_enemy_sprites:
    ldx #0
    ldy #4

@loop:
    lda enemy_y, x
    sta oam, y
    iny

    lda #2
    sta oam, y
    iny

    lda #1
    sta oam, y
    iny

    lda enemy_x, x
    sta oam, y
    iny

    inx
    cpx #NUM_ENEMIES
    bne @loop

    rts

; ----------------------------------------------------------------------------
; update_item_sprite - Write item to shadow OAM
; ----------------------------------------------------------------------------
update_item_sprite:
    lda item_y
    sta oam+20
    lda #3
    sta oam+21
    lda #2
    sta oam+22
    lda item_x
    sta oam+23
    rts

; ----------------------------------------------------------------------------
; draw_hud - Update score and lives display
; ----------------------------------------------------------------------------
draw_hud:
    lda #$20
    sta PPUADDR
    lda #$02
    sta PPUADDR

    lda score+1
    jsr div10
    clc
    adc #4
    sta PPUDATA

    lda temp
    jsr div10
    clc
    adc #4
    sta PPUDATA

    lda temp
    clc
    adc #4
    sta PPUDATA

    lda #$20
    sta PPUADDR
    lda #$1C
    sta PPUADDR

    lda lives
    clc
    adc #4
    sta PPUDATA

    lda #0
    sta PPUSCROLL
    sta PPUSCROLL

    rts

; ----------------------------------------------------------------------------
; div10 - Divide A by 10, quotient in A, remainder in temp
; ----------------------------------------------------------------------------
div10:
    ldx #0
@loop:
    cmp #10
    bcc @done
    sec
    sbc #10
    inx
    bne @loop
@done:
    sta temp
    txa
    rts

; ----------------------------------------------------------------------------
; load_palette - Load colour palette into PPU
; ----------------------------------------------------------------------------
load_palette:
    lda PPUSTATUS
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

; ----------------------------------------------------------------------------
; Palette Data
; ----------------------------------------------------------------------------
palette_data:
    ; Background palettes
    .byte $0F, $20, $10, $00
    .byte $0F, $20, $10, $00
    .byte $0F, $20, $10, $00
    .byte $0F, $20, $10, $00
    ; Sprite palettes
    .byte $0F, $20, $16, $28
    .byte $0F, $20, $12, $22
    .byte $0F, $20, $1A, $2A
    .byte $0F, $20, $10, $00

; ============================================================================
; Vectors
; ============================================================================

.segment "VECTORS"
    .word nmi
    .word reset
    .word irq

; ============================================================================
; CHR-ROM Pattern Data
; ============================================================================

.segment "CHARS"

; Tile 0: Empty/blank
.byte $00,$00,$00,$00,$00,$00,$00,$00
.byte $00,$00,$00,$00,$00,$00,$00,$00

; Tile 1: Player sprite
.byte $18,$3C,$7E,$FF,$FF,$7E,$3C,$18
.byte $00,$00,$00,$00,$00,$00,$00,$00

; Tile 2: Enemy sprite
.byte $42,$24,$7E,$5A,$FF,$81,$42,$24
.byte $00,$00,$00,$00,$00,$00,$00,$00

; Tile 3: Item sprite
.byte $18,$3C,$7E,$FF,$7E,$3C,$18,$00
.byte $00,$00,$00,$00,$00,$00,$00,$00

; Tile 4: Digit '0'
.byte $3C,$66,$6E,$7E,$76,$66,$3C,$00
.byte $00,$00,$00,$00,$00,$00,$00,$00

; Tile 5: Digit '1'
.byte $18,$38,$18,$18,$18,$18,$7E,$00
.byte $00,$00,$00,$00,$00,$00,$00,$00

; Tile 6: Digit '2'
.byte $3C,$66,$06,$1C,$30,$60,$7E,$00
.byte $00,$00,$00,$00,$00,$00,$00,$00

; Tile 7: Digit '3'
.byte $3C,$66,$06,$1C,$06,$66,$3C,$00
.byte $00,$00,$00,$00,$00,$00,$00,$00

; Tile 8: Digit '4'
.byte $0E,$1E,$36,$66,$7F,$06,$06,$00
.byte $00,$00,$00,$00,$00,$00,$00,$00

; Tile 9: Digit '5'
.byte $7E,$60,$7C,$06,$06,$66,$3C,$00
.byte $00,$00,$00,$00,$00,$00,$00,$00

; Tile 10: Digit '6'
.byte $1C,$30,$60,$7C,$66,$66,$3C,$00
.byte $00,$00,$00,$00,$00,$00,$00,$00

; Tile 11: Digit '7'
.byte $7E,$06,$0C,$18,$30,$30,$30,$00
.byte $00,$00,$00,$00,$00,$00,$00,$00

; Tile 12: Digit '8'
.byte $3C,$66,$66,$3C,$66,$66,$3C,$00
.byte $00,$00,$00,$00,$00,$00,$00,$00

; Tile 13: Digit '9'
.byte $3C,$66,$66,$3E,$06,$0C,$38,$00
.byte $00,$00,$00,$00,$00,$00,$00,$00

; Tile 14: Letter 'A'
.byte $18,$3C,$66,$66,$7E,$66,$66,$00
.byte $00,$00,$00,$00,$00,$00,$00,$00

; Tile 15: Letter 'E'
.byte $7E,$60,$60,$7C,$60,$60,$7E,$00
.byte $00,$00,$00,$00,$00,$00,$00,$00

; Tile 16: Letter 'G'
.byte $3C,$66,$60,$6E,$66,$66,$3C,$00
.byte $00,$00,$00,$00,$00,$00,$00,$00

; Tile 17: Letter 'M'
.byte $63,$77,$7F,$6B,$63,$63,$63,$00
.byte $00,$00,$00,$00,$00,$00,$00,$00

; Tile 18: Letter 'N'
.byte $66,$76,$7E,$7E,$6E,$66,$66,$00
.byte $00,$00,$00,$00,$00,$00,$00,$00

; Tile 19: Letter 'O'
.byte $3C,$66,$66,$66,$66,$66,$3C,$00
.byte $00,$00,$00,$00,$00,$00,$00,$00

; Tile 20: Letter 'P'
.byte $7C,$66,$66,$7C,$60,$60,$60,$00
.byte $00,$00,$00,$00,$00,$00,$00,$00

; Tile 21: Letter 'R'
.byte $7C,$66,$66,$7C,$6C,$66,$66,$00
.byte $00,$00,$00,$00,$00,$00,$00,$00

; Tile 22: Letter 'S'
.byte $3C,$66,$60,$3C,$06,$66,$3C,$00
.byte $00,$00,$00,$00,$00,$00,$00,$00

; Tile 23: Letter 'T'
.byte $7E,$18,$18,$18,$18,$18,$18,$00
.byte $00,$00,$00,$00,$00,$00,$00,$00

; Tile 24: Letter 'U'
.byte $66,$66,$66,$66,$66,$66,$3C,$00
.byte $00,$00,$00,$00,$00,$00,$00,$00

; Tile 25: Letter 'V'
.byte $66,$66,$66,$66,$66,$3C,$18,$00
.byte $00,$00,$00,$00,$00,$00,$00,$00

; Tile 26: Letter 'X'
.byte $66,$66,$3C,$18,$3C,$66,$66,$00
.byte $00,$00,$00,$00,$00,$00,$00,$00

; Remaining tiles filled with zeros
.res 7984, $00
