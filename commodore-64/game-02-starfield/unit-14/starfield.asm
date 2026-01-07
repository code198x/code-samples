;═══════════════════════════════════════════════════════════════════════════════
; STARFIELD - Unit 14: Wave System
; A space shooter for the Commodore 64
;
; This unit adds multiple enemies (3) and wave progression.
; Destroying all enemies starts a new wave with faster enemies.
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
SPRITE_MSB  = VIC + 16
SPRITE_EN   = VIC + 21
SPRITE_SSC  = VIC + 30
SPRITE_COL  = VIC + 39

SPRITE_PTR  = SCREEN + $03F8

CIA1_PRA    = $dc00
JOY_FIRE    = %00010000

; Colours
COL_BLACK   = $00
COL_WHITE   = $01
COL_YELLOW  = $07
COL_DKBLUE  = $06
COL_GREEN   = $05
COL_CYAN    = $03
COL_LGREEN  = $0d

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

BULLET_TOP  = 30
MAX_BULLETS = 4
MAX_ENEMIES = 3

;───────────────────────────────────────────────────────────────────────────────
; Zero Page Variables
;───────────────────────────────────────────────────────────────────────────────
player_x    = $02
player_y    = $03
fire_delay  = $04
collision   = $05
wave_number = $06
enemy_speed = $07

;───────────────────────────────────────────────────────────────────────────────
; Entry Point
;───────────────────────────────────────────────────────────────────────────────
            * = $0810

!zone main
main:
            jsr setup_screen
            jsr setup_sprites
            jsr init_bullets
            jsr init_wave
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
            ; Sprite 0 = player
            lda #(ship_sprite / 64)
            sta SPRITE_PTR

            ; Sprites 1-4 = bullets
            lda #(bullet_sprite / 64)
            sta SPRITE_PTR + 1
            sta SPRITE_PTR + 2
            sta SPRITE_PTR + 3
            sta SPRITE_PTR + 4

            ; Sprites 5-7 = enemies
            lda #(enemy_sprite / 64)
            sta SPRITE_PTR + 5
            sta SPRITE_PTR + 6
            sta SPRITE_PTR + 7

            ; Player position
            lda #172
            sta player_x
            sta VIC
            lda #220
            sta player_y
            sta VIC + 1

            lda #$00
            sta SPRITE_MSB

            ; Colours
            lda #COL_CYAN
            sta SPRITE_COL
            lda #COL_YELLOW
            sta SPRITE_COL + 1
            sta SPRITE_COL + 2
            sta SPRITE_COL + 3
            sta SPRITE_COL + 4
            lda #COL_GREEN
            sta SPRITE_COL + 5
            sta SPRITE_COL + 6
            sta SPRITE_COL + 7

            ; Enable player only initially
            lda #%00000001
            sta SPRITE_EN

            lda #0
            sta fire_delay

            ; Start at wave 1
            lda #1
            sta wave_number
            lda #1
            sta enemy_speed
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
            dex
            bpl .loop
            rts

;───────────────────────────────────────────────────────────────────────────────
; Initialise Wave - Setup all enemies
;───────────────────────────────────────────────────────────────────────────────
!zone init_wave
init_wave:
            ; Enemy 0 - left
            lda #60
            sta enemy_x
            lda #60
            sta enemy_y
            lda enemy_speed
            sta enemy_dir
            lda #1
            sta enemy_active

            ; Enemy 1 - centre
            lda #140
            sta enemy_x + 1
            lda #60
            sta enemy_y + 1
            lda enemy_speed
            eor #$ff
            clc
            adc #1              ; Negate for opposite direction
            sta enemy_dir + 1
            lda #1
            sta enemy_active + 1

            ; Enemy 2 - right
            lda #220
            sta enemy_x + 2
            lda #60
            sta enemy_y + 2
            lda enemy_speed
            sta enemy_dir + 2
            lda #1
            sta enemy_active + 2

            ; Enable enemy sprites (5-7)
            lda SPRITE_EN
            ora #%11100000
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
            jsr update_enemies
            jsr update_sprites
            jsr check_collisions
            jsr check_wave_clear
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

enemy_sprite_bit:
            !byte %00100000, %01000000, %10000000

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
; Update Enemies
;───────────────────────────────────────────────────────────────────────────────
!zone update_enemies
update_enemies:
            ldx #0
.loop:
            lda enemy_active,x
            beq .next

            ; Move enemy
            lda enemy_x,x
            clc
            adc enemy_dir,x
            sta enemy_x,x

            ; Check right boundary
            cmp #ENEMY_MAX_X
            bcc .check_left

            ; Reverse direction (go left)
            lda enemy_dir,x
            eor #$ff
            clc
            adc #1
            sta enemy_dir,x
            jmp .next

.check_left:
            cmp #ENEMY_MIN_X
            bcs .next

            ; Reverse direction (go right)
            lda enemy_dir,x
            eor #$ff
            clc
            adc #1
            sta enemy_dir,x

.next:
            inx
            cpx #MAX_ENEMIES
            bne .loop
            rts

;───────────────────────────────────────────────────────────────────────────────
; Check Collisions
;───────────────────────────────────────────────────────────────────────────────
!zone check_collisions
check_collisions:
            lda SPRITE_SSC
            sta collision

            ; Check each enemy
            ldx #0
.check_enemy:
            lda enemy_active,x
            beq .next_enemy

            ; Check if this enemy collided
            lda collision
            and enemy_sprite_bit,x
            beq .next_enemy

            ; Check against each bullet
            stx temp_enemy
            ldx #0
.check_bullet:
            lda bullet_active,x
            beq .next_bullet

            lda collision
            and sprite_bit,x
            beq .next_bullet

            ; Hit! Destroy both
            jsr handle_hit

.next_bullet:
            inx
            cpx #MAX_BULLETS
            bne .check_bullet

            ldx temp_enemy

.next_enemy:
            inx
            cpx #MAX_ENEMIES
            bne .check_enemy

            rts

temp_enemy: !byte 0

;───────────────────────────────────────────────────────────────────────────────
; Handle Hit
;───────────────────────────────────────────────────────────────────────────────
!zone handle_hit
handle_hit:
            ; X = bullet index, temp_enemy = enemy index
            ; Deactivate bullet
            lda #0
            sta bullet_active,x

            lda sprite_bit,x
            eor #$ff
            and SPRITE_EN
            sta SPRITE_EN

            ; Deactivate enemy
            stx temp_bullet
            ldx temp_enemy

            lda #0
            sta enemy_active,x

            lda enemy_sprite_bit,x
            eor #$ff
            and SPRITE_EN
            sta SPRITE_EN

            ldx temp_bullet
            rts

temp_bullet: !byte 0

;───────────────────────────────────────────────────────────────────────────────
; Check Wave Clear
;───────────────────────────────────────────────────────────────────────────────
!zone check_wave_clear
check_wave_clear:
            ldx #0
            ldy #0              ; Count active enemies
.loop:
            lda enemy_active,x
            beq .next
            iny
.next:
            inx
            cpx #MAX_ENEMIES
            bne .loop

            cpy #0
            bne .done

            ; All enemies destroyed - next wave!
            jsr next_wave

.done:
            rts

;───────────────────────────────────────────────────────────────────────────────
; Next Wave
;───────────────────────────────────────────────────────────────────────────────
!zone next_wave
next_wave:
            inc wave_number

            ; Increase enemy speed (max 3)
            lda enemy_speed
            cmp #3
            bcs .init
            inc enemy_speed

.init:
            jsr init_wave
            rts

;───────────────────────────────────────────────────────────────────────────────
; Update Sprite Positions
;───────────────────────────────────────────────────────────────────────────────
!zone update_sprites
update_sprites:
            ; Player
            lda player_x
            sta VIC
            lda player_y
            sta VIC + 1

            ; Bullets
            ldx #0
.bullet_loop:
            lda bullet_active,x
            beq .next_bullet

            txa
            asl
            clc
            adc #2
            tay

            lda bullet_x,x
            sta VIC,y
            lda bullet_y,x
            sta VIC + 1,y

.next_bullet:
            inx
            cpx #MAX_BULLETS
            bne .bullet_loop

            ; Enemies (sprites 5-7 = VIC offsets 10-15)
            ldx #0
.enemy_loop:
            lda enemy_active,x
            beq .next_enemy

            txa
            asl
            clc
            adc #10             ; Sprite 5 starts at offset 10
            tay

            lda enemy_x,x
            sta VIC,y
            lda enemy_y,x
            sta VIC + 1,y

.next_enemy:
            inx
            cpx #MAX_ENEMIES
            bne .enemy_loop
            rts

;───────────────────────────────────────────────────────────────────────────────
; Data
;───────────────────────────────────────────────────────────────────────────────
bullet_active:  !byte 0, 0, 0, 0
bullet_x:       !byte 0, 0, 0, 0
bullet_y:       !byte 0, 0, 0, 0

enemy_active:   !byte 0, 0, 0
enemy_x:        !byte 0, 0, 0
enemy_y:        !byte 0, 0, 0
enemy_dir:      !byte 0, 0, 0

;───────────────────────────────────────────────────────────────────────────────
; Sprite Data
;───────────────────────────────────────────────────────────────────────────────
            * = $0b00

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

            * = $0b40

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

            * = $0b80

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
