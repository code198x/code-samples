;──────────────────────────────────────────────────────────────
; NEON NEXUS - Unit 12 sample (Music loop + SFX coexistence)
; Builds on Unit 11: SFX, HUD, lives, state machine. Adds a simple
; background music loop on pulse1+triangle while keeping SFX on noise.
; Buttons: B triggers HIT (noise), A triggers PICKUP (pulse). Music runs.
;──────────────────────────────────────────────────────────────

.segment "HEADER"
    .byte "NES", $1a, 2, 1, $01, $00, 0,0,0,0,0,0,0,0

.segment "ZEROPAGE"
frame_counter: .res 1
player_x:      .res 1
player_y:      .res 1
hud_dirty:     .res 1
score0:        .res 1
score1:        .res 1
score2:        .res 1
controller1:   .res 1
lives:         .res 1
respawn_timer: .res 1
player_alive:  .res 1
game_state:    .res 1
sfx_active:    .res 1
sfx_type:      .res 1
sfx_timer:     .res 1
music_pos:     .res 1

.segment "CODE"
PPUCTRL   = $2000
PPUMASK   = $2001
PPUSTATUS = $2002
OAMADDR   = $2003
PPUSCROLL = $2005
PPUADDR   = $2006
PPUDATA   = $2007
OAMDMA    = $4014
JOY1      = $4016
APU_PULSE1    = $4000
APU_PULSE1_SW = $4001
APU_PULSE1_LO = $4002
APU_PULSE1_HI = $4003
APU_TRI_CTRL  = $4008
APU_TRI_LO    = $400a
APU_TRI_HI    = $400b
APU_NOISE_VOL = $400C
APU_NOISE_LO  = $400E
APU_NOISE_LEN = $400F
APU_STATUS    = $4015

BTN_A     = %10000000
BTN_B     = %01000000
BTN_START = %00010000
BTN_UP    = %00001000
BTN_DOWN  = %00000100
BTN_LEFT  = %00000010
BTN_RIGHT = %00000001

STATE_TITLE    = $00
STATE_PLAY     = $01
STATE_GAMEOVER = $02

HUD_ROW       = 0
HUD_COL       = 2
HUD_SCORE_COL = HUD_COL + 6
HUD_LIVES_COL = HUD_SCORE_COL + 8
TILE_ZERO     = $30
TILE_L        = $20

.proc reset
    sei
    cld
    ldx #$40
    stx $4017
    ldx #$ff
    txs
    inx
    stx PPUCTRL
    stx PPUMASK
    stx $4010

    bit PPUSTATUS
@v1:
    bit PPUSTATUS
    bpl @v1

    lda #$00
@clr:
    sta $0000, x
    sta $0100, x
    sta $0200, x
    sta $0300, x
    sta $0400, x
    sta $0500, x
    sta $0600, x
    sta $0700, x
    inx
    bne @clr

@v2:
    bit PPUSTATUS
    bpl @v2

    jsr reset_run_state
    lda #STATE_TITLE
    sta game_state

    jsr load_palette
    jsr fill_background
    jsr draw_title
    jsr build_oam
    jsr upload_oam
    jsr apu_init

    lda #%10000000
    sta PPUCTRL
    lda #%00011110
    sta PPUMASK

    lda #0
    sta PPUSCROLL
    sta PPUSCROLL

main:
    jmp main
.endproc

.proc nmi
    inc frame_counter
    jsr read_controller

    lda game_state
    beq title_loop
    cmp #STATE_PLAY
    beq play_loop
    cmp #STATE_GAMEOVER
    beq game_over_loop
    rti
.endproc

.proc title_loop
    lda controller1
    and #(BTN_START|BTN_A)
    beq @done
    jsr reset_run_state
    jsr draw_playfield
    lda #STATE_PLAY
    sta game_state
@done:
    rti
.endproc

.proc play_loop
    lda controller1
    and #BTN_B
    beq @skip_hit
    jsr lose_life
    jsr trigger_sfx_hit
@skip_hit:
    lda controller1
    and #BTN_A
    beq @skip_pick
    jsr add_score_10
    jsr trigger_sfx_pickup
@skip_pick:

    jsr update_player
    jsr build_oam
    jsr upload_oam

    jsr apu_step_music
    jsr apu_step_sfx

    lda hud_dirty
    beq @hud_ok
    jsr draw_hud
    lda #0
    sta hud_dirty
@hud_ok:
    lda #0
    sta PPUSCROLL
    sta PPUSCROLL

    lda lives
    bne @alive
    lda #STATE_GAMEOVER
    sta game_state
@alive:
    rti
.endproc

.proc game_over_loop
    jsr draw_game_over
    lda controller1
    and #(BTN_START|BTN_A)
    beq @done
    jsr reset_run_state
    jsr draw_playfield
    lda #STATE_PLAY
    sta game_state
@done:
    rti
.endproc

.proc irq
    rti
.endproc

;------------------------------------------------------------
; Controller
;------------------------------------------------------------
.proc read_controller
    lda #1
    sta JOY1
    lda #0
    sta JOY1
    ldx #8
    lda #0
    sta controller1
@loop:
    lda JOY1
    lsr
    rol controller1
    dex
    bne @loop
    rts
.endproc

;------------------------------------------------------------
; Player movement
;------------------------------------------------------------
.proc update_player
    lda respawn_timer
    beq @move
    dec respawn_timer
    rts
@move:
    lda controller1
    and #BTN_LEFT
    beq @skip_left
    dec player_x
@skip_left:
    lda controller1
    and #BTN_RIGHT
    beq @skip_right
    inc player_x
@skip_right:
    lda controller1
    and #BTN_UP
    beq @skip_up
    dec player_y
@skip_up:
    lda controller1
    and #BTN_DOWN
    beq @skip_down
    inc player_y
@skip_down:
    rts
.endproc

;------------------------------------------------------------
; OAM handling
;------------------------------------------------------------
player_oam = $0200

.proc build_oam
    lda player_y
    sta player_oam
    lda #$00
    sta player_oam+1
    lda #%00000000
    sta player_oam+2
    lda player_x
    sta player_oam+3
    rts
.endproc

.proc upload_oam
    lda #$00
    sta OAMADDR
    lda #$02
    sta OAMDMA
    rts
.endproc

;------------------------------------------------------------
; HUD Score + Lives
;------------------------------------------------------------
.proc add_score_10
    clc
    lda score0
    adc #$10
    jsr fix_bcd
    lda score1
    adc #$00
    jsr fix_bcd
    lda score2
    adc #$00
    jsr fix_bcd
    lda #1
    sta hud_dirty
    rts
.endproc

.proc fix_bcd
    cmp #$a0
    bcc @ok
    sbc #$a0
    adc #$10
@ok:
    rts
.endproc

.proc lose_life
    lda lives
    beq @game_over
    dec lives
    lda #1
    sta hud_dirty
    lda #30
    sta respawn_timer
    jsr reset_position
    rts
@game_over:
    lda #0
    sta player_alive
    rts
.endproc

.proc reset_position
    lda #120
    sta player_x
    lda #180
    sta player_y
    rts
.endproc

.proc draw_hud
    bit PPUSTATUS
    lda #$20 + HUD_ROW
    sta PPUADDR
    lda #HUD_COL
    sta PPUADDR

    ldx #0
@text:
    lda hud_label, x
    beq @digits
    sta PPUDATA
    inx
    bne @text
@digits:
    lda score2
    jsr bcd_to_tiles
    lda score1
    jsr bcd_to_tiles
    lda score0
    jsr bcd_to_tiles

    lda #$20 + HUD_ROW
    sta PPUADDR
    lda #HUD_LIVES_COL
    sta PPUADDR
    lda lives_label
    sta PPUDATA
    lda lives_label+1
    sta PPUDATA
    lda lives
    ora #TILE_ZERO
    sta PPUDATA
    rts
.endproc

.proc bcd_to_tiles
    pha
    lsr
    lsr
    lsr
    lsr
    ora #TILE_ZERO
    sta PPUDATA
    pla
    and #$0f
    ora #TILE_ZERO
    sta PPUDATA
    rts
.endproc

hud_label:
    .byte "SCORE ", 0
lives_label:
    .byte "L", "I"

;------------------------------------------------------------
; State resets and screens
;------------------------------------------------------------
.proc reset_run_state
    lda #0
    sta frame_counter
    sta hud_dirty
    sta score0
    sta score1
    sta score2
    lda #3
    sta lives
    lda #0
    sta respawn_timer
    lda #1
    sta player_alive
    lda #0
    sta sfx_active
    sta sfx_timer
    sta music_pos
    jsr reset_position
    rts
.endproc

.proc draw_title
    bit PPUSTATUS
    lda #$20
    sta PPUADDR
    lda #$02
    sta PPUADDR
    ldx #0
@t:
    lda title_text, x
    beq @done
    sta PPUDATA
    inx
    bne @t
@done:
    rts
.endproc

.proc draw_game_over
    bit PPUSTATUS
    lda #$21
    sta PPUADDR
    lda #$04
    sta PPUADDR
    ldx #0
@g:
    lda go_text, x
    beq @done
    sta PPUDATA
    inx
    bne @g
@done:
    rts
.endproc

.proc draw_playfield
    jsr fill_background
    lda #1
    sta hud_dirty
    jsr draw_hud
    rts
.endproc

title_text: .byte "NEON NEXUS - START/A TO PLAY",0
go_text:    .byte "GAME OVER - START/A TO RESTART",0

;------------------------------------------------------------
; Palette / background
;------------------------------------------------------------
.proc load_palette
    bit PPUSTATUS
    lda #$3f
    sta PPUADDR
    lda #$00
    sta PPUADDR
    ldx #0
@lp:
    lda palette_data, x
    sta PPUDATA
    inx
    cpx #32
    bne @lp
    rts
.endproc

.proc fill_background
    bit PPUSTATUS
    lda #$20
    sta PPUADDR
    lda #$00
    sta PPUADDR

    lda #$00
    ldx #0
    ldy #4
@outer:
@inner:
    sta PPUDATA
    inx
    bne @inner
    dey
    bne @outer

    bit PPUSTATUS
    lda #$23
    sta PPUADDR
    lda #$c0
    sta PPUADDR

    ldx #0
@attr:
    lda attribute_data, x
    sta PPUDATA
    inx
    cpx #64
    bne @attr
    rts
.endproc

palette_data:
    .byte $0f, $11, $21, $31
    .byte $0f, $19, $29, $39
    .byte $0f, $15, $25, $35
    .byte $0f, $00, $10, $30
    .byte $0f, $11, $21, $31
    .byte $0f, $19, $29, $39
    .byte $0f, $15, $25, $35
    .byte $0f, $00, $10, $30

attribute_data:
    .byte $00,$00,$00,$00,$00,$00,$00,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00
    .byte $55,$55,$55,$55,$55,$55,$55,$55
    .byte $55,$55,$55,$55,$55,$55,$55,$55
    .byte $aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa
    .byte $aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa
    .byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
    .byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff

;------------------------------------------------------------
; APU Sound: music + SFX
;------------------------------------------------------------
.proc apu_init
    lda #%00010111        ; enable pulse1, triangle, noise
    sta APU_STATUS
    lda #%00111111        ; pulse1 vol 15
    sta APU_PULSE1
    lda #%00000000
    sta APU_PULSE1_SW
    lda #$00
    sta APU_PULSE1_LO
    lda #$00
    sta APU_PULSE1_HI
    lda #%10000000        ; triangle linear counter length enable
    sta APU_TRI_CTRL
    lda #$00
    sta APU_TRI_LO
    lda #$00
    sta APU_TRI_HI
    lda #%00001111        ; noise vol 15
    sta APU_NOISE_VOL
    lda #$0f
    sta APU_NOISE_LO
    lda #$00
    sta APU_NOISE_LEN
    rts
.endproc

; Music data: simple two-note loop (periods for pulse/tri)
music_table:
    .byte $30,$02   ; pulse low, tri low
    .byte $40,$04
    .byte $00,$00   ; terminator

.proc apu_step_music
    lda music_pos
    tay
    lda music_table,y
    beq @reset
    sta APU_PULSE1_LO
    lda music_table+1,y
    sta APU_TRI_LO
    iny
    iny
    sty music_pos
    rts
@reset:
    lda #0
    sta music_pos
    rts
.endproc

SFX_HIT    = 1
SFX_PICKUP = 2

.proc trigger_sfx_hit
    lda #SFX_HIT
    sta sfx_type
    lda #6
    sta sfx_timer
    lda #1
    sta sfx_active
    rts
.endproc

.proc trigger_sfx_pickup
    lda #SFX_PICKUP
    sta sfx_type
    lda #6
    sta sfx_timer
    lda #1
    sta sfx_active
    rts
.endproc

.proc apu_step_sfx
    lda sfx_active
    bne @do
    rts
@do:
    lda sfx_type
    cmp #SFX_HIT
    beq @hit
    cmp #SFX_PICKUP
    beq @pickup
    rts
@hit:
    lda #%00001111
    sta APU_NOISE_VOL
    lda #$04
    sta APU_NOISE_LO
    lda #$00
    sta APU_NOISE_LEN
    jmp @dec
@pickup:
    lda #%00111111
    sta APU_PULSE1
    lda #$30
    sta APU_PULSE1_LO
    lda #%00000000
    sta APU_PULSE1_HI
@dec:
    dec sfx_timer
    bne @done
    lda #0
    sta APU_NOISE_VOL
    sta APU_PULSE1
    lda #0
    sta sfx_active
@done:
    rts
.endproc

;------------------------------------------------------------
.segment "VECTORS"
    .word nmi
    .word reset
    .word irq

.segment "CHARS"
    .byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
    .byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
    .res 8192-16
