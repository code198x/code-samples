; underground-assault-04.s
; Lesson 4: Collision Detection
; Add enemies and implement sprite-based collision detection

; NES hardware constants
PPU_CTRL        = $2000
PPU_MASK        = $2001
PPU_STATUS      = $2002
OAM_ADDR        = $2003
OAM_DATA        = $2004
PPU_SCROLL      = $2005
PPU_ADDR        = $2006
PPU_DATA        = $2007

OAM_DMA         = $4014
APU_FRAME       = $4017

CONTROLLER1     = $4016
CONTROLLER2     = $4017

; Controller buttons
BUTTON_A        = $80
BUTTON_B        = $40
BUTTON_SELECT   = $20
BUTTON_START    = $10
BUTTON_UP       = $08
BUTTON_DOWN     = $04
BUTTON_LEFT     = $02
BUTTON_RIGHT    = $01

; iNES header
.segment "HEADER"
    .byte "NES", $1A    ; Magic signature
    .byte 2             ; 2 * 16KB PRG ROM
    .byte 1             ; 1 * 8KB CHR ROM
    .byte $01           ; Mapper 0, vertical mirroring
    .byte $00           ; No extra features
    .byte 0,0,0,0,0,0,0 ; Padding

; ------------------------------------------------------------------------------
; Constants
; ------------------------------------------------------------------------------
; Sprite constants
SHIP_SPRITE     = $00
BULLET_SPRITE   = $01
ENEMY_SPRITE    = $02
EXPLOSION_1     = $03
EXPLOSION_2     = $04

; Game constants  
MAX_BULLETS     = 4
MAX_ENEMIES     = 6
SHIP_X          = 32
BULLET_SPEED    = 3
ENEMY_SPEED     = 1
FIRE_COOLDOWN   = 8
EXPLOSION_TIME  = 12

; Collision box sizes (in pixels)
COLLISION_WIDTH = 6
COLLISION_HEIGHT = 6

; ------------------------------------------------------------------------------
; Zero Page Variables
; ------------------------------------------------------------------------------
.segment "ZEROPAGE"

; System variables
frame_counter:      .res 1
controller1:        .res 1
controller1_old:    .res 1
controller1_press:  .res 1

; Player variables
ship_y:             .res 1
ship_y_old:         .res 1
fire_cooldown:      .res 1

; Star animation
star_timer:         .res 1

; Temp collision variables
obj1_x:             .res 1
obj1_y:             .res 1
obj2_x:             .res 1
obj2_y:             .res 1
temp_x:             .res 1
temp_y:             .res 1

; ------------------------------------------------------------------------------
; BSS Segment (RAM)
; ------------------------------------------------------------------------------
.segment "BSS"

; Bullet system variables
bullet_active:      .res MAX_BULLETS
bullet_x:           .res MAX_BULLETS
bullet_y:           .res MAX_BULLETS

; Enemy system variables
enemy_active:       .res MAX_ENEMIES
enemy_x:            .res MAX_ENEMIES
enemy_y:            .res MAX_ENEMIES
enemy_timer:        .res MAX_ENEMIES

; Explosion system
explosion_active:   .res MAX_ENEMIES
explosion_x:        .res MAX_ENEMIES
explosion_y:        .res MAX_ENEMIES
explosion_timer:    .res MAX_ENEMIES

; ------------------------------------------------------------------------------
; Main Code
; ------------------------------------------------------------------------------
.segment "CODE"

; Reset handler
reset:
    sei                     ; Disable interrupts
    cld                     ; Clear decimal mode
    
    ; Initialize stack
    ldx #$ff
    txs
    
    ; Turn off rendering
    lda #0
    sta PPU_CTRL
    sta PPU_MASK
    
    ; Wait for PPU to stabilize
    jsr wait_vblank
    jsr wait_vblank
    
    ; Clear memory
    jsr clear_memory
    
    ; Initialize PPU
    jsr init_ppu
    
    ; Initialize APU
    jsr init_apu
    
    ; Load palettes
    jsr load_palettes
    
    ; Load pattern table
    jsr load_pattern_table
    
    ; Load initial nametable
    jsr load_nametable
    
    ; Initialize game state
    jsr init_game
    
    ; Enable rendering
    lda #%10010000          ; Enable NMI, sprites from pattern 0
    sta PPU_CTRL
    lda #%00011110          ; Enable sprites and background
    sta PPU_MASK
    
    ; Main game loop
main_loop:
    jsr wait_nmi            ; Wait for vblank
    jsr read_controller
    jsr update_game
    jmp main_loop

; ------------------------------------------------------------------------------
; NMI Handler
; ------------------------------------------------------------------------------
nmi:
    ; Save registers
    pha
    txa
    pha
    tya
    pha
    
    ; Update sprites via DMA
    lda #$00
    sta OAM_ADDR
    lda #$02
    sta OAM_DMA
    
    ; Reset scroll
    bit PPU_STATUS
    lda #0
    sta PPU_SCROLL
    sta PPU_SCROLL
    
    ; Restore registers
    pla
    tay
    pla
    tax
    pla
    rti

; ------------------------------------------------------------------------------
; Initialize Game
; ------------------------------------------------------------------------------
init_game:
    ; Initialize player
    lda #120                ; Middle of screen
    sta ship_y
    sta ship_y_old
    
    lda #0
    sta fire_cooldown
    sta star_timer
    sta frame_counter
    
    ; Initialize bullets
    ldx #0
@init_bullet_loop:
    lda #0
    sta bullet_active,x
    sta bullet_x,x
    sta bullet_y,x
    inx
    cpx #MAX_BULLETS
    bne @init_bullet_loop
    
    ; Initialize enemies
    ldx #0
@init_enemy_loop:
    lda #1                  ; Active
    sta enemy_active,x
    
    ; Starting X position (staggered)
    txa
    asl                     ; * 2
    asl                     ; * 4
    asl                     ; * 8
    asl                     ; * 16
    clc
    adc #200                ; Start from right side
    sta enemy_x,x
    
    ; Starting Y position (spread out)
    txa
    asl                     ; * 2
    asl                     ; * 4
    asl                     ; * 8
    asl                     ; * 16
    clc
    adc #48                 ; Offset from top
    sta enemy_y,x
    
    ; Random movement timer
    txa
    asl
    sta enemy_timer,x
    
    inx
    cpx #MAX_ENEMIES
    bne @init_enemy_loop
    
    ; Initialize explosions
    ldx #0
@init_explosion_loop:
    lda #0
    sta explosion_active,x
    sta explosion_x,x
    sta explosion_y,x
    sta explosion_timer,x
    inx
    cpx #MAX_ENEMIES
    bne @init_explosion_loop
    
    rts

; ------------------------------------------------------------------------------
; Update Game
; ------------------------------------------------------------------------------
update_game:
    inc frame_counter
    
    ; Update subsystems
    jsr update_starfield
    jsr update_ship
    jsr update_bullets
    jsr update_enemies
    jsr check_collisions
    jsr update_explosions
    jsr update_sprites
    
    ; Update fire cooldown
    lda fire_cooldown
    beq @done
    dec fire_cooldown
@done:
    rts

; ------------------------------------------------------------------------------
; Update Starfield Animation
; ------------------------------------------------------------------------------
update_starfield:
    inc star_timer
    lda star_timer
    cmp #8
    bcc @done
    
    lda #0
    sta star_timer
    
    ; Simple star animation in nametable
    ; This would normally update background tiles
@done:
    rts

; ------------------------------------------------------------------------------
; Update Ship
; ------------------------------------------------------------------------------
update_ship:
    ; Store old position
    lda ship_y
    sta ship_y_old
    
    ; Check up
    lda controller1_press
    and #BUTTON_UP
    beq @check_down
    
    lda ship_y
    cmp #32                 ; Top boundary
    bcc @check_down
    sec
    sbc #2
    sta ship_y
    
@check_down:
    lda controller1_press
    and #BUTTON_DOWN
    beq @check_fire
    
    lda ship_y
    cmp #200                ; Bottom boundary
    bcs @check_fire
    clc
    adc #2
    sta ship_y
    
@check_fire:
    lda controller1_press
    and #BUTTON_A
    beq @done
    
    lda fire_cooldown
    bne @done
    
    jsr fire_bullet
    
@done:
    rts

; ------------------------------------------------------------------------------
; Fire Bullet
; ------------------------------------------------------------------------------
fire_bullet:
    ; Find inactive bullet
    ldx #0
@find_loop:
    lda bullet_active,x
    beq @found
    inx
    cpx #MAX_BULLETS
    bne @find_loop
    rts                     ; No free bullets
    
@found:
    ; Activate bullet
    lda #1
    sta bullet_active,x
    
    ; Set position
    lda #SHIP_X
    clc
    adc #8                  ; In front of ship
    sta bullet_x,x
    
    lda ship_y
    sta bullet_y,x
    
    ; Set cooldown
    lda #FIRE_COOLDOWN
    sta fire_cooldown
    
    rts

; ------------------------------------------------------------------------------
; Update Bullets
; ------------------------------------------------------------------------------
update_bullets:
    ldx #0
@loop:
    lda bullet_active,x
    beq @next
    
    ; Move bullet right
    lda bullet_x,x
    clc
    adc #BULLET_SPEED
    sta bullet_x,x
    
    ; Check if off screen
    cmp #240
    bcc @next
    
    ; Deactivate
    lda #0
    sta bullet_active,x
    
@next:
    inx
    cpx #MAX_BULLETS
    bne @loop
    rts

; ------------------------------------------------------------------------------
; Update Enemies
; ------------------------------------------------------------------------------
update_enemies:
    ldx #0
@loop:
    lda enemy_active,x
    beq @next
    
    ; Move enemy left
    lda enemy_x,x
    sec
    sbc #ENEMY_SPEED
    sta enemy_x,x
    
    ; Check if off screen
    cmp #8
    bcs @check_movement
    
    ; Respawn on right
    lda #240
    sta enemy_x,x
    
    ; Random Y position
    lda frame_counter
    and #$3F                ; 0-63
    clc
    adc #48                 ; 48-111
    sta enemy_y,x
    
@check_movement:
    ; Simple vertical movement
    dec enemy_timer,x
    bne @next
    
    ; Reset timer
    lda #32
    sta enemy_timer,x
    
    ; Move up or down
    lda frame_counter
    and #1
    beq @move_up
    
    ; Move down
    lda enemy_y,x
    clc
    adc #16
    cmp #180
    bcs @next
    sta enemy_y,x
    jmp @next
    
@move_up:
    lda enemy_y,x
    sec
    sbc #16
    cmp #32
    bcc @next
    sta enemy_y,x
    
@next:
    inx
    cpx #MAX_ENEMIES
    bne @loop
    rts

; ------------------------------------------------------------------------------
; Check Collisions
; ------------------------------------------------------------------------------
check_collisions:
    ; Check each bullet against each enemy
    ldx #0
@bullet_loop:
    lda bullet_active,x
    beq @next_bullet
    
    ; Store bullet position
    lda bullet_x,x
    sta obj1_x
    lda bullet_y,x
    sta obj1_y
    
    ; Check against enemies
    ldy #0
@enemy_loop:
    lda enemy_active,y
    beq @next_enemy
    
    ; Store enemy position
    lda enemy_x,y
    sta obj2_x
    lda enemy_y,y
    sta obj2_y
    
    ; Check collision
    jsr check_object_collision
    bcc @next_enemy         ; No collision
    
    ; Collision detected!
    ; Deactivate bullet
    lda #0
    sta bullet_active,x
    
    ; Deactivate enemy
    lda #0
    sta enemy_active,y
    
    ; Start explosion
    lda enemy_x,y
    sta explosion_x,y
    lda enemy_y,y
    sta explosion_y,y
    lda #EXPLOSION_TIME
    sta explosion_timer,y
    lda #1
    sta explosion_active,y
    
    ; Could add score here
    
    jmp @next_bullet        ; This bullet is done
    
@next_enemy:
    iny
    cpy #MAX_ENEMIES
    bne @enemy_loop
    
@next_bullet:
    inx
    cpx #MAX_BULLETS
    bne @bullet_loop
    rts

; ------------------------------------------------------------------------------
; Check Object Collision
; Input: obj1_x/y, obj2_x/y
; Output: Carry set if collision
; ------------------------------------------------------------------------------
check_object_collision:
    ; Check X overlap
    lda obj1_x
    sec
    sbc obj2_x
    bcs @positive_x         ; obj1 >= obj2
    
    ; obj1 < obj2, check if obj2 is within range
    eor #$FF
    clc
    adc #1                  ; Make positive
    cmp #COLLISION_WIDTH
    bcs @no_collision
    jmp @check_y
    
@positive_x:
    ; obj1 >= obj2, check if obj1 is within range
    cmp #COLLISION_WIDTH
    bcs @no_collision
    
@check_y:
    ; Check Y overlap
    lda obj1_y
    sec
    sbc obj2_y
    bcs @positive_y         ; obj1 >= obj2
    
    ; obj1 < obj2
    eor #$FF
    clc
    adc #1                  ; Make positive
    cmp #COLLISION_HEIGHT
    bcs @no_collision
    
    ; Collision!
    sec
    rts
    
@positive_y:
    ; obj1 >= obj2
    cmp #COLLISION_HEIGHT
    bcs @no_collision
    
    ; Collision!
    sec
    rts
    
@no_collision:
    clc
    rts

; ------------------------------------------------------------------------------
; Update Explosions
; ------------------------------------------------------------------------------
update_explosions:
    ldx #0
@loop:
    lda explosion_active,x
    beq @next
    
    ; Decrement timer
    dec explosion_timer,x
    bne @next
    
    ; Explosion finished
    lda #0
    sta explosion_active,x
    
@next:
    inx
    cpx #MAX_ENEMIES
    bne @loop
    rts

; ------------------------------------------------------------------------------
; Update Sprites
; ------------------------------------------------------------------------------
update_sprites:
    ; Clear OAM
    ldx #0
    lda #$FF
@clear_loop:
    sta $0200,x
    inx
    bne @clear_loop
    
    ; Sprite index
    ldx #0
    
    ; Draw ship
    lda ship_y
    sta $0200,x             ; Y position
    lda #SHIP_SPRITE
    sta $0201,x             ; Tile
    lda #0
    sta $0202,x             ; Attributes
    lda #SHIP_X
    sta $0203,x             ; X position
    
    ; Next sprite
    txa
    clc
    adc #4
    tax
    
    ; Draw bullets
    ldy #0
@bullet_loop:
    lda bullet_active,y
    beq @next_bullet
    
    lda bullet_y,y
    sta $0200,x             ; Y position
    lda #BULLET_SPRITE
    sta $0201,x             ; Tile
    lda #1                  ; Different palette
    sta $0202,x             ; Attributes
    lda bullet_x,y
    sta $0203,x             ; X position
    
    ; Next sprite
    txa
    clc
    adc #4
    tax
    
@next_bullet:
    iny
    cpy #MAX_BULLETS
    bne @bullet_loop
    
    ; Draw enemies
    ldy #0
@enemy_loop:
    lda enemy_active,y
    beq @check_explosion
    
    lda enemy_y,y
    sta $0200,x             ; Y position
    lda #ENEMY_SPRITE
    sta $0201,x             ; Tile
    lda #2                  ; Enemy palette
    sta $0202,x             ; Attributes
    lda enemy_x,y
    sta $0203,x             ; X position
    
    ; Next sprite
    txa
    clc
    adc #4
    tax
    jmp @next_enemy
    
@check_explosion:
    ; Check if explosion active
    lda explosion_active,y
    beq @next_enemy
    
    ; Draw explosion
    lda explosion_y,y
    sta $0200,x             ; Y position
    
    ; Alternate explosion frames
    lda explosion_timer,y
    and #4
    beq @explosion_frame2
    
    lda #EXPLOSION_1
    jmp @draw_explosion
    
@explosion_frame2:
    lda #EXPLOSION_2
    
@draw_explosion:
    sta $0201,x             ; Tile
    lda #3                  ; Explosion palette
    sta $0202,x             ; Attributes
    lda explosion_x,y
    sta $0203,x             ; X position
    
    ; Next sprite
    txa
    clc
    adc #4
    tax
    
@next_enemy:
    iny
    cpy #MAX_ENEMIES
    bne @enemy_loop
    
    rts

; ------------------------------------------------------------------------------
; Utility Functions
; ------------------------------------------------------------------------------

wait_vblank:
    bit PPU_STATUS
@wait:
    bit PPU_STATUS
    bpl @wait
    rts

wait_nmi:
    lda frame_counter
@wait:
    cmp frame_counter
    beq @wait
    rts

clear_memory:
    lda #0
    tax
@loop:
    sta $0000,x
    sta $0100,x
    sta $0200,x
    sta $0300,x
    sta $0400,x
    sta $0500,x
    sta $0600,x
    sta $0700,x
    inx
    bne @loop
    rts

init_ppu:
    ; Clear nametables
    lda PPU_STATUS
    lda #$20
    sta PPU_ADDR
    lda #$00
    sta PPU_ADDR
    
    lda #0
    ldy #8                  ; 8 * 256 = 2048 bytes
    ldx #0
@loop:
    sta PPU_DATA
    inx
    bne @loop
    dey
    bne @loop
    rts

init_apu:
    lda #$0F
    sta $4015               ; Enable channels
    lda #$40
    sta $4017               ; Frame counter mode
    rts

read_controller:
    ; Save old state
    lda controller1
    sta controller1_old
    
    ; Read controller
    lda #1
    sta CONTROLLER1
    lda #0
    sta CONTROLLER1
    
    ldx #8
@loop:
    lda CONTROLLER1
    lsr a
    rol controller1
    dex
    bne @loop
    
    ; Calculate newly pressed buttons
    lda controller1_old
    eor #$FF
    and controller1
    sta controller1_press
    
    rts

load_palettes:
    ; Set PPU address to palette
    bit PPU_STATUS
    lda #$3F
    sta PPU_ADDR
    lda #$00
    sta PPU_ADDR
    
    ; Load palettes
    ldx #0
@loop:
    lda palette_data,x
    sta PPU_DATA
    inx
    cpx #32
    bne @loop
    rts

load_pattern_table:
    ; This would load CHR data
    ; For now, assume CHR-ROM
    rts

load_nametable:
    ; Set PPU address
    bit PPU_STATUS
    lda #$20
    sta PPU_ADDR
    lda #$00
    sta PPU_ADDR
    
    ; Simple starfield background
    ldx #30                 ; 30 rows
@row_loop:
    ldy #32                 ; 32 columns
@col_loop:
    lda #0                  ; Empty space
    
    ; Random stars
    cpx #25
    bcs @write
    cpy #30
    bcs @write
    
    txa
    eor frame_counter
    and #7
    bne @write
    
    lda #'.'                ; Star character
    
@write:
    sta PPU_DATA
    dey
    bne @col_loop
    dex
    bne @row_loop
    
    rts

; ------------------------------------------------------------------------------
; Data
; ------------------------------------------------------------------------------
palette_data:
    ; Background palettes
    .byte $0F,$01,$11,$30   ; Black, dark blue, blue, white
    .byte $0F,$05,$15,$35   ; Black, dark red, red, pink
    .byte $0F,$09,$19,$39   ; Black, dark green, green, light green
    .byte $0F,$0C,$1C,$3C   ; Black, dark gray, gray, light gray
    
    ; Sprite palettes
    .byte $0F,$02,$12,$30   ; Ship: blue/cyan/white
    .byte $0F,$07,$17,$30   ; Bullets: brown/orange/white
    .byte $0F,$06,$16,$30   ; Enemies: dark red/red/white
    .byte $0F,$08,$28,$38   ; Explosions: orange/yellow/pale yellow

; ------------------------------------------------------------------------------
; Interrupt Vectors
; ------------------------------------------------------------------------------
.segment "VECTORS"
    .addr 0         ; Unused
    .addr reset     ; Reset vector
    .addr nmi       ; NMI vector

; ------------------------------------------------------------------------------
; CHR ROM Data
; ------------------------------------------------------------------------------
.segment "CHARS"
    ; Ship sprite (tile 0)
    .byte $00,$00,$08,$18,$3C,$7E,$18,$00
    .byte $00,$00,$08,$18,$3C,$7E,$18,$00
    
    ; Bullet sprite (tile 1)
    .byte $00,$00,$18,$3C,$3C,$18,$00,$00
    .byte $00,$00,$18,$3C,$3C,$18,$00,$00
    
    ; Enemy sprite (tile 2)
    .byte $00,$18,$3C,$7E,$7E,$3C,$18,$00
    .byte $00,$18,$24,$42,$42,$24,$18,$00
    
    ; Explosion frame 1 (tile 3)
    .byte $00,$24,$18,$7E,$7E,$18,$24,$00
    .byte $00,$24,$18,$42,$42,$18,$24,$00
    
    ; Explosion frame 2 (tile 4)
    .byte $42,$24,$99,$7E,$7E,$99,$24,$42
    .byte $42,$24,$99,$42,$42,$99,$24,$42
    
    ; Fill rest of CHR ROM (8KB - 80 bytes used)
    .res 8192-80, $00