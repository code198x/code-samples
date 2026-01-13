; =============================================================================
; NEON NEXUS - Unit 2: Moving the Player
; =============================================================================
; The player sprite now moves with the D-pad.
; Press Up, Down, Left, Right to move around the screen.
; =============================================================================

; -----------------------------------------------------------------------------
; NES Hardware Addresses
; -----------------------------------------------------------------------------
PPUCTRL   = $2000
PPUMASK   = $2001
PPUSTATUS = $2002
OAMADDR   = $2003
PPUADDR   = $2006
PPUDATA   = $2007
OAMDMA    = $4014

JOYPAD1   = $4016     ; Controller 1
JOYPAD2   = $4017     ; Controller 2

; Controller button masks
BTN_A      = %10000000
BTN_B      = %01000000
BTN_SELECT = %00100000
BTN_START  = %00010000
BTN_UP     = %00001000
BTN_DOWN   = %00000100
BTN_LEFT   = %00000010
BTN_RIGHT  = %00000001

; -----------------------------------------------------------------------------
; Game Constants
; -----------------------------------------------------------------------------
PLAYER_START_X = 124
PLAYER_START_Y = 116
PLAYER_TILE    = 1
BG_COLOUR      = $12

PLAYER_SPEED   = 2    ; Pixels per frame (try 1, 2, or 3)

; Screen boundaries
SCREEN_LEFT   = 0
SCREEN_RIGHT  = 248   ; 256 - 8 (sprite width)
SCREEN_TOP    = 0
SCREEN_BOTTOM = 224   ; 240 - 16 (sprite height + overscan)

; -----------------------------------------------------------------------------
; Memory Layout
; -----------------------------------------------------------------------------
.segment "ZEROPAGE"
player_x:    .res 1
player_y:    .res 1
buttons:     .res 1   ; Current button state

.segment "OAM"
oam_buffer:  .res 256

.segment "BSS"

; -----------------------------------------------------------------------------
; iNES Header
; -----------------------------------------------------------------------------
.segment "HEADER"
    .byte "NES", $1A
    .byte 2           ; 32KB PRG-ROM
    .byte 1           ; 8KB CHR-ROM
    .byte $01         ; Mapper 0, vertical mirroring
    .byte $00
    .byte 0,0,0,0,0,0,0,0

; -----------------------------------------------------------------------------
; Code
; -----------------------------------------------------------------------------
.segment "CODE"

reset:
    sei
    cld
    ldx #$40
    stx $4017
    ldx #$FF
    txs
    inx
    stx PPUCTRL
    stx PPUMASK
    stx $4010

@vblank1:
    bit PPUSTATUS
    bpl @vblank1

    lda #0
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

    ; Load palette
    bit PPUSTATUS
    lda #$3F
    sta PPUADDR
    lda #$00
    sta PPUADDR

    ldx #0
@load_palette:
    lda palette_data, x
    sta PPUDATA
    inx
    cpx #32
    bne @load_palette

    ; Set up player
    lda #PLAYER_START_X
    sta player_x
    lda #PLAYER_START_Y
    sta player_y

    ; Initialise player sprite
    lda player_y
    sta oam_buffer+0
    lda #PLAYER_TILE
    sta oam_buffer+1
    lda #0
    sta oam_buffer+2
    lda player_x
    sta oam_buffer+3

    ; Hide other sprites
    lda #$FF
    ldx #4
@hide_sprites:
    sta oam_buffer, x
    inx
    bne @hide_sprites

    ; Enable rendering
    lda #%10010000
    sta PPUCTRL
    lda #%00011110
    sta PPUMASK

; === Main Loop ===
main_loop:
    ; Read controller
    jsr read_controller

    ; Move player based on input
    jsr move_player

    jmp main_loop

; -----------------------------------------------------------------------------
; Read Controller
; -----------------------------------------------------------------------------
read_controller:
    ; Strobe the controller
    lda #1
    sta JOYPAD1
    lda #0
    sta JOYPAD1

    ; Read 8 buttons into 'buttons' variable
    ldx #8
@read_loop:
    lda JOYPAD1
    lsr a           ; Bit 0 -> Carry
    rol buttons     ; Carry -> buttons
    dex
    bne @read_loop

    rts

; -----------------------------------------------------------------------------
; Move Player
; -----------------------------------------------------------------------------
move_player:
    ; Check UP
    lda buttons
    and #BTN_UP
    beq @check_down

    lda player_y
    sec
    sbc #PLAYER_SPEED
    cmp #SCREEN_TOP
    bcc @check_down      ; Don't go above top
    sta player_y

@check_down:
    lda buttons
    and #BTN_DOWN
    beq @check_left

    lda player_y
    clc
    adc #PLAYER_SPEED
    cmp #SCREEN_BOTTOM
    bcs @check_left      ; Don't go below bottom
    sta player_y

@check_left:
    lda buttons
    and #BTN_LEFT
    beq @check_right

    lda player_x
    sec
    sbc #PLAYER_SPEED
    cmp #SCREEN_LEFT
    bcc @check_right     ; Don't go past left edge
    sta player_x

@check_right:
    lda buttons
    and #BTN_RIGHT
    beq @done

    lda player_x
    clc
    adc #PLAYER_SPEED
    cmp #SCREEN_RIGHT
    bcs @done            ; Don't go past right edge
    sta player_x

@done:
    rts

; === NMI ===
nmi:
    pha
    txa
    pha
    tya
    pha

    ; DMA sprites
    lda #0
    sta OAMADDR
    lda #>oam_buffer
    sta OAMDMA

    ; Update sprite from player position
    lda player_y
    sta oam_buffer+0
    lda player_x
    sta oam_buffer+3

    pla
    tay
    pla
    tax
    pla
    rti

irq:
    rti

; -----------------------------------------------------------------------------
; Data
; -----------------------------------------------------------------------------
palette_data:
    .byte BG_COLOUR, $00, $10, $20
    .byte BG_COLOUR, $00, $10, $20
    .byte BG_COLOUR, $00, $10, $20
    .byte BG_COLOUR, $00, $10, $20
    .byte BG_COLOUR, $30, $20, $0F
    .byte BG_COLOUR, $30, $16, $0F
    .byte BG_COLOUR, $30, $12, $0F
    .byte BG_COLOUR, $30, $14, $0F

; -----------------------------------------------------------------------------
; Vectors
; -----------------------------------------------------------------------------
.segment "VECTORS"
    .word nmi
    .word reset
    .word irq

; -----------------------------------------------------------------------------
; CHR-ROM
; -----------------------------------------------------------------------------
.segment "CHARS"

; Tile 0: Empty
.byte $00,$00,$00,$00,$00,$00,$00,$00
.byte $00,$00,$00,$00,$00,$00,$00,$00

; Tile 1: Player sprite
.byte %00011000
.byte %00111100
.byte %01111110
.byte %11111111
.byte %00111100
.byte %00111100
.byte %00111100
.byte %00111100
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000

.res 8192 - 32, $00
