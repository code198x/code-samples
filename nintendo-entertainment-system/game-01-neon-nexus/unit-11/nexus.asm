;
; Neon Nexus - Unit 11: Difficulty
; Progressive difficulty based on score
;

; ============================================================================
; iNES Header
; ============================================================================

.segment "HEADER"
    .byte "NES", $1A
    .byte 2
    .byte 1
    .byte $01
    .byte $00

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

APU_PULSE1_CTRL = $4000
APU_PULSE1_SWEEP = $4001
APU_PULSE1_TIMER_LO = $4002
APU_PULSE1_TIMER_HI = $4003
APU_STATUS = $4015

BTN_RIGHT  = %00000001
BTN_LEFT   = %00000010
BTN_DOWN   = %00000100
BTN_UP     = %00001000
BTN_START  = %00010000
BTN_SELECT = %00100000
BTN_B      = %01000000
BTN_A      = %10000000

PLAYER_SPEED  = 2
NUM_ENEMIES   = 4
SPAWN_X       = 120
SPAWN_Y       = 120
INVULN_TIME   = 60
HITBOX_SIZE   = 6
MAX_DIFFICULTY = 5

STATE_TITLE    = 0
STATE_PLAYING  = 1
STATE_GAMEOVER = 2

SFX_NONE    = 0
SFX_COLLECT = 1
SFX_DEATH   = 2

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
nmi_ready:      .res 1
buttons:        .res 1
player_x:       .res 1
player_y:       .res 1
enemy_x:        .res 4
enemy_y:        .res 4
item_x:         .res 1
item_y:         .res 1
score:          .res 2
game_state:     .res 1
lives:          .res 1
invuln_timer:   .res 1
screen_drawn:   .res 1
temp:           .res 1
sfx_timer:      .res 1
sfx_pitch:      .res 1
sfx_type:       .res 1
difficulty:     .res 1      ; current difficulty level

; ============================================================================
; OAM Buffer
; ============================================================================

.segment "OAM"
oam: .res 256

; ============================================================================
; Main Code
; ============================================================================

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

    ldx #0
    lda #$FF
@hide_sprites:
    sta oam, x
    inx
    bne @hide_sprites

    jsr init_apu
    jsr load_palette

    lda #STATE_TITLE
    sta game_state
    lda #0
    sta screen_drawn

    lda #%10010000
    sta PPUCTRL
    lda #%00011110
    sta PPUMASK

game_loop:
    lda nmi_ready
    beq game_loop
    lda #0
    sta nmi_ready

    lda game_state

    cmp #STATE_TITLE
    beq title_state

    cmp #STATE_PLAYING
    beq playing_state

    jmp gameover_state

title_state:
    lda screen_drawn
    bne @check_input
    jsr draw_title_screen
    lda #1
    sta screen_drawn

@check_input:
    jsr read_controller
    lda buttons
    and #BTN_START
    beq game_loop

    jsr clear_playfield
    jsr init_game
    lda #STATE_PLAYING
    sta game_state
    lda #0
    sta screen_drawn
    jmp game_loop

playing_state:
    lda invuln_timer
    beq @no_invuln
    dec invuln_timer
@no_invuln:

    jsr read_controller
    jsr update_player
    jsr move_enemies
    jsr check_item_collision
    jsr check_enemy_collision
    jsr update_sound
    jsr update_player_sprite
    jsr update_enemy_sprites
    jsr update_item_sprite

    jmp game_loop

gameover_state:
    lda screen_drawn
    bne @check_restart
    jsr draw_game_over
    lda #1
    sta screen_drawn

@check_restart:
    jsr read_controller
    lda buttons
    and #BTN_START
    beq game_loop

    jsr clear_playfield
    jsr init_game
    lda #STATE_PLAYING
    sta game_state
    lda #0
    sta screen_drawn
    jmp game_loop

nmi:
    pha
    txa
    pha
    tya
    pha

    lda #$00
    sta $2003
    lda #$02
    sta OAMDMA

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

irq:
    rti

; ----------------------------------------------------------------------------
; init_apu
; ----------------------------------------------------------------------------
init_apu:
    lda #%00000001
    sta APU_STATUS

    lda #%00110000
    sta APU_PULSE1_CTRL
    lda #0
    sta APU_PULSE1_SWEEP

    lda #0
    sta sfx_timer
    sta sfx_type
    sta sfx_pitch

    rts

; ----------------------------------------------------------------------------
; play_collect_sound
; ----------------------------------------------------------------------------
play_collect_sound:
    lda #SFX_COLLECT
    sta sfx_type
    lda #15
    sta sfx_timer
    lda #0
    sta sfx_pitch

    lda #%10111111
    sta APU_PULSE1_CTRL
    lda #0
    sta APU_PULSE1_SWEEP

    lda collect_pitches
    sta APU_PULSE1_TIMER_LO
    lda #%00001000
    sta APU_PULSE1_TIMER_HI

    rts

; ----------------------------------------------------------------------------
; play_death_sound
; ----------------------------------------------------------------------------
play_death_sound:
    lda #SFX_DEATH
    sta sfx_type
    lda #20
    sta sfx_timer
    lda #0
    sta sfx_pitch

    lda #%11111111
    sta APU_PULSE1_CTRL
    lda #0
    sta APU_PULSE1_SWEEP

    lda death_pitches
    sta APU_PULSE1_TIMER_LO
    lda #%00001000
    sta APU_PULSE1_TIMER_HI

    rts

; ----------------------------------------------------------------------------
; update_sound
; ----------------------------------------------------------------------------
update_sound:
    lda sfx_timer
    beq @done

    dec sfx_timer
    beq @end_sound

    lda sfx_type
    cmp #SFX_COLLECT
    beq @update_collect
    cmp #SFX_DEATH
    beq @update_death
    rts

@update_collect:
    lda sfx_timer
    and #%00000011
    bne @done
    inc sfx_pitch
    ldx sfx_pitch
    cpx #5
    bcs @done
    lda collect_pitches, x
    sta APU_PULSE1_TIMER_LO
    rts

@update_death:
    lda sfx_timer
    and #%00000011
    bne @done
    inc sfx_pitch
    ldx sfx_pitch
    cpx #5
    bcs @done
    lda death_pitches, x
    sta APU_PULSE1_TIMER_LO
    rts

@end_sound:
    lda #%00110000
    sta APU_PULSE1_CTRL
    lda #SFX_NONE
    sta sfx_type
@done:
    rts

collect_pitches:
    .byte 200, 150, 100, 75, 50

death_pitches:
    .byte 100, 150, 200, 230, 254

; ----------------------------------------------------------------------------
; init_game
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
    sta sfx_timer
    sta sfx_type
    sta difficulty          ; reset difficulty

    jsr init_enemies
    jsr respawn_item

    rts

; ----------------------------------------------------------------------------
; init_enemies
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
; respawn_item
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
; update_difficulty - Check if score warrants difficulty increase
; ----------------------------------------------------------------------------
update_difficulty:
    lda difficulty
    cmp #MAX_DIFFICULTY
    bcs @done               ; already at max

    ; Get threshold for next level
    ldx difficulty
    inx                     ; next level index
    lda score
    cmp difficulty_thresholds, x
    bcc @done               ; below threshold

    inc difficulty          ; level up!

@done:
    rts

; Thresholds for each difficulty level
difficulty_thresholds:
    .byte 0                 ; level 0 (start)
    .byte 50                ; level 1
    .byte 100               ; level 2
    .byte 150               ; level 3
    .byte 200               ; level 4
    .byte 250               ; level 5 (max)

; Speed (pixels/frame) for each difficulty level
enemy_speeds:
    .byte 1, 1, 2, 2, 3, 3  ; difficulty 0-5

; ----------------------------------------------------------------------------
; draw_title_screen
; ----------------------------------------------------------------------------
draw_title_screen:
    ldx #0
    lda #$FF
@hide:
    sta oam, x
    inx
    bne @hide

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

title_text:
    .byte TILE_N, TILE_E, TILE_O, TILE_N
    .byte 0
    .byte TILE_N, TILE_E, TILE_X, TILE_U, TILE_S
    .byte 0

press_text:
    .byte TILE_P, TILE_R, TILE_E, TILE_S, TILE_S
    .byte 0
    .byte TILE_S, TILE_T, TILE_A, TILE_R, TILE_T
    .byte 0

; ----------------------------------------------------------------------------
; draw_game_over
; ----------------------------------------------------------------------------
draw_game_over:
    ldx #0
    lda #$FF
@hide:
    sta oam, x
    inx
    bne @hide

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

gameover_text:
    .byte TILE_G, TILE_A, TILE_M, TILE_E
    .byte 0
    .byte TILE_O, TILE_V, TILE_E, TILE_R
    .byte 0

; ----------------------------------------------------------------------------
; clear_playfield
; ----------------------------------------------------------------------------
clear_playfield:
    lda PPUSTATUS
    lda #$21
    sta PPUADDR
    lda #$00
    sta PPUADDR

    lda #0
    ldx #0
@loop:
    sta PPUDATA
    sta PPUDATA
    sta PPUDATA
    sta PPUDATA
    inx
    cpx #64
    bne @loop

    lda #0
    sta PPUSCROLL
    sta PPUSCROLL
    rts

; ----------------------------------------------------------------------------
; read_controller
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
; update_player
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
; move_enemies - Speed based on difficulty
; ----------------------------------------------------------------------------
move_enemies:
    ; Get speed for current difficulty
    ldx difficulty
    lda enemy_speeds, x
    sta temp                ; store speed

    ldx #0                  ; enemy index

@loop:
    lda enemy_x, x
    sec
    sbc temp                ; subtract speed based on difficulty
    sta enemy_x, x

    ; Check for wrap
    cmp #250
    bcc @next

    ; Respawn on right
    lda #248
    sta enemy_x, x

@next:
    inx
    cpx #NUM_ENEMIES
    bne @loop

    rts

; ----------------------------------------------------------------------------
; check_item_collision
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
; collect_item
; ----------------------------------------------------------------------------
collect_item:
    lda score
    clc
    adc #10
    sta score
    lda score+1
    adc #0
    sta score+1

    jsr update_difficulty   ; check for level up
    jsr play_collect_sound
    jsr respawn_item
    rts

; ----------------------------------------------------------------------------
; check_enemy_collision
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
; lose_life
; ----------------------------------------------------------------------------
lose_life:
    dec lives

    jsr play_death_sound

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
; respawn_player
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
; update_player_sprite
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
; update_enemy_sprites
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
; update_item_sprite
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
; draw_hud
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
; div10
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
; load_palette
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

palette_data:
    .byte $0F, $20, $10, $00
    .byte $0F, $20, $10, $00
    .byte $0F, $20, $10, $00
    .byte $0F, $20, $10, $00
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
; CHR-ROM
; ============================================================================

.segment "CHARS"

.byte $00,$00,$00,$00,$00,$00,$00,$00
.byte $00,$00,$00,$00,$00,$00,$00,$00

.byte $18,$3C,$7E,$FF,$FF,$7E,$3C,$18
.byte $00,$00,$00,$00,$00,$00,$00,$00

.byte $42,$24,$7E,$5A,$FF,$81,$42,$24
.byte $00,$00,$00,$00,$00,$00,$00,$00

.byte $18,$3C,$7E,$FF,$7E,$3C,$18,$00
.byte $00,$00,$00,$00,$00,$00,$00,$00

.byte $3C,$66,$6E,$7E,$76,$66,$3C,$00
.byte $00,$00,$00,$00,$00,$00,$00,$00

.byte $18,$38,$18,$18,$18,$18,$7E,$00
.byte $00,$00,$00,$00,$00,$00,$00,$00

.byte $3C,$66,$06,$1C,$30,$60,$7E,$00
.byte $00,$00,$00,$00,$00,$00,$00,$00

.byte $3C,$66,$06,$1C,$06,$66,$3C,$00
.byte $00,$00,$00,$00,$00,$00,$00,$00

.byte $0E,$1E,$36,$66,$7F,$06,$06,$00
.byte $00,$00,$00,$00,$00,$00,$00,$00

.byte $7E,$60,$7C,$06,$06,$66,$3C,$00
.byte $00,$00,$00,$00,$00,$00,$00,$00

.byte $1C,$30,$60,$7C,$66,$66,$3C,$00
.byte $00,$00,$00,$00,$00,$00,$00,$00

.byte $7E,$06,$0C,$18,$30,$30,$30,$00
.byte $00,$00,$00,$00,$00,$00,$00,$00

.byte $3C,$66,$66,$3C,$66,$66,$3C,$00
.byte $00,$00,$00,$00,$00,$00,$00,$00

.byte $3C,$66,$66,$3E,$06,$0C,$38,$00
.byte $00,$00,$00,$00,$00,$00,$00,$00

.byte $18,$3C,$66,$66,$7E,$66,$66,$00
.byte $00,$00,$00,$00,$00,$00,$00,$00

.byte $7E,$60,$60,$7C,$60,$60,$7E,$00
.byte $00,$00,$00,$00,$00,$00,$00,$00

.byte $3C,$66,$60,$6E,$66,$66,$3C,$00
.byte $00,$00,$00,$00,$00,$00,$00,$00

.byte $63,$77,$7F,$6B,$63,$63,$63,$00
.byte $00,$00,$00,$00,$00,$00,$00,$00

.byte $66,$76,$7E,$7E,$6E,$66,$66,$00
.byte $00,$00,$00,$00,$00,$00,$00,$00

.byte $3C,$66,$66,$66,$66,$66,$3C,$00
.byte $00,$00,$00,$00,$00,$00,$00,$00

.byte $7C,$66,$66,$7C,$60,$60,$60,$00
.byte $00,$00,$00,$00,$00,$00,$00,$00

.byte $7C,$66,$66,$7C,$6C,$66,$66,$00
.byte $00,$00,$00,$00,$00,$00,$00,$00

.byte $3C,$66,$60,$3C,$06,$66,$3C,$00
.byte $00,$00,$00,$00,$00,$00,$00,$00

.byte $7E,$18,$18,$18,$18,$18,$18,$00
.byte $00,$00,$00,$00,$00,$00,$00,$00

.byte $66,$66,$66,$66,$66,$66,$3C,$00
.byte $00,$00,$00,$00,$00,$00,$00,$00

.byte $66,$66,$66,$66,$66,$3C,$18,$00
.byte $00,$00,$00,$00,$00,$00,$00,$00

.byte $66,$66,$3C,$18,$3C,$66,$66,$00
.byte $00,$00,$00,$00,$00,$00,$00,$00

.res 7984, $00
