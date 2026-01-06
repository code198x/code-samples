;──────────────────────────────────────────────────────────────
; NEON NEXUS - Unit 7 sample (HUD score)
; Includes: PPU init, grid background, player sprite + movement,
; basic controller read, and HUD score (BCD) with a fake pickup
; on button B to test scoring. Extend/replace collision as needed.
;──────────────────────────────────────────────────────────────

.segment "HEADER"
    .byte "NES", $1a
    .byte 2           ; PRG 32KB
    .byte 1           ; CHR 8KB
    .byte $01         ; Mapper0, vertical mirroring
    .byte $00
    .byte 0,0,0,0,0,0,0,0

.segment "ZEROPAGE"
frame_counter: .res 1
player_x:      .res 1
player_y:      .res 1
hud_dirty:     .res 1
score0:        .res 1   ; BCD low
score1:        .res 1
score2:        .res 1
controller1:   .res 1

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
TILE_ZERO     = $30          ; adjust if digits differ

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

    lda #120
    sta player_x
    lda #180
    sta player_y

    jsr load_palette
    jsr fill_background
    jsr build_oam
    jsr upload_oam

    lda #%10000000
    sta PPUCTRL       ; enable NMI
    lda #%00011110
    sta PPUMASK       ; enable bg + sprites

    lda #0
    sta PPUSCROLL
    sta PPUSCROLL

main:
    jmp main
.endproc

.proc nmi
    inc frame_counter
    jsr read_controller
    jsr update_player
    jsr build_oam
    jsr upload_oam
    ; fake pickup: press B to add 10 points
    lda controller1
    and #BTN_B
    beq :+
    jsr add_score_10
:
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
; Player movement
;------------------------------------------------------------
.proc update_player
    lda controller1
    and #BTN_LEFT
    beq :+
    dec player_x
:
    lda controller1
    and #BTN_RIGHT
    beq :+
    inc player_x
:
    lda controller1
    and #BTN_UP
    beq :+
    dec player_y
:
    lda controller1
    and #BTN_DOWN
    beq :+
    inc player_y
:
    rts
.endproc

;------------------------------------------------------------
; OAM handling: single sprite
;------------------------------------------------------------
.proc build_oam
    lda player_y
    sta player_oam
    lda #$00           ; tile index
    sta player_oam+1
    lda #%00000000     ; attributes
    sta player_oam+2
    lda player_x
    sta player_oam+3
    rts
.endproc

.proc upload_oam
    lda #$00
    sta OAMADDR
    lda #$02           ; page 2 OAM buffer
    sta OAMDMA
    rts
.endproc

player_oam = $0200
;------------------------------------------------------------
; HUD Score
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
    bcc :+
    sbc #$a0
    adc #$10
:
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

;------------------------------------------------------------
; Palette / background grid
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
; Vectors
;------------------------------------------------------------
.segment "VECTORS"
    .word nmi
    .word reset
    .word irq

;------------------------------------------------------------
; CHR placeholder
;------------------------------------------------------------
.segment "CHARS"
    .byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
    .byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
    .res 8192-16
