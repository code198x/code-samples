;──────────────────────────────────────────────────────────────
; NEON NEXUS
; A fixed-screen action game for the Nintendo Entertainment System
; Unit 2: The Player
;──────────────────────────────────────────────────────────────

.segment "HEADER"
    .byte "NES", $1a        ; iNES magic number
    .byte 2                 ; 2 x 16KB PRG ROM = 32KB
    .byte 1                 ; 1 x 8KB CHR ROM
    .byte $01               ; Mapper 0, vertical mirroring
    .byte $00               ; Mapper 0 continued
    .byte 0,0,0,0,0,0,0,0   ; Padding

;──────────────────────────────────────────────────────────────
; Variables
;──────────────────────────────────────────────────────────────

.segment "ZEROPAGE"
frame_counter: .res 1

;──────────────────────────────────────────────────────────────
; Constants
;──────────────────────────────────────────────────────────────

.segment "CODE"

; PPU registers
PPUCTRL   = $2000
PPUMASK   = $2001
PPUSTATUS = $2002
OAMADDR   = $2003
PPUSCROLL = $2005
PPUADDR   = $2006
PPUDATA   = $2007

; OAM DMA register
OAMDMA    = $4014

;──────────────────────────────────────────────────────────────
; Reset handler
;──────────────────────────────────────────────────────────────

.proc reset
    sei                     ; Disable IRQs
    cld                     ; Disable decimal mode

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

    ; Clear RAM ($0000-$07FF)
    lda #$00
    ldx #0
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

    ; Clear shadow OAM to $FF (sprites off-screen)
    lda #$ff
    ldx #0
@clear_oam:
    sta $0200, x
    inx
    bne @clear_oam

    ; Wait for second vblank
@vblank2:
    bit PPUSTATUS
    bpl @vblank2

    ; Load palette
    jsr load_palette

    ; Fill background
    jsr fill_background

    ; Initialise player sprite (Sprite 0)
    lda #120                ; Y position
    sta $0200
    lda #1                  ; Tile index 1
    sta $0201
    lda #%00000000          ; Attributes: palette 0, no flip
    sta $0202
    lda #128                ; X position
    sta $0203

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
    jmp forever
.endproc

;──────────────────────────────────────────────────────────────
; NMI handler (called every vblank)
;──────────────────────────────────────────────────────────────

.proc nmi
    ; Preserve registers
    pha
    txa
    pha
    tya
    pha

    inc frame_counter

    ; OAM DMA transfer
    lda #$00
    sta OAMADDR             ; Set OAM address to 0
    lda #$02                ; High byte of $0200
    sta OAMDMA              ; Trigger DMA copy

    ; Reset scroll position
    lda #$00
    sta PPUSCROLL
    sta PPUSCROLL

    ; Restore registers
    pla
    tay
    pla
    tax
    pla

    rti
.endproc

;──────────────────────────────────────────────────────────────
; IRQ handler (unused)
;──────────────────────────────────────────────────────────────

.proc irq
    rti
.endproc

;──────────────────────────────────────────────────────────────
; Subroutines
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

.proc fill_background
    ; Set PPU address to nametable 0 ($2000)
    bit PPUSTATUS
    lda #$20
    sta PPUADDR
    lda #$00
    sta PPUADDR

    ; Fill with tile 0 (960 + 64 = 1024 bytes)
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

    ; Set PPU address to attribute table ($23C0)
    bit PPUSTATUS
    lda #$23
    sta PPUADDR
    lda #$c0
    sta PPUADDR

    ; Fill with colour zone pattern
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
; Data
;──────────────────────────────────────────────────────────────

palette_data:
    ; Background palettes
    .byte $0f, $11, $21, $31    ; Palette 0: Blues
    .byte $0f, $19, $29, $39    ; Palette 1: Greens
    .byte $0f, $15, $25, $35    ; Palette 2: Magentas
    .byte $0f, $00, $10, $30    ; Palette 3: Greys

    ; Sprite palettes
    .byte $0f, $30, $21, $11    ; Palette 0: White/Blue (player)
    .byte $0f, $19, $29, $39    ; Palette 1: Greens
    .byte $0f, $15, $25, $35    ; Palette 2: Magentas
    .byte $0f, $17, $27, $37    ; Palette 3: Oranges

attribute_data:
    ; 8 rows of 8 bytes = 64 bytes
    .byte $00, $00, $00, $00, $00, $00, $00, $00  ; Palette 0
    .byte $00, $00, $00, $00, $00, $00, $00, $00
    .byte $55, $55, $55, $55, $55, $55, $55, $55  ; Palette 1
    .byte $55, $55, $55, $55, $55, $55, $55, $55
    .byte $aa, $aa, $aa, $aa, $aa, $aa, $aa, $aa  ; Palette 2
    .byte $aa, $aa, $aa, $aa, $aa, $aa, $aa, $aa
    .byte $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff  ; Palette 3
    .byte $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff

;──────────────────────────────────────────────────────────────
; Vectors
;──────────────────────────────────────────────────────────────

.segment "VECTORS"
    .word nmi               ; $FFFA-$FFFB: NMI vector
    .word reset             ; $FFFC-$FFFD: Reset vector
    .word irq               ; $FFFE-$FFFF: IRQ vector

;──────────────────────────────────────────────────────────────
; CHR ROM (graphics)
;──────────────────────────────────────────────────────────────

.segment "CHARS"
    ; Tile 0: Solid block (background fill)
    .byte $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff  ; Plane 0
    .byte $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff  ; Plane 1

    ; Tile 1: Player ship
    .byte %00011000         ; ...XX...
    .byte %00111100         ; ..XXXX..
    .byte %01111110         ; .XXXXXX.
    .byte %11111111         ; XXXXXXXX
    .byte %11111111         ; XXXXXXXX
    .byte %00100100         ; ..X..X..
    .byte %00100100         ; ..X..X..
    .byte %01100110         ; .XX..XX.
    ; Plane 1 (all zeros = colour 1 only)
    .byte $00, $00, $00, $00, $00, $00, $00, $00

    ; Fill rest of 8KB CHR ROM
    .res 8192 - 32
