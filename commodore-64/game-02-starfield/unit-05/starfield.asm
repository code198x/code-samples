;═══════════════════════════════════════════════════════════════════════════════
; STARFIELD - Unit 5: Player Movement
; A space shooter for the Commodore 64
;
; This unit combines joystick input with sprite positioning.
; Player ship moves smoothly in all four directions.
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
SPRITE_MSB  = VIC + 16          ; $D010 - X position high bits
SPRITE_EN   = VIC + 21          ; $D015 - Sprite enable register
SPRITE0_COL = VIC + 39          ; $D027 - Sprite 0 colour

; Sprite pointer location (screen + $03F8)
SPRITE0_PTR = SCREEN + $03F8

; CIA #1 - Joystick
CIA1_PRA    = $dc00             ; Port A - Joystick 2

; Colours
COL_BLACK   = $00
COL_WHITE   = $01
COL_DKBLUE  = $06
COL_LBLUE   = $0e
COL_CYAN    = $03

; Movement boundaries
MIN_X       = 24                ; Left edge
MAX_X       = 224               ; Right edge (low byte, no MSB needed)
MIN_Y       = 50                ; Top edge
MAX_Y       = 220               ; Bottom edge

; Movement speed
SPEED       = 2

;───────────────────────────────────────────────────────────────────────────────
; Zero Page Variables
;───────────────────────────────────────────────────────────────────────────────
player_x    = $02               ; Player X position
player_y    = $03               ; Player Y position

;───────────────────────────────────────────────────────────────────────────────
; Entry Point
;───────────────────────────────────────────────────────────────────────────────
            * = $0810

!zone main
main:
            jsr setup_screen
            jsr setup_sprite
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
; Setup Sprite
;───────────────────────────────────────────────────────────────────────────────
!zone setup_sprite
setup_sprite:
            ; Point sprite 0 to ship data
            lda #(ship_sprite / 64)
            sta SPRITE0_PTR

            ; Initialise player position
            lda #172
            sta player_x
            sta SPRITE0_X
            lda #220
            sta player_y
            sta SPRITE0_Y

            lda #$00
            sta SPRITE_MSB

            ; Cyan colour for the ship
            lda #COL_CYAN
            sta SPRITE0_COL

            ; Enable sprite 0
            lda #%00000001
            sta SPRITE_EN
            rts

;───────────────────────────────────────────────────────────────────────────────
; Main Loop
;───────────────────────────────────────────────────────────────────────────────
!zone main_loop
main_loop:
            ; Wait for raster line 255 (simple vsync)
.wait_raster:
            lda $d012
            cmp #255
            bne .wait_raster

            jsr read_joystick
            jsr update_sprite
            jmp main_loop

;───────────────────────────────────────────────────────────────────────────────
; Read Joystick
; CIA #1 Port A ($DC00) - Joystick 2
; Bits are ACTIVE LOW (0 = pressed)
; Bit 0 = Up, Bit 1 = Down, Bit 2 = Left, Bit 3 = Right, Bit 4 = Fire
;───────────────────────────────────────────────────────────────────────────────
!zone read_joystick
read_joystick:
            lda CIA1_PRA        ; Read joystick port

            ; Check UP (bit 0)
            lsr                 ; Shift bit 0 into carry
            bcs .not_up
            ; Move up
            lda player_y
            cmp #MIN_Y
            bcc .not_up         ; Already at top
            sec
            sbc #SPEED
            sta player_y
.not_up:

            ; Check DOWN (bit 1 now in bit 0)
            lda CIA1_PRA
            lsr
            lsr                 ; Shift bit 1 into carry
            bcs .not_down
            ; Move down
            lda player_y
            cmp #MAX_Y
            bcs .not_down       ; Already at bottom
            clc
            adc #SPEED
            sta player_y
.not_down:

            ; Check LEFT (bit 2)
            lda CIA1_PRA
            and #%00000100
            bne .not_left
            ; Move left
            lda player_x
            cmp #MIN_X
            bcc .not_left       ; Already at left
            sec
            sbc #SPEED
            sta player_x
.not_left:

            ; Check RIGHT (bit 3)
            lda CIA1_PRA
            and #%00001000
            bne .not_right
            ; Move right
            lda player_x
            cmp #MAX_X
            bcs .not_right      ; Already at right
            clc
            adc #SPEED
            sta player_x
.not_right:

            rts

;───────────────────────────────────────────────────────────────────────────────
; Update Sprite Position
;───────────────────────────────────────────────────────────────────────────────
!zone update_sprite
update_sprite:
            lda player_x
            sta SPRITE0_X
            lda player_y
            sta SPRITE0_Y
            rts

;───────────────────────────────────────────────────────────────────────────────
; Ship Sprite Data
;───────────────────────────────────────────────────────────────────────────────
            * = $0900           ; Block 36 ($0900 / 64 = 36)

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
