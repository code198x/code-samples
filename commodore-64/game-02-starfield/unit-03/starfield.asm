;═══════════════════════════════════════════════════════════════════════════════
; STARFIELD - Unit 3: Sprite Graphics
; A space shooter for the Commodore 64
;
; This unit creates a proper player ship sprite with custom graphics.
; The ship design is a classic upward-pointing fighter craft.
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

; Colours
COL_BLACK   = $00
COL_WHITE   = $01
COL_DKBLUE  = $06
COL_LBLUE   = $0e
COL_CYAN    = $03

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
            ; Pointer = address / 64 = $0880 / 64 = 34
            lda #(ship_sprite / 64)
            sta SPRITE0_PTR

            ; Position at bottom centre (player starting position)
            lda #172
            sta SPRITE0_X
            lda #220
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
            jmp main_loop

;───────────────────────────────────────────────────────────────────────────────
; Ship Sprite Data
; 24×21 pixels = 63 bytes (3 bytes per row)
; Aligned to 64-byte boundary
;
; Design: Classic fighter ship pointing upward
;         ....##....##....        (twin cockpits/engines)
;         ...####..####...
;         ...############...
;         ..##############..
;         ..##############..
;         .################.
;         .######....######.      (engine exhaust gaps)
;         .######....######.
;───────────────────────────────────────────────────────────────────────────────
            * = $0880

ship_sprite:
            ;        76543210 76543210 76543210
            !byte %00000000, %00000000, %00000000  ; Row 0  (empty top)
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
            !byte %00000000, %00000000, %00000000  ; Row 20 (empty bottom)
