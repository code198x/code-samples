;──────────────────────────────────────────────────────────────
; NEON NEXUS - Unit 8 sample (Score + Lives + Respawn)
; Includes: PPU init, grid, player sprite/movement, HUD score and lives,
; fake collisions via B (lose life) and A (add score), respawn with timer.
; Game over flag when lives reach zero (no title screen yet).
;──────────────────────────────────────────────────────────────

.segment "HEADER"
    .byte "NES", $1a
    .byte 2
    .byte 1
    .byte $01
    .byte $00
    .byte 0,0,0,0,0,0,0,0

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

BTN_A     = %10000000
BTN_B     = %01000000
BTN_START = %00010000
BTN_UP    = %00001000
BTN_DOWN  = %00000100
BTN_LEFT  = %00000010
BTN_RIGHT = %00000001

HUD_ROW       = 0
HUD_COL       = 2
HUD_SCORE_COL = HUD_COL + 6
HUD_LIVES_COL = HUD_SCORE_COL + 8
TILE_ZERO     = $30
TILE_L        = $20   ; adjust if needed for letters

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

    lda #120
    sta player_x
    lda #180
    sta player_y

    jsr load_palette
    jsr fill_background
    jsr build_oam
    jsr upload_oam

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

    ; Fake collision: B loses a life, A adds score
    lda controller1
    and #BTN_B
    beq :+
    jsr lose_life
:
    lda controller1
    and #BTN_A
    beq :+
    jsr add_score_10
:

    jsr update_player
    jsr build_oam
    jsr upload_oam

    lda hud_dirty
    beq :+
    jsr draw_hud
    lda #0
    sta hud_dirty
:
    lda #0
    sta PPUSCROLL
    sta PPUSCROLL
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
; Player movement (disabled during respawn timer)
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
; OAM handling: single sprite
;------------------------------------------------------------
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

player_oam = $0200
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
    lda player_alive
    beq @done           ; already dead/game over
    lda lives
    beq @game_over
    dec lives
    lda #1
    sta hud_dirty
    lda #30            ; respawn delay frames
    sta respawn_timer
    lda #1
    sta player_alive
    jsr reset_position
    rts
@game_over:
    lda #0
    sta player_alive
    rts
@done:
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

    ; lives label
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
.segment "VECTORS"
    .word nmi
    .word reset
    .word irq

.segment "CHARS"
    .byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
    .byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
    .res 8192-16
