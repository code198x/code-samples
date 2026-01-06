;──────────────────────────────────────────────────────────────
; NEON NEXUS - Unit 4 sample (Enemies placeholder + OAM slots)
; Adds enemies using sprite slots with simple horizontal movement + wrap.
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
    lda #120
    sta player_x
    lda #180
    sta player_y

    ; init enemies
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
    ; dummy oscillation on X
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

.proc build_oam
    lda #$00
    sta OAMADDR

    ; player at slot 0
    lda player_y
    sta player_oam
    lda #$00
    sta player_oam+1
    lda #%00000000
    sta player_oam+2
    lda player_x
    sta player_oam+3

    ; enemies slots 1-3
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
    .res 4*4   ; player + 3 enemies

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
