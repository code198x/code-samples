; =============================================================================
; DASH - Unit 4: Obstacle
; =============================================================================
; A diamond-shaped obstacle scrolls across the floor. Jump over it or get
; knocked back to the start. The first challenge in Dash.
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
JOYPAD1   = $4016

; -----------------------------------------------------------------------------
; Button Masks
; -----------------------------------------------------------------------------
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
PLAYER_X       = 60            ; Starting X position (left side)
PLAYER_Y       = 206           ; Starting Y position (on the floor)
PLAYER_TILE    = 1             ; Tile number for the player sprite
RIGHT_WALL     = 248           ; Rightmost X position
FLOOR_Y        = 206           ; Y position of the floor
GRAVITY        = 1             ; Added to vel_y each frame
JUMP_VEL       = $F6           ; -10 in two's complement (upward impulse)
OBSTACLE_TILE  = 2             ; Tile number for the obstacle
OBSTACLE_SPEED = 2             ; Pixels per frame (moving left)

; -----------------------------------------------------------------------------
; Memory
; -----------------------------------------------------------------------------
.segment "ZEROPAGE"
player_x:   .res 1          ; Player X position
player_y:   .res 1          ; Player Y position
vel_y:      .res 1          ; Vertical velocity (signed: negative = up)
buttons:    .res 1          ; Current button state
nmi_flag:   .res 1          ; Set by NMI, cleared by main loop
on_ground:  .res 1          ; 1 = on floor, 0 = in air
obstacle_x: .res 1          ; Obstacle X position

.segment "OAM"
oam_buffer: .res 256

.segment "BSS"

; =============================================================================
; iNES Header
; =============================================================================
.segment "HEADER"
    .byte "NES", $1A
    .byte 2
    .byte 1
    .byte $01
    .byte $00
    .byte 0,0,0,0,0,0,0,0

; =============================================================================
; Code
; =============================================================================
.segment "CODE"

; --- Reset ---
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

    ; Set up player sprite (OAM entry 0)
    lda #PLAYER_Y
    sta oam_buffer+0
    lda #PLAYER_TILE
    sta oam_buffer+1
    lda #0
    sta oam_buffer+2
    lda #PLAYER_X
    sta oam_buffer+3

    ; Set up obstacle sprite (OAM entry 1)
    lda #FLOOR_Y
    sta oam_buffer+4
    lda #OBSTACLE_TILE
    sta oam_buffer+5
    lda #1                  ; Palette 1 (red)
    sta oam_buffer+6
    lda #255
    sta oam_buffer+7

    ; Initialise game state
    lda #PLAYER_X
    sta player_x
    lda #PLAYER_Y
    sta player_y
    lda #0
    sta vel_y
    lda #1
    sta on_ground
    lda #255
    sta obstacle_x          ; Start at right edge

    ; Hide other sprites (entries 2-63)
    lda #$EF
    ldx #8
@hide_sprites:
    sta oam_buffer, x
    inx
    bne @hide_sprites

    ; Enable rendering
    lda #%10000000
    sta PPUCTRL
    lda #%00011110
    sta PPUMASK

; =============================================================================
; Main Loop
; =============================================================================
main_loop:
    lda nmi_flag
    beq main_loop
    lda #0
    sta nmi_flag

    ; --- Read controller ---
    lda #1
    sta JOYPAD1
    lda #0
    sta JOYPAD1

    ldx #8
@read_pad:
    lda JOYPAD1
    lsr a
    rol buttons
    dex
    bne @read_pad

    ; --- Jump check ---
    lda buttons
    and #BTN_A
    beq @no_jump
    lda on_ground
    beq @no_jump
    lda #JUMP_VEL
    sta vel_y
    lda #0
    sta on_ground
@no_jump:

    ; --- Move left/right ---
    lda buttons
    and #BTN_LEFT
    beq @not_left
    lda player_x
    beq @not_left
    dec player_x
@not_left:

    lda buttons
    and #BTN_RIGHT
    beq @not_right
    lda player_x
    cmp #RIGHT_WALL
    bcs @not_right
    inc player_x
@not_right:

    ; --- Apply gravity ---
    lda vel_y
    clc
    adc #GRAVITY
    sta vel_y

    ; --- Apply velocity to Y position ---
    lda player_y
    clc
    adc vel_y
    sta player_y

    ; --- Floor collision ---
    lda player_y
    cmp #FLOOR_Y
    bcc @in_air
    lda #FLOOR_Y
    sta player_y
    lda #0
    sta vel_y
    lda #1
    sta on_ground
@in_air:

    ; --- Move obstacle ---
    lda obstacle_x
    sec
    sbc #OBSTACLE_SPEED
    sta obstacle_x

    ; --- Collision with obstacle ---
    lda on_ground
    beq @no_collide         ; In the air — jumped over it!

    lda obstacle_x
    cmp #240
    bcs @no_collide         ; Obstacle near screen edge — skip

    ; Check X overlap between player and obstacle
    ; Both sprites are 8 pixels wide
    lda player_x
    clc
    adc #8                  ; Player right edge
    cmp obstacle_x          ; Past obstacle left edge?
    bcc @no_collide
    beq @no_collide

    lda obstacle_x
    clc
    adc #8                  ; Obstacle right edge
    cmp player_x            ; Past player left edge?
    bcc @no_collide
    beq @no_collide

    ; Hit! Reset player to starting position
    lda #PLAYER_X
    sta player_x

@no_collide:

    ; --- Update sprite positions ---
    lda player_y
    sta oam_buffer+0
    lda player_x
    sta oam_buffer+3

    lda #FLOOR_Y
    sta oam_buffer+4        ; Obstacle always on the floor
    lda obstacle_x
    sta oam_buffer+7

    jmp main_loop

; =============================================================================
; NMI Handler
; =============================================================================
nmi:
    pha
    txa
    pha
    tya
    pha

    lda #0
    sta OAMADDR
    lda #>oam_buffer
    sta OAMDMA

    lda #1
    sta nmi_flag

    pla
    tay
    pla
    tax
    pla
    rti

irq:
    rti

; =============================================================================
; Data
; =============================================================================

palette_data:
    ; Background palettes
    .byte $0F, $00, $10, $20
    .byte $0F, $00, $10, $20
    .byte $0F, $00, $10, $20
    .byte $0F, $00, $10, $20
    ; Sprite palettes
    .byte $0F, $30, $16, $27   ; Palette 0: white, red, orange (player)
    .byte $0F, $16, $27, $30   ; Palette 1: red, orange, white (obstacle)
    .byte $0F, $30, $16, $27
    .byte $0F, $30, $16, $27

; =============================================================================
; Vectors
; =============================================================================
.segment "VECTORS"
    .word nmi
    .word reset
    .word irq

; =============================================================================
; CHR-ROM
; =============================================================================
.segment "CHARS"

; Tile 0: Empty
.byte $00,$00,$00,$00,$00,$00,$00,$00
.byte $00,$00,$00,$00,$00,$00,$00,$00

; Tile 1: Running figure
.byte %00110000
.byte %00110000
.byte %01111000
.byte %00110000
.byte %00110000
.byte %00101000
.byte %01000100
.byte %01000100
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000

; Tile 2: Diamond obstacle
.byte %00011000
.byte %00111100
.byte %01111110
.byte %11111111
.byte %11111111
.byte %01111110
.byte %00111100
.byte %00011000
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000

.res 8192 - 48, $00
