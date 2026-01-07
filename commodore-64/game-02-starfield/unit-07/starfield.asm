;═══════════════════════════════════════════════════════════════════════════════
; STARFIELD - Unit 7: Bullet Sprite
; A space shooter for the Commodore 64
;
; This unit adds a bullet sprite that fires when the fire button is pressed.
; Uses sprite 1 for the bullet, sprite 0 for the player ship.
;
; Build: acme -f cbm -o starfield.prg starfield.asm
; Run:   x64sc starfield.prg
;═══════════════════════════════════════════════════════════════════════════════

;───────────────────────────────────────────────────────────────────────────────
; BASIC stub: 10 SYS 2064
;───────────────────────────────────────────────────────────────────────────────
            * = $0801

            !byte $0c, $08      ; Pointer to next line
            !byte $0a, $00      ; Line number 10
            !byte $9e           ; SYS token
            !byte $32, $30, $36, $34  ; "2064"
            !byte $00           ; End of line
            !byte $00, $00      ; End of program

;───────────────────────────────────────────────────────────────────────────────
; Constants
;───────────────────────────────────────────────────────────────────────────────
SCREEN      = $0400             ; Default screen memory
COLOUR      = $d800             ; Colour RAM

BORDER      = $d020             ; Border colour register
BACKGROUND  = $d021             ; Background colour register

; VIC-II Sprite Registers
VIC         = $d000
SPRITE0_X   = VIC + 0           ; Sprite 0 X position
SPRITE0_Y   = VIC + 1           ; Sprite 0 Y position
SPRITE1_X   = VIC + 2           ; Sprite 1 X position
SPRITE1_Y   = VIC + 3           ; Sprite 1 Y position
SPRITE_MSB  = VIC + 16          ; $D010 - X position high bits
SPRITE_EN   = VIC + 21          ; $D015 - Sprite enable register
SPRITE0_COL = VIC + 39          ; $D027 - Sprite 0 colour
SPRITE1_COL = VIC + 40          ; $D028 - Sprite 1 colour

; Sprite pointer locations
SPRITE0_PTR = SCREEN + $03F8
SPRITE1_PTR = SCREEN + $03F9

; CIA #1 - Joystick
CIA1_PRA    = $dc00             ; Port A - Joystick 2
JOY_FIRE    = %00010000         ; Fire button mask (bit 4)

; Colours
COL_BLACK   = $00
COL_WHITE   = $01
COL_YELLOW  = $07
COL_DKBLUE  = $06
COL_LBLUE   = $0e
COL_CYAN    = $03

; Movement boundaries
MIN_X       = 24
MAX_X       = 224
MIN_Y       = 50
MAX_Y       = 220

; Movement speed
SPEED       = 2

;───────────────────────────────────────────────────────────────────────────────
; Zero Page Variables
;───────────────────────────────────────────────────────────────────────────────
player_x      = $02             ; Player X position
player_y      = $03             ; Player Y position
bullet_x      = $04             ; Bullet X position
bullet_y      = $05             ; Bullet Y position
bullet_active = $06             ; Bullet active flag (0 = inactive)

;───────────────────────────────────────────────────────────────────────────────
; Entry Point
;───────────────────────────────────────────────────────────────────────────────
            * = $0810

!zone main
main:
            jsr setup_screen
            jsr setup_sprites
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
            ; Point sprite 0 to ship data
            lda #(ship_sprite / 64)
            sta SPRITE0_PTR

            ; Point sprite 1 to bullet data
            lda #(bullet_sprite / 64)
            sta SPRITE1_PTR

            ; Initialise player position
            lda #172
            sta player_x
            sta SPRITE0_X
            lda #220
            sta player_y
            sta SPRITE0_Y

            ; Initialise bullet as inactive
            lda #0
            sta bullet_active
            sta SPRITE1_X
            sta SPRITE1_Y

            lda #$00
            sta SPRITE_MSB

            ; Ship = cyan, bullet = yellow
            lda #COL_CYAN
            sta SPRITE0_COL
            lda #COL_YELLOW
            sta SPRITE1_COL

            ; Enable sprite 0 only (bullet enabled when fired)
            lda #%00000001
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
            jsr update_sprites
            jmp main_loop

;───────────────────────────────────────────────────────────────────────────────
; Read Joystick (movement only)
;───────────────────────────────────────────────────────────────────────────────
!zone read_joystick
read_joystick:
            lda CIA1_PRA

            ; Check UP (bit 0)
            lsr
            bcs .not_up
            lda player_y
            cmp #MIN_Y
            bcc .not_up
            sec
            sbc #SPEED
            sta player_y
.not_up:

            ; Check DOWN (bit 1)
            lda CIA1_PRA
            lsr
            lsr
            bcs .not_down
            lda player_y
            cmp #MAX_Y
            bcs .not_down
            clc
            adc #SPEED
            sta player_y
.not_down:

            ; Check LEFT (bit 2)
            lda CIA1_PRA
            and #%00000100
            bne .not_left
            lda player_x
            cmp #MIN_X
            bcc .not_left
            sec
            sbc #SPEED
            sta player_x
.not_left:

            ; Check RIGHT (bit 3)
            lda CIA1_PRA
            and #%00001000
            bne .not_right
            lda player_x
            cmp #MAX_X
            bcs .not_right
            clc
            adc #SPEED
            sta player_x
.not_right:
            rts

;───────────────────────────────────────────────────────────────────────────────
; Check Fire Button
;───────────────────────────────────────────────────────────────────────────────
!zone check_fire
check_fire:
            ; Already have a bullet active?
            lda bullet_active
            bne .done

            ; Check fire button (bit 4, active low)
            lda CIA1_PRA
            and #JOY_FIRE
            bne .done               ; Not pressed (bit = 1)

            ; Fire a bullet
            jsr spawn_bullet
.done:
            rts

;───────────────────────────────────────────────────────────────────────────────
; Spawn Bullet
;───────────────────────────────────────────────────────────────────────────────
!zone spawn_bullet
spawn_bullet:
            ; Position bullet at player's location
            lda player_x
            clc
            adc #8                  ; Centre on ship (sprite is 24 wide)
            sta bullet_x

            lda player_y
            sec
            sbc #16                 ; Start above the ship
            sta bullet_y

            ; Mark bullet as active
            lda #1
            sta bullet_active

            ; Enable sprite 1
            lda SPRITE_EN
            ora #%00000010
            sta SPRITE_EN

            rts

;───────────────────────────────────────────────────────────────────────────────
; Update Sprite Positions
;───────────────────────────────────────────────────────────────────────────────
!zone update_sprites
update_sprites:
            ; Update player sprite
            lda player_x
            sta SPRITE0_X
            lda player_y
            sta SPRITE0_Y

            ; Update bullet sprite (if active)
            lda bullet_active
            beq .done
            lda bullet_x
            sta SPRITE1_X
            lda bullet_y
            sta SPRITE1_Y
.done:
            rts

;───────────────────────────────────────────────────────────────────────────────
; Ship Sprite Data (Block 38 = $0980 / 64)
;───────────────────────────────────────────────────────────────────────────────
            * = $0980

ship_sprite:
            !byte %00000000, %00000000, %00000000  ; Row 0
            !byte %00000000, %00000000, %00000000  ; Row 1
            !byte %00000000, %00011000, %00000000  ; Row 2  - nose tip
            !byte %00000000, %00111100, %00000000  ; Row 3
            !byte %00000000, %01111110, %00000000  ; Row 4
            !byte %00000000, %11111111, %00000000  ; Row 5
            !byte %00000001, %11111111, %10000000  ; Row 6
            !byte %00000001, %11111111, %10000000  ; Row 7
            !byte %00000011, %11111111, %11000000  ; Row 8
            !byte %00000111, %11111111, %11100000  ; Row 9
            !byte %00001111, %11100111, %11110000  ; Row 10 - cockpit indent
            !byte %00011111, %11100111, %11111000  ; Row 11
            !byte %00111111, %11111111, %11111100  ; Row 12 - widest body
            !byte %01111111, %11111111, %11111110  ; Row 13
            !byte %01111001, %11111111, %10011110  ; Row 14 - wing detail
            !byte %01110000, %11111111, %00001110  ; Row 15
            !byte %01100000, %11111111, %00000110  ; Row 16
            !byte %01100000, %01111110, %00000110  ; Row 17 - engine section
            !byte %01100000, %00111100, %00000110  ; Row 18
            !byte %01100000, %00011000, %00000110  ; Row 19 - exhaust
            !byte %00000000, %00000000, %00000000  ; Row 20

;───────────────────────────────────────────────────────────────────────────────
; Bullet Sprite Data (Block 39 = $09C0 / 64)
; Small vertical projectile centred in the sprite
;───────────────────────────────────────────────────────────────────────────────
            * = $09c0

bullet_sprite:
            !byte %00000000, %00000000, %00000000  ; Row 0
            !byte %00000000, %00000000, %00000000  ; Row 1
            !byte %00000000, %00000000, %00000000  ; Row 2
            !byte %00000000, %00011000, %00000000  ; Row 3
            !byte %00000000, %00011000, %00000000  ; Row 4
            !byte %00000000, %00111100, %00000000  ; Row 5
            !byte %00000000, %00111100, %00000000  ; Row 6
            !byte %00000000, %00111100, %00000000  ; Row 7
            !byte %00000000, %00111100, %00000000  ; Row 8
            !byte %00000000, %00011000, %00000000  ; Row 9
            !byte %00000000, %00011000, %00000000  ; Row 10
            !byte %00000000, %00000000, %00000000  ; Row 11
            !byte %00000000, %00000000, %00000000  ; Row 12
            !byte %00000000, %00000000, %00000000  ; Row 13
            !byte %00000000, %00000000, %00000000  ; Row 14
            !byte %00000000, %00000000, %00000000  ; Row 15
            !byte %00000000, %00000000, %00000000  ; Row 16
            !byte %00000000, %00000000, %00000000  ; Row 17
            !byte %00000000, %00000000, %00000000  ; Row 18
            !byte %00000000, %00000000, %00000000  ; Row 19
            !byte %00000000, %00000000, %00000000  ; Row 20
