;═══════════════════════════════════════════════════════════════════════════════
; STARFIELD - Unit 12: Collision Detection
; A space shooter for the Commodore 64
;
; This unit adds hardware sprite collision detection.
; Uses VIC-II register $D01E to detect bullet-enemy collisions.
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
SPRITE5_X   = VIC + 10
SPRITE5_Y   = VIC + 11
SPRITE_MSB  = VIC + 16
SPRITE_EN   = VIC + 21
SPRITE_SSC  = VIC + 30          ; $D01E - Sprite-sprite collision
SPRITE_COL  = VIC + 39

SPRITE0_PTR = SCREEN + $03F8
SPRITE5_PTR = SCREEN + $03FD

CIA1_PRA    = $dc00
JOY_FIRE    = %00010000

; Colours
COL_BLACK   = $00
COL_WHITE   = $01
COL_RED     = $02
COL_YELLOW  = $07
COL_DKBLUE  = $06
COL_GREEN   = $05
COL_CYAN    = $03

; Boundaries
MIN_X       = 24
MAX_X       = 224
MIN_Y       = 50
MAX_Y       = 220
ENEMY_MIN_X = 30
ENEMY_MAX_X = 230

; Speeds
PLAYER_SPEED = 2
BULLET_SPEED = 4
ENEMY_SPEED  = 1

BULLET_TOP  = 30
MAX_BULLETS = 4

;───────────────────────────────────────────────────────────────────────────────
; Zero Page Variables
;───────────────────────────────────────────────────────────────────────────────
player_x     = $02
player_y     = $03
fire_delay   = $04
enemy_x      = $05
enemy_y      = $06
enemy_dir    = $07
enemy_active = $08
collision    = $09              ; Collision flags storage

;───────────────────────────────────────────────────────────────────────────────
; Entry Point
;───────────────────────────────────────────────────────────────────────────────
            * = $0810

!zone main
main:
            jsr setup_screen
            jsr setup_sprites
            jsr init_bullets
            jsr init_enemy
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
            lda #(ship_sprite / 64)
            sta SPRITE0_PTR

            lda #(bullet_sprite / 64)
            sta SPRITE0_PTR + 1
            sta SPRITE0_PTR + 2
            sta SPRITE0_PTR + 3
            sta SPRITE0_PTR + 4

            lda #(enemy_sprite / 64)
            sta SPRITE5_PTR

            lda #172
            sta player_x
            sta SPRITE0_X
            lda #220
            sta player_y
            sta SPRITE0_Y

            lda #$00
            sta SPRITE_MSB

            lda #COL_CYAN
            sta SPRITE_COL
            lda #COL_YELLOW
            sta SPRITE_COL + 1
            sta SPRITE_COL + 2
            sta SPRITE_COL + 3
            sta SPRITE_COL + 4
            lda #COL_GREEN
            sta SPRITE_COL + 5

            lda #%00000001
            sta SPRITE_EN

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
; Initialise Enemy
;───────────────────────────────────────────────────────────────────────────────
!zone init_enemy
init_enemy:
            lda #172
            sta enemy_x
            sta SPRITE5_X
            lda #60
            sta enemy_y
            sta SPRITE5_Y

            lda #ENEMY_SPEED
            sta enemy_dir

            lda #1
            sta enemy_active

            lda SPRITE_EN
            ora #%00100000
            sta SPRITE_EN
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
            jsr update_enemy
            jsr update_sprites
            jsr check_collisions
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
            lda fire_delay
            beq .can_fire
            dec fire_delay
            rts

.can_fire:
            lda CIA1_PRA
            and #JOY_FIRE
            bne .done

            jsr spawn_bullet
            lda #8
            sta fire_delay
.done:
            rts

;───────────────────────────────────────────────────────────────────────────────
; Spawn Bullet
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
            rts

.found_slot:
            lda #1
            sta bullet_active,x

            lda player_x
            clc
            adc #8
            sta bullet_x,x

            lda player_y
            sec
            sbc #16
            sta bullet_y,x

            lda SPRITE_EN
            ora sprite_bit,x
            sta SPRITE_EN
            rts

sprite_bit:
            !byte %00000010, %00000100, %00001000, %00010000

;───────────────────────────────────────────────────────────────────────────────
; Update Bullets
;───────────────────────────────────────────────────────────────────────────────
!zone update_bullets
update_bullets:
            ldx #0
.loop:
            lda bullet_active,x
            beq .next

            lda bullet_y,x
            sec
            sbc #BULLET_SPEED
            sta bullet_y,x

            cmp #BULLET_TOP
            bcs .next

            lda #0
            sta bullet_active,x

            lda sprite_bit,x
            eor #$ff
            and SPRITE_EN
            sta SPRITE_EN

.next:
            inx
            cpx #MAX_BULLETS
            bne .loop
            rts

;───────────────────────────────────────────────────────────────────────────────
; Update Enemy
;───────────────────────────────────────────────────────────────────────────────
!zone update_enemy
update_enemy:
            lda enemy_active
            beq .done

            lda enemy_x
            clc
            adc enemy_dir
            sta enemy_x

            cmp #ENEMY_MAX_X
            bcc .check_left
            lda #256 - ENEMY_SPEED
            sta enemy_dir
            jmp .done

.check_left:
            cmp #ENEMY_MIN_X
            bcs .done
            lda #ENEMY_SPEED
            sta enemy_dir

.done:
            rts

;───────────────────────────────────────────────────────────────────────────────
; Check Collisions
; Use hardware sprite-sprite collision register $D01E
;───────────────────────────────────────────────────────────────────────────────
!zone check_collisions
check_collisions:
            lda SPRITE_SSC          ; Read clears the register
            sta collision           ; Store for checking

            ; Check if enemy (sprite 5) collided with any bullet (sprites 1-4)
            lda enemy_active
            beq .done

            ; Check enemy bit
            lda collision
            and #%00100000          ; Sprite 5 bit
            beq .done

            ; Enemy collided - check which bullet
            ldx #0
.check_bullets:
            lda bullet_active,x
            beq .next_bullet

            lda collision
            and sprite_bit,x
            beq .next_bullet

            ; This bullet hit the enemy!
            jsr handle_hit

.next_bullet:
            inx
            cpx #MAX_BULLETS
            bne .check_bullets

.done:
            rts

;───────────────────────────────────────────────────────────────────────────────
; Handle Hit - Bullet hit enemy
;───────────────────────────────────────────────────────────────────────────────
!zone handle_hit
handle_hit:
            ; Deactivate bullet (X = bullet index)
            lda #0
            sta bullet_active,x

            ; Disable bullet sprite
            lda sprite_bit,x
            eor #$ff
            and SPRITE_EN
            sta SPRITE_EN

            ; Flash enemy white briefly (visual feedback)
            lda #COL_WHITE
            sta SPRITE_COL + 5

            rts

;───────────────────────────────────────────────────────────────────────────────
; Update Sprite Positions
;───────────────────────────────────────────────────────────────────────────────
!zone update_sprites
update_sprites:
            lda player_x
            sta SPRITE0_X
            lda player_y
            sta SPRITE0_Y

            ldx #0
.loop:
            lda bullet_active,x
            beq .next

            txa
            asl
            clc
            adc #2
            tay

            lda bullet_x,x
            sta VIC,y
            lda bullet_y,x
            sta VIC + 1,y

.next:
            inx
            cpx #MAX_BULLETS
            bne .loop

            lda enemy_active
            beq .skip_enemy
            lda enemy_x
            sta SPRITE5_X
            lda enemy_y
            sta SPRITE5_Y
.skip_enemy:
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
; Sprite Data
;───────────────────────────────────────────────────────────────────────────────
            * = $0a80

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

            * = $0ac0

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

            * = $0b00

enemy_sprite:
            !byte %00000000, %00000000, %00000000
            !byte %00000000, %00000000, %00000000
            !byte %00000100, %00000000, %00100000
            !byte %00000010, %00000000, %01000000
            !byte %00000111, %11111111, %11100000
            !byte %00001101, %11111111, %10110000
            !byte %00011111, %11111111, %11111000
            !byte %00011011, %11111111, %11011000
            !byte %00011111, %11111111, %11111000
            !byte %00000111, %10000001, %11100000
            !byte %00000011, %00000000, %11000000
            !byte %00000110, %00000000, %01100000
            !byte %00001100, %00000000, %00110000
            !byte %00000000, %00000000, %00000000
            !byte %00000000, %00000000, %00000000
            !byte %00000000, %00000000, %00000000
            !byte %00000000, %00000000, %00000000
            !byte %00000000, %00000000, %00000000
            !byte %00000000, %00000000, %00000000
            !byte %00000000, %00000000, %00000000
            !byte %00000000, %00000000, %00000000
