;═══════════════════════════════════════════════════════════════════════════════
; STARFIELD - Unit 8: Bullet Movement
; A space shooter for the Commodore 64
;
; This unit adds bullet movement - the bullet travels upward and
; disappears when it leaves the screen.
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
SCREEN      = $0400
COLOUR      = $d800

BORDER      = $d020
BACKGROUND  = $d021

; VIC-II Sprite Registers
VIC         = $d000
SPRITE0_X   = VIC + 0
SPRITE0_Y   = VIC + 1
SPRITE1_X   = VIC + 2
SPRITE1_Y   = VIC + 3
SPRITE_MSB  = VIC + 16
SPRITE_EN   = VIC + 21
SPRITE0_COL = VIC + 39
SPRITE1_COL = VIC + 40

; Sprite pointer locations
SPRITE0_PTR = SCREEN + $03F8
SPRITE1_PTR = SCREEN + $03F9

; CIA #1 - Joystick
CIA1_PRA    = $dc00
JOY_FIRE    = %00010000

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

; Speeds
PLAYER_SPEED = 2
BULLET_SPEED = 4

; Bullet boundaries
BULLET_TOP  = 30                ; Y position where bullet deactivates

;───────────────────────────────────────────────────────────────────────────────
; Zero Page Variables
;───────────────────────────────────────────────────────────────────────────────
player_x      = $02
player_y      = $03
bullet_x      = $04
bullet_y      = $05
bullet_active = $06

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
            lda #(ship_sprite / 64)
            sta SPRITE0_PTR
            lda #(bullet_sprite / 64)
            sta SPRITE1_PTR

            lda #172
            sta player_x
            sta SPRITE0_X
            lda #220
            sta player_y
            sta SPRITE0_Y

            lda #0
            sta bullet_active
            sta SPRITE1_X
            sta SPRITE1_Y

            lda #$00
            sta SPRITE_MSB

            lda #COL_CYAN
            sta SPRITE0_COL
            lda #COL_YELLOW
            sta SPRITE1_COL

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
            jsr update_bullet
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
            lda bullet_active
            bne .done

            lda CIA1_PRA
            and #JOY_FIRE
            bne .done

            jsr spawn_bullet
.done:
            rts

;───────────────────────────────────────────────────────────────────────────────
; Spawn Bullet
;───────────────────────────────────────────────────────────────────────────────
!zone spawn_bullet
spawn_bullet:
            lda player_x
            clc
            adc #8
            sta bullet_x

            lda player_y
            sec
            sbc #16
            sta bullet_y

            lda #1
            sta bullet_active

            lda SPRITE_EN
            ora #%00000010
            sta SPRITE_EN
            rts

;───────────────────────────────────────────────────────────────────────────────
; Update Bullet
; Move bullet upward and deactivate if off-screen
;───────────────────────────────────────────────────────────────────────────────
!zone update_bullet
update_bullet:
            lda bullet_active
            beq .done               ; Skip if inactive

            ; Move bullet up
            lda bullet_y
            sec
            sbc #BULLET_SPEED
            sta bullet_y

            ; Check if off top of screen
            cmp #BULLET_TOP
            bcs .done               ; Still on screen

            ; Deactivate bullet
            lda #0
            sta bullet_active

            ; Disable sprite 1
            lda SPRITE_EN
            and #%11111101          ; Clear bit 1
            sta SPRITE_EN
.done:
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

            lda bullet_active
            beq .done
            lda bullet_x
            sta SPRITE1_X
            lda bullet_y
            sta SPRITE1_Y
.done:
            rts

;───────────────────────────────────────────────────────────────────────────────
; Ship Sprite Data (Block 38)
;───────────────────────────────────────────────────────────────────────────────
            * = $0980

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
; Bullet Sprite Data (Block 39)
;───────────────────────────────────────────────────────────────────────────────
            * = $09c0

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
