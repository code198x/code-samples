;═══════════════════════════════════════════════════════════════════════════════
; STARFIELD - Unit 1: Screen Setup
; A space shooter for the Commodore 64
;
; This unit establishes the display: black background with dark blue border,
; creating the starfield backdrop ready for sprites.
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

; Colours
COL_BLACK   = $00
COL_DKBLUE  = $06               ; Dark blue for border

;───────────────────────────────────────────────────────────────────────────────
; Entry Point
;───────────────────────────────────────────────────────────────────────────────
            * = $0810

!zone main
main:
            jsr setup_screen
            jmp main_loop

;───────────────────────────────────────────────────────────────────────────────
; Setup Screen
; - Set border to dark blue
; - Set background to black
; - Clear screen memory with spaces
; - Clear colour RAM to black
;───────────────────────────────────────────────────────────────────────────────
!zone setup_screen
setup_screen:
            ; Set border to dark blue (the void of space)
            lda #COL_DKBLUE
            sta BORDER

            ; Set background to black (deep space)
            lda #COL_BLACK
            sta BACKGROUND

            ; Clear screen and colour RAM
            ; Screen is 1000 bytes ($0400-$07E7)
            ; We clear in 4 chunks of 256 bytes
            ldx #$00
.clear_loop:
            lda #$20            ; Space character (blank)
            sta SCREEN,x
            sta SCREEN + $100,x
            sta SCREEN + $200,x
            sta SCREEN + $2e8,x ; Last chunk (partial)

            lda #COL_BLACK      ; Black text colour
            sta COLOUR,x
            sta COLOUR + $100,x
            sta COLOUR + $200,x
            sta COLOUR + $2e8,x

            inx
            bne .clear_loop

            rts

;───────────────────────────────────────────────────────────────────────────────
; Main Loop
; For now, just wait forever - sprites come in Unit 2
;───────────────────────────────────────────────────────────────────────────────
!zone main_loop
main_loop:
            jmp main_loop       ; Infinite loop
