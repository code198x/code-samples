;──────────────────────────────────────────────────────────────
; NEON NEXUS
; A fixed-screen action game for the Nintendo Entertainment System
; Unit 1: The Grid
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

.segment "CODE"
PPUCTRL   = $2000
PPUMASK   = $2001
PPUSTATUS = $2002
OAMADDR   = $2003
PPUSCROLL = $2005
PPUADDR   = $2006
PPUDATA   = $2007

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
@vblank1:
    bit PPUSTATUS
    bpl @vblank1

    lda #$00
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
    jsr fill_background

    lda #%10000000
    sta PPUCTRL
    lda #%00011110
    sta PPUMASK

    lda #$00
    sta PPUSCROLL
    sta PPUSCROLL

forever:
    jmp forever
.endproc

.proc load_palette
    bit PPUSTATUS
    lda #$3f
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
@attr_loop:
    lda attribute_data, x
    sta PPUDATA
    inx
    cpx #64
    bne @attr_loop
    rts
.endproc

.proc nmi
    inc frame_counter
    lda #$00
    sta PPUSCROLL
    sta PPUSCROLL
    rti
.endproc

.proc irq
    rti
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
    .byte $00, $00, $00, $00, $00, $00, $00, $00
    .byte $00, $00, $00, $00, $00, $00, $00, $00
    .byte $55, $55, $55, $55, $55, $55, $55, $55
    .byte $55, $55, $55, $55, $55, $55, $55, $55
    .byte $aa, $aa, $aa, $aa, $aa, $aa, $aa, $aa
    .byte $aa, $aa, $aa, $aa, $aa, $aa, $aa, $aa
    .byte $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    .byte $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff

.segment "VECTORS"
    .word nmi
    .word reset
    .word irq

.segment "CHARS"
    .byte $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    .byte $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    .res 8192 - 16
