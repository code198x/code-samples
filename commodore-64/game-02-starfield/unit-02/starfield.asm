;═══════════════════════════════════════════════════════════════════════════════
; STARFIELD - Unit 2: First Sprite
; A space shooter for the Commodore 64
;
; This unit enables hardware sprite 0 and positions it on screen.
; We use default/garbage sprite data for now - custom graphics in Unit 3.
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
COL_YELLOW  = $07
COL_LBLUE   = $0e

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
; - Set border to dark blue
; - Set background to black
; - Clear screen memory with spaces
;───────────────────────────────────────────────────────────────────────────────
!zone setup_screen
setup_screen:
            ; Set border to dark blue
            lda #COL_DKBLUE
            sta BORDER

            ; Set background to black
            lda #COL_BLACK
            sta BACKGROUND

            ; Clear screen and colour RAM
            ldx #$00
.clear_loop:
            lda #$20            ; Space character
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
; - Point sprite 0 to our sprite data
; - Set sprite position (centre of screen)
; - Set sprite colour
; - Enable sprite 0
;───────────────────────────────────────────────────────────────────────────────
!zone setup_sprite
setup_sprite:
            ; Point sprite 0 to our data
            ; Pointer value = address / 64
            ; sprite_data is at $0880, so pointer = $0880 / 64 = 34
            lda #(sprite_data / 64)
            sta SPRITE0_PTR

            ; Set sprite 0 position (roughly centre screen)
            ; X = 172 (centre), Y = 140 (centre)
            lda #172
            sta SPRITE0_X
            lda #140
            sta SPRITE0_Y

            ; Clear X high bit (X < 256)
            lda #$00
            sta SPRITE_MSB

            ; Set sprite colour to light blue
            lda #COL_LBLUE
            sta SPRITE0_COL

            ; Enable sprite 0 (bit 0 of $D015)
            lda #%00000001
            sta SPRITE_EN

            rts

;───────────────────────────────────────────────────────────────────────────────
; Main Loop
; For now, just wait forever
;───────────────────────────────────────────────────────────────────────────────
!zone main_loop
main_loop:
            jmp main_loop

;───────────────────────────────────────────────────────────────────────────────
; Sprite Data
; 24x21 pixels = 63 bytes (3 bytes per row × 21 rows)
; Must be aligned to 64-byte boundary
;───────────────────────────────────────────────────────────────────────────────
            * = $0880           ; 64-byte aligned address (block 34)

sprite_data:
            ; Simple diamond/ship shape
            !byte %00000000, %00000000, %00000000  ; Row 0
            !byte %00000000, %00000000, %00000000  ; Row 1
            !byte %00000000, %00000000, %00000000  ; Row 2
            !byte %00000000, %00011000, %00000000  ; Row 3
            !byte %00000000, %00111100, %00000000  ; Row 4
            !byte %00000000, %01111110, %00000000  ; Row 5
            !byte %00000000, %11111111, %00000000  ; Row 6
            !byte %00000001, %11111111, %10000000  ; Row 7
            !byte %00000011, %11111111, %11000000  ; Row 8
            !byte %00000111, %11111111, %11100000  ; Row 9
            !byte %00001111, %11111111, %11110000  ; Row 10 (widest)
            !byte %00000111, %11111111, %11100000  ; Row 11
            !byte %00000011, %11111111, %11000000  ; Row 12
            !byte %00000001, %11111111, %10000000  ; Row 13
            !byte %00000000, %11111111, %00000000  ; Row 14
            !byte %00000000, %01111110, %00000000  ; Row 15
            !byte %00000000, %00111100, %00000000  ; Row 16
            !byte %00000000, %00011000, %00000000  ; Row 17
            !byte %00000000, %00000000, %00000000  ; Row 18
            !byte %00000000, %00000000, %00000000  ; Row 19
            !byte %00000000, %00000000, %00000000  ; Row 20
