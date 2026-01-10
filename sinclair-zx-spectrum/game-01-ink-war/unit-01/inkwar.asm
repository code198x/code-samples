; Ink War - Unit 01: The Spectrum's Display
; First contact with the Spectrum's memory-mapped display
;
; Learning objectives:
; - Run machine code from BASIC
; - Change the border colour
; - Write to attribute memory
; - See colour on screen

        org $8000           ; 32768 - our code starts here

; =============================================================================
; CONSTANTS
; =============================================================================

ATTR_START  equ $5800       ; Attribute memory starts here
BORDER_PORT equ $FE         ; Border colour port

; Colours (for attribute bytes)
BLACK       equ 0
BLUE        equ 1
RED         equ 2
MAGENTA     equ 3
GREEN       equ 4
CYAN        equ 5
YELLOW      equ 6
WHITE       equ 7

; =============================================================================
; MAIN PROGRAM
; =============================================================================

start:
        ; Set the border colour to blue
        ; The border is controlled by port $FE (254)
        ; Bits 0-2 set the border colour

        ld a, BLUE          ; Blue border
        out (BORDER_PORT), a

        ; Now let's put some coloured blocks on screen
        ; Attribute memory is at $5800-$5AFF (768 bytes)
        ; Each byte controls the colour of one 8x8 pixel cell
        ;
        ; Attribute byte format: FBPPPIII
        ; F = Flash (bit 7)
        ; B = Bright (bit 6)
        ; PPP = Paper colour (bits 5-3)
        ; III = Ink colour (bits 2-0)

        ; Let's colour some cells in the top-left corner
        ; Address = $5800 + (row * 32) + column

        ; First cell (row 0, column 0) - Red paper, white ink
        ld hl, ATTR_START   ; $5800
        ld a, %00010111     ; Red paper (010), white ink (111)
        ld (hl), a

        ; Second cell (row 0, column 1) - Blue paper, yellow ink
        inc hl              ; Next cell
        ld a, %00001110     ; Blue paper (001), yellow ink (110)
        ld (hl), a

        ; Third cell (row 0, column 2) - Green paper, black ink
        inc hl
        ld a, %00100000     ; Green paper (100), black ink (000)
        ld (hl), a

        ; Fourth cell (row 0, column 3) - Cyan paper, magenta ink
        inc hl
        ld a, %00101011     ; Cyan paper (101), magenta ink (011)
        ld (hl), a

        ; Let's add a bright cell below (row 1, column 0)
        ; Row 1 starts at $5800 + 32 = $5820
        ld hl, ATTR_START + 32
        ld a, %01010111     ; Bright + Red paper, white ink
        ld (hl), a

        ; And a flashing cell next to it (row 1, column 1)
        inc hl
        ld a, %10001110     ; Flash + Blue paper, yellow ink
        ld (hl), a

        ; Infinite loop - keep the program running
        ; Without this, we'd return to BASIC and lose our colours
forever:
        jr forever          ; Jump to self - loops forever

        end start
