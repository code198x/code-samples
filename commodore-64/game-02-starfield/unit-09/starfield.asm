;═══════════════════════════════════════════════════════════════════════════════
; STARFIELD - Unit 9: Bullet Pooling
; A space shooter for the Commodore 64
;
; This unit adds support for multiple bullets using a bullet pool.
; Player can now have up to 4 bullets on screen simultaneously.
;
; Build: acme -f cbm -o starfield.prg starfield.asm
; Run:   x64sc starfield.prg
;═══════════════════════════════════════════════════════════════════════════════

;───────────────────────────────────────────────────────────────────────────────
; BASIC stub: 10 SYS 2064
;───────────────────────────────────────────────────────────────────────────────
            * = $0801

            !byte $0c, $08
            !byte $0a, $00
            !byte $9e
            !byte $32, $30, $36, $34
            !byte $00
            !byte $00, $00

;───────────────────────────────────────────────────────────────────────────────
; Constants
;───────────────────────────────────────────────────────────────────────────────
SCREEN      = $0400
COLOUR      = $d800

BORDER      = $d020
BACKGROUND  = $d021

VIC         = $d000
SPRITE0_X   = VIC + 0
SPRITE0_Y   = VIC + 1
SPRITE_MSB  = VIC + 16
SPRITE_EN   = VIC + 21
SPRITE_COL  = VIC + 39          ; Base of sprite colour registers

SPRITE0_PTR = SCREEN + $03F8

CIA1_PRA    = $dc00
JOY_FIRE    = %00010000

; Colours
COL_BLACK   = $00
COL_WHITE   = $01
COL_YELLOW  = $07
COL_DKBLUE  = $06
COL_CYAN    = $03

; Boundaries
MIN_X       = 24
MAX_X       = 224
MIN_Y       = 50
MAX_Y       = 220

; Speeds
PLAYER_SPEED = 2
BULLET_SPEED = 4

BULLET_TOP  = 30

; Bullet pool
MAX_BULLETS = 4

;───────────────────────────────────────────────────────────────────────────────
; Zero Page Variables
;───────────────────────────────────────────────────────────────────────────────
player_x    = $02
player_y    = $03
fire_delay  = $04               ; Delay between shots

;───────────────────────────────────────────────────────────────────────────────
; Entry Point
;───────────────────────────────────────────────────────────────────────────────
            * = $0810

!zone main
main:
            jsr setup_screen
            jsr setup_sprites
            jsr init_bullets
            jmp main_loop

;───────────────────────────────────────────────────────────────────────────────
; Setup Screen
;───────────────────────────────────────────────────────────────────────────────
!zone setup_screen
setup_screen:
            lda #COL_DKBLUE
            sta BORDER
            lda #COL_BLACK
            sta BACKGROUND

            ldx #$00
.clear_loop:
            lda #$20
            sta SCREEN,x
            sta SCREEN + $100,x
            sta SCREEN + $200,x
            sta SCREEN + $2e8,x
            lda #COL_BLACK
            sta COLOUR,x
            sta COLOUR + $100,x
            sta COLOUR + $200,x
            sta COLOUR + $2e8,x
            inx
            bne .clear_loop
            rts

;───────────────────────────────────────────────────────────────────────────────
; Setup Sprites
;───────────────────────────────────────────────────────────────────────────────
!zone setup_sprites
setup_sprites:
            ; Sprite 0 = player ship
            lda #(ship_sprite / 64)
            sta SPRITE0_PTR

            ; Sprites 1-4 = bullets (all same graphic)
            lda #(bullet_sprite / 64)
            sta SPRITE0_PTR + 1
            sta SPRITE0_PTR + 2
            sta SPRITE0_PTR + 3
            sta SPRITE0_PTR + 4

            ; Player position
            lda #172
            sta player_x
            sta SPRITE0_X
            lda #220
            sta player_y
            sta SPRITE0_Y

            lda #$00
            sta SPRITE_MSB

            ; Colours: player = cyan, bullets = yellow
            lda #COL_CYAN
            sta SPRITE_COL
            lda #COL_YELLOW
            sta SPRITE_COL + 1
            sta SPRITE_COL + 2
            sta SPRITE_COL + 3
            sta SPRITE_COL + 4

            ; Enable only player sprite initially
            lda #%00000001
            sta SPRITE_EN

            ; Initialise fire delay
            lda #0
            sta fire_delay
            rts

;───────────────────────────────────────────────────────────────────────────────
; Initialise Bullet Pool
;───────────────────────────────────────────────────────────────────────────────
!zone init_bullets
init_bullets:
            ldx #MAX_BULLETS - 1
.loop:
            lda #0
            sta bullet_active,x
            sta bullet_x,x
            sta bullet_y,x
            dex
            bpl .loop
            rts

;───────────────────────────────────────────────────────────────────────────────
; Main Loop
;───────────────────────────────────────────────────────────────────────────────
!zone main_loop
main_loop:
.wait_raster:
            lda $d012
            cmp #255
            bne .wait_raster

            jsr read_joystick
            jsr check_fire
            jsr update_bullets
            jsr update_sprites
            jmp main_loop

;───────────────────────────────────────────────────────────────────────────────
; Read Joystick
;───────────────────────────────────────────────────────────────────────────────
!zone read_joystick
read_joystick:
            lda CIA1_PRA

            lsr
            bcs .not_up
            lda player_y
            cmp #MIN_Y
            bcc .not_up
            sec
            sbc #PLAYER_SPEED
            sta player_y
.not_up:

            lda CIA1_PRA
            lsr
            lsr
            bcs .not_down
            lda player_y
            cmp #MAX_Y
            bcs .not_down
            clc
            adc #PLAYER_SPEED
            sta player_y
.not_down:

            lda CIA1_PRA
            and #%00000100
            bne .not_left
            lda player_x
            cmp #MIN_X
            bcc .not_left
            sec
            sbc #PLAYER_SPEED
            sta player_x
.not_left:

            lda CIA1_PRA
            and #%00001000
            bne .not_right
            lda player_x
            cmp #MAX_X
            bcs .not_right
            clc
            adc #PLAYER_SPEED
            sta player_x
.not_right:
            rts

;───────────────────────────────────────────────────────────────────────────────
; Check Fire Button
;───────────────────────────────────────────────────────────────────────────────
!zone check_fire
check_fire:
            ; Decrement fire delay
            lda fire_delay
            beq .can_fire
            dec fire_delay
            rts

.can_fire:
            ; Check fire button
            lda CIA1_PRA
            and #JOY_FIRE
            bne .done               ; Not pressed

            jsr spawn_bullet

            ; Set fire delay (rate limiter)
            lda #8
            sta fire_delay
.done:
            rts

;───────────────────────────────────────────────────────────────────────────────
; Spawn Bullet - Find free slot in pool
;───────────────────────────────────────────────────────────────────────────────
!zone spawn_bullet
spawn_bullet:
            ldx #0
.find_slot:
            lda bullet_active,x
            beq .found_slot
            inx
            cpx #MAX_BULLETS
            bne .find_slot
            rts                     ; No free slots

.found_slot:
            ; Mark as active
            lda #1
            sta bullet_active,x

            ; Set position
            lda player_x
            clc
            adc #8
            sta bullet_x,x

            lda player_y
            sec
            sbc #16
            sta bullet_y,x

            ; Enable this bullet's sprite (sprite 1 + x)
            lda SPRITE_EN
            ora sprite_bit,x
            sta SPRITE_EN
            rts

; Bit masks for sprites 1-4
sprite_bit:
            !byte %00000010, %00000100, %00001000, %00010000

;───────────────────────────────────────────────────────────────────────────────
; Update Bullets - Move all active bullets
;───────────────────────────────────────────────────────────────────────────────
!zone update_bullets
update_bullets:
            ldx #0
.loop:
            lda bullet_active,x
            beq .next               ; Skip inactive

            ; Move bullet up
            lda bullet_y,x
            sec
            sbc #BULLET_SPEED
            sta bullet_y,x

            ; Check if off top of screen
            cmp #BULLET_TOP
            bcs .next               ; Still on screen

            ; Deactivate bullet
            lda #0
            sta bullet_active,x

            ; Disable this sprite
            lda sprite_bit,x
            eor #$ff                ; Invert to clear bit
            and SPRITE_EN
            sta SPRITE_EN

.next:
            inx
            cpx #MAX_BULLETS
            bne .loop
            rts

;───────────────────────────────────────────────────────────────────────────────
; Update Sprite Positions
;───────────────────────────────────────────────────────────────────────────────
!zone update_sprites
update_sprites:
            ; Update player
            lda player_x
            sta SPRITE0_X
            lda player_y
            sta SPRITE0_Y

            ; Update bullets (sprites 1-4)
            ldx #0
.loop:
            lda bullet_active,x
            beq .next

            ; Calculate sprite register offset (sprite 1 = offset 2, etc.)
            txa
            asl                     ; x * 2
            clc
            adc #2                  ; + 2 (skip sprite 0)
            tay

            lda bullet_x,x
            sta VIC,y               ; X position
            lda bullet_y,x
            sta VIC + 1,y           ; Y position

.next:
            inx
            cpx #MAX_BULLETS
            bne .loop
            rts

;───────────────────────────────────────────────────────────────────────────────
; Bullet Pool Data
;───────────────────────────────────────────────────────────────────────────────
bullet_active:
            !byte 0, 0, 0, 0
bullet_x:
            !byte 0, 0, 0, 0
bullet_y:
            !byte 0, 0, 0, 0

;───────────────────────────────────────────────────────────────────────────────
; Ship Sprite Data (Block 40 = $0A00 / 64)
;───────────────────────────────────────────────────────────────────────────────
            * = $0a00

ship_sprite:
            !byte %00000000, %00000000, %00000000
            !byte %00000000, %00000000, %00000000
            !byte %00000000, %00011000, %00000000
            !byte %00000000, %00111100, %00000000
            !byte %00000000, %01111110, %00000000
            !byte %00000000, %11111111, %00000000
            !byte %00000001, %11111111, %10000000
            !byte %00000001, %11111111, %10000000
            !byte %00000011, %11111111, %11000000
            !byte %00000111, %11111111, %11100000
            !byte %00001111, %11100111, %11110000
            !byte %00011111, %11100111, %11111000
            !byte %00111111, %11111111, %11111100
            !byte %01111111, %11111111, %11111110
            !byte %01111001, %11111111, %10011110
            !byte %01110000, %11111111, %00001110
            !byte %01100000, %11111111, %00000110
            !byte %01100000, %01111110, %00000110
            !byte %01100000, %00111100, %00000110
            !byte %01100000, %00011000, %00000110
            !byte %00000000, %00000000, %00000000

;───────────────────────────────────────────────────────────────────────────────
; Bullet Sprite Data (Block 41 = $0A40 / 64)
;───────────────────────────────────────────────────────────────────────────────
            * = $0a40

bullet_sprite:
            !byte %00000000, %00000000, %00000000
            !byte %00000000, %00000000, %00000000
            !byte %00000000, %00000000, %00000000
            !byte %00000000, %00011000, %00000000
            !byte %00000000, %00011000, %00000000
            !byte %00000000, %00111100, %00000000
            !byte %00000000, %00111100, %00000000
            !byte %00000000, %00111100, %00000000
            !byte %00000000, %00111100, %00000000
            !byte %00000000, %00011000, %00000000
            !byte %00000000, %00011000, %00000000
            !byte %00000000, %00000000, %00000000
            !byte %00000000, %00000000, %00000000
            !byte %00000000, %00000000, %00000000
            !byte %00000000, %00000000, %00000000
            !byte %00000000, %00000000, %00000000
            !byte %00000000, %00000000, %00000000
            !byte %00000000, %00000000, %00000000
            !byte %00000000, %00000000, %00000000
            !byte %00000000, %00000000, %00000000
            !byte %00000000, %00000000, %00000000
