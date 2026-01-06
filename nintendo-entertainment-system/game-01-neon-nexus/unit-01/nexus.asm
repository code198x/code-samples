;──────────────────────────────────────────────────────────────
; NEON NEXUS
; A fixed-screen action game for the Nintendo Entertainment System
; Unit 1: The Grid
;──────────────────────────────────────────────────────────────
; Shows a simple coloured background - the neon grid awaits
;──────────────────────────────────────────────────────────────

.segment "HEADER"
;──────────────────────────────────────────────────────────────
; iNES header
;──────────────────────────────────────────────────────────────
    .byte "NES", $1a        ; iNES magic number
    .byte 2                 ; 2 x 16KB PRG ROM = 32KB
    .byte 1                 ; 1 x 8KB CHR ROM
    .byte $01               ; Mapper 0, vertical mirroring
    .byte $00               ; Mapper 0
    .byte 0,0,0,0,0,0,0,0   ; Padding

.segment "ZEROPAGE"
;──────────────────────────────────────────────────────────────
; Zero page variables
;──────────────────────────────────────────────────────────────
frame_counter: .res 1

.segment "CODE"
;──────────────────────────────────────────────────────────────
; Constants
;──────────────────────────────────────────────────────────────
PPUCTRL   = $2000
PPUMASK   = $2001
PPUSTATUS = $2002
OAMADDR   = $2003
PPUSCROLL = $2005
PPUADDR   = $2006
PPUDATA   = $2007

;──────────────────────────────────────────────────────────────
; Reset vector - entry point
;──────────────────────────────────────────────────────────────
.proc reset
    sei                     ; Disable IRQs
    cld                     ; Disable decimal mode (not on NES, but good practice)

    ldx #$40
    stx $4017               ; Disable APU frame IRQ

    ldx #$ff
    txs                     ; Set up stack

    inx                     ; X = 0
    stx PPUCTRL             ; Disable NMI
    stx PPUMASK             ; Disable rendering
    stx $4010               ; Disable DMC IRQs

    ; Wait for first vblank
    bit PPUSTATUS
@vblank1:
    bit PPUSTATUS
    bpl @vblank1

    ; Clear RAM during second vblank wait
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

    ; Wait for second vblank
@vblank2:
    bit PPUSTATUS
    bpl @vblank2

    ; PPU is now ready
    jsr load_palette
    jsr fill_background

    ; Enable rendering
    lda #%10000000          ; Enable NMI
    sta PPUCTRL
    lda #%00011110          ; Enable sprites and background
    sta PPUMASK

    ; Reset scroll
    lda #$00
    sta PPUSCROLL
    sta PPUSCROLL

forever:
    jmp forever             ; Main loop (NMI handles everything)
.endproc

;──────────────────────────────────────────────────────────────
; Load palette into PPU
;──────────────────────────────────────────────────────────────
.proc load_palette
    ; Set PPU address to palette ($3F00)
    bit PPUSTATUS           ; Reset address latch
    lda #$3f
    sta PPUADDR
    lda #$00
    sta PPUADDR

    ; Load 32 palette bytes
    ldx #0
@loop:
    lda palette_data, x
    sta PPUDATA
    inx
    cpx #32
    bne @loop
    rts
.endproc

;──────────────────────────────────────────────────────────────
; Fill background with a simple pattern
;──────────────────────────────────────────────────────────────
.proc fill_background
    ; Set PPU address to first nametable ($2000)
    bit PPUSTATUS
    lda #$20
    sta PPUADDR
    lda #$00
    sta PPUADDR

    ; Fill with tile $00 (960 tiles = 30 rows x 32 cols)
    lda #$00                ; Tile index 0
    ldx #0
    ldy #4                  ; 4 x 256 = 1024 bytes (covers nametable + attributes)
@outer:
@inner:
    sta PPUDATA
    inx
    bne @inner
    dey
    bne @outer

    ; Now set attribute table for colour variation
    ; Attribute table starts at $23C0
    bit PPUSTATUS
    lda #$23
    sta PPUADDR
    lda #$c0
    sta PPUADDR

    ; Fill attributes - creates colour zones
    ; Each byte controls 4x4 tiles (32x32 pixels)
    ; Bits: 33221100 (bottom-right, bottom-left, top-right, top-left)
    ldx #0
@attr_loop:
    lda attribute_data, x
    sta PPUDATA
    inx
    cpx #64
    bne @attr_loop

    rts
.endproc

;──────────────────────────────────────────────────────────────
; NMI handler (called every vblank)
;──────────────────────────────────────────────────────────────
.proc nmi
    ; Just increment frame counter for now
    inc frame_counter

    ; Reset scroll (important!)
    lda #$00
    sta PPUSCROLL
    sta PPUSCROLL

    rti
.endproc

;──────────────────────────────────────────────────────────────
; IRQ handler (unused)
;──────────────────────────────────────────────────────────────
.proc irq
    rti
.endproc

;──────────────────────────────────────────────────────────────
; Data
;──────────────────────────────────────────────────────────────
palette_data:
    ; Background palettes (4 palettes x 4 colours)
    .byte $0f, $11, $21, $31    ; Palette 0: Black, dark blue, med blue, light blue
    .byte $0f, $19, $29, $39    ; Palette 1: Black, dark green, med green, light green
    .byte $0f, $15, $25, $35    ; Palette 2: Black, dark magenta, med magenta, light magenta
    .byte $0f, $00, $10, $30    ; Palette 3: Black, dark grey, grey, white

    ; Sprite palettes (4 palettes x 4 colours)
    .byte $0f, $11, $21, $31    ; Palette 0
    .byte $0f, $19, $29, $39    ; Palette 1
    .byte $0f, $15, $25, $35    ; Palette 2
    .byte $0f, $00, $10, $30    ; Palette 3

attribute_data:
    ; 8 rows of 8 bytes each = 64 bytes
    ; Creates horizontal stripes of different palettes
    .byte $00, $00, $00, $00, $00, $00, $00, $00  ; Row 0-3: Palette 0 (blue)
    .byte $00, $00, $00, $00, $00, $00, $00, $00
    .byte $55, $55, $55, $55, $55, $55, $55, $55  ; Row 4-7: Palette 1 (green)
    .byte $55, $55, $55, $55, $55, $55, $55, $55
    .byte $aa, $aa, $aa, $aa, $aa, $aa, $aa, $aa  ; Row 8-11: Palette 2 (magenta)
    .byte $aa, $aa, $aa, $aa, $aa, $aa, $aa, $aa
    .byte $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff  ; Row 12-15: Palette 3 (grey)
    .byte $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff

.segment "VECTORS"
;──────────────────────────────────────────────────────────────
; CPU vectors
;──────────────────────────────────────────────────────────────
    .word nmi               ; NMI vector
    .word reset             ; Reset vector
    .word irq               ; IRQ vector

.segment "CHARS"
;──────────────────────────────────────────────────────────────
; CHR ROM - Pattern tables (8KB)
; Tile 0 = solid block (all pixels set)
;──────────────────────────────────────────────────────────────
    ; Tile 0: Solid block
    .byte $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff  ; Plane 0
    .byte $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff  ; Plane 1

    ; Remaining tiles: empty (filled to 8KB)
    .res 8192 - 16
