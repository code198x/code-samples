;──────────────────────────────────────────────────────────────
; NEON NEXUS
; A fixed-screen action game for the Nintendo Entertainment System
; Unit 5: Items
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
buttons:       .res 1
player_x:      .res 1
player_y:      .res 1
enemy_x:       .res 4       ; X positions for 4 enemies
enemy_y:       .res 4       ; Y positions for 4 enemies
item_x:        .res 1       ; Item X position
item_y:        .res 1       ; Item Y position
score:         .res 1       ; Items collected

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

; Controller
JOYPAD1   = $4016

; Button bit positions
BTN_A      = %00000001
BTN_B      = %00000010
BTN_SELECT = %00000100
BTN_START  = %00001000
BTN_UP     = %00010000
BTN_DOWN   = %00100000
BTN_LEFT   = %01000000
BTN_RIGHT  = %10000000

; Game constants
NUM_ENEMIES = 4

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

    ; Initialise player position
    lda #128                ; X position (centre)
    sta player_x
    lda #200                ; Y position (near bottom)
    sta player_y

    ; Initialise player sprite (Sprite 0)
    lda player_y
    sta $0200               ; Y position
    lda #1                  ; Tile index 1 (player ship)
    sta $0201
    lda #%00000000          ; Attributes: palette 0, no flip
    sta $0202
    lda player_x
    sta $0203               ; X position

    ; Initialise enemies
    jsr init_enemies

    ; Initialise item
    jsr init_item

    ; Initialise score
    lda #0
    sta score

    ; Enable rendering
    lda #%10000000          ; Enable NMI
    sta PPUCTRL
    lda #%00011110          ; Enable sprites and background
    sta PPUMASK

    ; Reset scroll
    lda #$00
    sta PPUSCROLL
    sta PPUSCROLL

    ; Main loop
forever:
    lda frame_counter
@wait:
    cmp frame_counter       ; Has NMI fired?
    beq @wait               ; No - keep waiting

    jsr read_controller
    jsr update_player
    jsr move_enemies
    jsr update_enemy_sprites
    jsr update_item_sprite
    jsr check_item_collision

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
; Read controller
;──────────────────────────────────────────────────────────────

.proc read_controller
    ; Strobe controller
    lda #$01
    sta JOYPAD1             ; Strobe on
    lda #$00
    sta JOYPAD1             ; Strobe off

    ; Read 8 buttons
    ldx #8
@loop:
    lda JOYPAD1             ; Read next button (bit 0)
    lsr a                   ; Shift bit 0 into carry
    rol buttons             ; Roll carry into buttons byte
    dex
    bne @loop
    rts
.endproc

;──────────────────────────────────────────────────────────────
; Update player position
;──────────────────────────────────────────────────────────────

.proc update_player
    ; Check Up
    lda buttons
    and #BTN_UP
    beq @check_down
    lda player_y
    cmp #8                  ; Top boundary
    bcc @check_down
    dec player_y

@check_down:
    lda buttons
    and #BTN_DOWN
    beq @check_left
    lda player_y
    cmp #224                ; Bottom boundary
    bcs @check_left
    inc player_y

@check_left:
    lda buttons
    and #BTN_LEFT
    beq @check_right
    lda player_x
    cmp #8                  ; Left boundary
    bcc @check_right
    dec player_x

@check_right:
    lda buttons
    and #BTN_RIGHT
    beq @done
    lda player_x
    cmp #240                ; Right boundary
    bcs @done
    inc player_x

@done:
    ; Copy position to shadow OAM
    lda player_y
    sta $0200               ; Sprite 0 Y position
    lda player_x
    sta $0203               ; Sprite 0 X position
    rts
.endproc

;──────────────────────────────────────────────────────────────
; Initialise enemies
;──────────────────────────────────────────────────────────────

.proc init_enemies
    ; Enemy 0: left side
    lda #50
    sta enemy_x
    lda #32
    sta enemy_y

    ; Enemy 1: left-centre
    lda #100
    sta enemy_x + 1
    lda #48
    sta enemy_y + 1

    ; Enemy 2: right-centre
    lda #156
    sta enemy_x + 2
    lda #24
    sta enemy_y + 2

    ; Enemy 3: right side
    lda #206
    sta enemy_x + 3
    lda #40
    sta enemy_y + 3

    rts
.endproc

;──────────────────────────────────────────────────────────────
; Move enemies
;──────────────────────────────────────────────────────────────

.proc move_enemies
    ldx #0                  ; Start with enemy 0
@loop:
    ; Move enemy down (increment Y)
    inc enemy_y, x

    ; Check if off bottom of screen
    lda enemy_y, x
    cmp #232                ; Past visible area?
    bcc @next               ; No - continue

    ; Wrap to top
    lda #0
    sta enemy_y, x

@next:
    inx                     ; Next enemy
    cpx #NUM_ENEMIES        ; All done?
    bne @loop               ; No - loop
    rts
.endproc

;──────────────────────────────────────────────────────────────
; Update enemy sprites
;──────────────────────────────────────────────────────────────

.proc update_enemy_sprites
    ldx #0                  ; Enemy index
    ldy #4                  ; OAM offset (skip sprite 0)
@loop:
    ; Y position
    lda enemy_y, x
    sta $0200, y
    iny

    ; Tile index (enemy graphic)
    lda #2                  ; Tile 2 = enemy ship
    sta $0200, y
    iny

    ; Attributes (palette 1, no flip)
    lda #%00000001          ; Sprite palette 1
    sta $0200, y
    iny

    ; X position
    lda enemy_x, x
    sta $0200, y
    iny

    ; Next enemy
    inx
    cpx #NUM_ENEMIES
    bne @loop
    rts
.endproc

;──────────────────────────────────────────────────────────────
; Initialise item
;──────────────────────────────────────────────────────────────

.proc init_item
    lda #180                ; X position
    sta item_x
    lda #100                ; Y position
    sta item_y
    rts
.endproc

;──────────────────────────────────────────────────────────────
; Update item sprite
;──────────────────────────────────────────────────────────────

.proc update_item_sprite
    ; Sprite 5 is at OAM offset 20 ($0214)
    lda item_y
    sta $0200 + 20          ; Y position
    lda #3                  ; Tile 3 (item graphic)
    sta $0200 + 21          ; Tile
    lda #%00000010          ; Palette 2 (magentas)
    sta $0200 + 22          ; Attributes
    lda item_x
    sta $0200 + 23          ; X position
    rts
.endproc

;──────────────────────────────────────────────────────────────
; Check item collision
;──────────────────────────────────────────────────────────────

.proc check_item_collision
    ; Check: player_x < item_x + 8
    lda item_x
    clc
    adc #8                  ; item right edge
    cmp player_x            ; carry set if item_x+8 >= player_x
    bcc @no_hit             ; if item_x+8 < player_x, no hit

    ; Check: item_x < player_x + 8
    lda player_x
    clc
    adc #8                  ; player right edge
    cmp item_x              ; carry set if player_x+8 >= item_x
    bcc @no_hit             ; if player_x+8 < item_x, no hit

    ; Check: player_y < item_y + 8
    lda item_y
    clc
    adc #8                  ; item bottom edge
    cmp player_y            ; carry set if item_y+8 >= player_y
    bcc @no_hit             ; if item_y+8 < player_y, no hit

    ; Check: item_y < player_y + 8
    lda player_y
    clc
    adc #8                  ; player bottom edge
    cmp item_y              ; carry set if player_y+8 >= item_y
    bcc @no_hit             ; if player_y+8 < item_y, no hit

    ; All checks passed - collision!
    jsr collect_item

@no_hit:
    rts
.endproc

;──────────────────────────────────────────────────────────────
; Collect item
;──────────────────────────────────────────────────────────────

.proc collect_item
    ; Increase score
    inc score

    ; Respawn item at new position
    ; X position: score × 16 + 32
    lda score
    asl a                   ; score × 2
    asl a                   ; score × 4
    asl a                   ; score × 8
    asl a                   ; score × 16
    clc
    adc #32                 ; offset from left edge
    cmp #224                ; wrap if too far right
    bcc @x_ok
    lda #48                 ; reset to left side
@x_ok:
    sta item_x

    ; Y position: alternate high and low
    lda score
    and #%00000001          ; check if odd or even
    beq @high
    lda #160                ; odd: low on screen
    jmp @set_y
@high:
    lda #60                 ; even: high on screen
@set_y:
    sta item_y

    rts
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
    .byte $0f, $2a, $1a, $0a    ; Palette 1: Greens (enemies)
    .byte $0f, $25, $15, $05    ; Palette 2: Magentas (items)
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

    ; Tile 1: Player ship (pointing up)
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

    ; Tile 2: Enemy ship (pointing down)
    .byte %01100110         ; .XX..XX.
    .byte %11111111         ; XXXXXXXX
    .byte %11011011         ; XX.XX.XX
    .byte %01111110         ; .XXXXXX.
    .byte %00111100         ; ..XXXX..
    .byte %00111100         ; ..XXXX..
    .byte %00011000         ; ...XX...
    .byte %00011000         ; ...XX...
    ; Plane 1 (all zeros = colour 1 only)
    .byte $00, $00, $00, $00, $00, $00, $00, $00

    ; Tile 3: Collectible item (diamond)
    .byte %00011000         ; ...XX...
    .byte %00111100         ; ..XXXX..
    .byte %01111110         ; .XXXXXX.
    .byte %11111111         ; XXXXXXXX
    .byte %11111111         ; XXXXXXXX
    .byte %01111110         ; .XXXXXX.
    .byte %00111100         ; ..XXXX..
    .byte %00011000         ; ...XX...
    ; Plane 1 (all zeros = colour 1 only)
    .byte $00, $00, $00, $00, $00, $00, $00, $00

    ; Fill rest of 8KB CHR ROM
    .res 8192 - 64
