;──────────────────────────────────────────────────────────────
; NEON NEXUS - Unit 6 sample (Collision stub)
; Adds collision detection between player and enemies/items.
; On enemy hit: player is knocked back and flagged. On item pickup: item is removed.
;──────────────────────────────────────────────────────────────

.segment "HEADER"
    .byte "NES", $1a, 2, 1, $01, $00, 0,0,0,0,0,0,0,0

.segment "ZEROPAGE"
frame_counter: .res 1
player_x:      .res 1
player_y:      .res 1
controller1:   .res 1
enemy_x:       .res 3
enemy_y:       .res 3
item_x:        .res 2
item_y:        .res 2
hit_flag:      .res 1
pickup_flag:   .res 1
items_left:    .res 1

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

BTN_LEFT  = %00000010
BTN_RIGHT = %00000001
BTN_UP    = %00001000
BTN_DOWN  = %00000100

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
    sta hit_flag
    sta pickup_flag
    lda #120
    sta player_x
    lda #180
    sta player_y

    lda #40
    sta enemy_x
    lda #80
    sta enemy_y
    lda #200
    sta enemy_x+1
    lda #120
    sta enemy_y+1
    lda #140
    sta enemy_x+2
    lda #60
    sta enemy_y+2

    lda #60
    sta item_x
    lda #140
    sta item_y
    lda #220
    sta item_x+1
    lda #140
    sta item_y+1

    lda #2
    sta items_left

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
    jsr update_player
    jsr move_enemies
    jsr pulse_items
    jsr check_collisions
    jsr build_oam
    jsr upload_oam
    lda #0
    sta PPUSCROLL
    sta PPUSCROLL
    rti
.endproc

.proc irq
    rti
.endproc

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

.proc move_enemies
    ldx #0
@loop:
    lda frame_counter
    and #%00000001
    beq :+
    inc enemy_x, x
    jmp :++
:   dec enemy_x, x
:
    inx
    cpx #3
    bne @loop
    rts
.endproc

.proc pulse_items
    lda frame_counter
    and #%00000010
    beq :down
    inc item_y
    inc item_y+1
    rts
:down
    dec item_y
    dec item_y+1
    rts
.endproc

;------------------------------------------------------------
; Simple AABB overlap (8x8 vs 8x8)
;------------------------------------------------------------
.proc check_collisions
    lda #0
    sta hit_flag
    sta pickup_flag

    ; player vs enemies
    ldx #0
@e:
    lda player_x
    sec
    sbc enemy_x, x
    cmp #8
    bcs :next_e
    lda player_y
    sec
    sbc enemy_y, x
    cmp #8
    bcs :next_e
    lda #1
    sta hit_flag
:    lda player_x         ; simple knockback on hit
    sec
    sbc #8
    sta player_x
:next_e
    inx
    cpx #3
    bne @e

    ; player vs items
    ldx #0
@i:
    lda items_left
    beq :next_i
    lda player_x
    sec
    sbc item_x, x
    cmp #8
    bcs :next_i
    lda player_y
    sec
    sbc item_y, x
    cmp #8
    bcs :next_i
    lda #1
    sta pickup_flag
    ; remove item
    lda #0
    sta item_x, x
    sta item_y, x
    dec items_left
:next_i
    inx
    cpx #2
    bne @i
    rts
.endproc

.proc build_oam
    lda #$00
    sta OAMADDR

    ; player
    lda player_y
    sta player_oam
    lda #$00
    sta player_oam+1
    lda #%00000000
    sta player_oam+2
    lda player_x
    sta player_oam+3

    ; enemies
    ldx #0
@e:
    lda enemy_y, x
    sta player_oam+4 + (4*x)
    lda #$02
    sta player_oam+5 + (4*x)
    lda #%00000001
    sta player_oam+6 + (4*x)
    lda enemy_x, x
    sta player_oam+7 + (4*x)
    inx
    cpx #3
    bne @e

    ; items
    lda item_y
    sta player_oam+16
    lda #$04
    sta player_oam+17
    lda #%00000010
    sta player_oam+18
    lda item_x
    sta player_oam+19

    lda item_y+1
    sta player_oam+20
    lda #$04
    sta player_oam+21
    lda #%00000010
    sta player_oam+22
    lda item_x+1
    sta player_oam+23

    ; change sprite attribute if hit/pickup
    lda hit_flag
    beq :nohit
    lda #%00000011
    sta player_oam+2
:nohit
    lda pickup_flag
    beq :nopick
    lda #%00000100
    sta player_oam+18
    sta player_oam+22
:nopick
    rts
.endproc

.proc upload_oam
    lda #$00
    sta OAMADDR
    lda #$02
    sta OAMDMA
    rts
.endproc

.segment "OAM"
.org $0200
player_oam:
    .res 4*6

.segment "CODE"
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

.segment "VECTORS"
    .word nmi
    .word reset
    .word irq

.segment "CHARS"
    .byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
    .byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
    .res 8192-16
