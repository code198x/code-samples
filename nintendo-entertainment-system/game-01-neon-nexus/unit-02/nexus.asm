;──────────────────────────────────────────────────────────────
; NEON NEXUS - Unit 2 sample (Player sprite)
; Adds a single 8x8 sprite on top of the Unit 1 background.
; Movement is not yet included (handled in Unit 3).
;──────────────────────────────────────────────────────────────

.segment "HEADER"
    .byte "NES", $1a, 2, 1, $01, $00, 0,0,0,0,0,0,0,0

.segment "ZEROPAGE"
frame_counter: .res 1
player_x:      .res 1
player_y:      .res 1

.segment "CODE"
PPUCTRL   = $2000
PPUMASK   = $2001
PPUSTATUS = $2002
OAMADDR   = $2003
PPUSCROLL = $2005
PPUADDR   = $2006
PPUDATA   = $2007
OAMDMA    = $4014

HUD_ROW       = 0
HUD_COL       = 2

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

    jsr load_palette
    jsr fill_background
    jsr build_oam
    jsr upload_oam

    lda #%10000000
    sta PPUCTRL       ; enable NMI
    lda #%00011110
    sta PPUMASK       ; bg + sprites

    lda #0
    sta PPUSCROLL
    sta PPUSCROLL

main:
    jmp main
.endproc

.proc nmi
    inc frame_counter
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
; OAM: single sprite
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
    lda #$02           ; use $0200 buffer
    sta OAMDMA
    rts
.endproc

.segment "OAM"
.org $0200
player_oam:
    .byte 0,1,%00000000,0

.segment "CODE"
;------------------------------------------------------------
; Palette / background from Unit 1
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

.segment "VECTORS"
    .word nmi
    .word reset
    .word irq

.segment "CHARS"
    .byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
    .byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
    .res 8192-16
