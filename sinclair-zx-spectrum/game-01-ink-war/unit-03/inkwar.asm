; Ink War - Unit 03: Drawing the Board
; Create the game board: 8x8 white cells with black border
;
; Learning objectives:
; - Use constants for board positioning
; - Draw a border around the playing area
; - Fill the board with the "empty" colour
; - Centre elements on screen

        org $8000           ; 32768 - our code starts here

; =============================================================================
; CONSTANTS
; =============================================================================

; Screen layout
ATTR_START  equ $5800       ; Attribute memory
ATTR_WIDTH  equ 32          ; Cells per row
ATTR_SIZE   equ 768         ; Total attribute cells

; Board positioning (centred on 32x24 screen)
; Board is 8x8, so border is 10x10
; Centre column: (32 - 10) / 2 = 11
; Centre row: (24 - 10) / 2 = 7
BOARD_SIZE  equ 8           ; 8x8 playing area
BORDER_SIZE equ 10          ; 10x10 including border
BOARD_TOP   equ 8           ; First board row (row 7 is border)
BOARD_LEFT  equ 12          ; First board column (col 11 is border)
BORDER_TOP  equ 7           ; Border starts one row above board
BORDER_LEFT equ 11          ; Border starts one column left of board

; Ports
BORDER_PORT equ $FE         ; Screen border colour port

; Colours (as paper colours - shifted to bits 5-3)
BLACK_PAPER equ %00000000   ; Black background
WHITE_PAPER equ %00111000   ; White background
GREY_PAPER  equ %00000000   ; Black (no grey on Spectrum)

; =============================================================================
; MAIN PROGRAM
; =============================================================================

start:
        ; Set the screen border to black
        xor a               ; A = 0 (black)
        out (BORDER_PORT), a

        ; Clear entire screen to black
        call clear_screen

        ; Draw the board border (black frame)
        call draw_border

        ; Fill the playing area with white (empty cells)
        call draw_board

        ; Done - loop forever
forever:
        jr forever

; =============================================================================
; SUBROUTINES
; =============================================================================

; -----------------------------------------------------------------------------
; Clear entire attribute memory to black
; -----------------------------------------------------------------------------
clear_screen:
        ld hl, ATTR_START
        ld de, ATTR_START + 1
        ld bc, ATTR_SIZE - 1
        ld (hl), BLACK_PAPER    ; Black paper, black ink
        ldir
        ret

; -----------------------------------------------------------------------------
; Draw the border around the board
; The border is 10x10 cells, with the 8x8 board inside
; We draw a frame of black cells (which will contrast with the white board)
; Actually, since background is black, we need the border to be visible
; Let's make the border bright white to frame the playing area
; -----------------------------------------------------------------------------
draw_border:
        ; We'll draw a white frame around where the board will go
        ; Top border row
        ld hl, ATTR_START + (BORDER_TOP * ATTR_WIDTH) + BORDER_LEFT
        ld b, BORDER_SIZE       ; 10 cells wide
        ld a, %00111111         ; White paper, white ink (solid white)
border_top:
        ld (hl), a
        inc hl
        djnz border_top

        ; Bottom border row
        ld hl, ATTR_START + ((BORDER_TOP + BORDER_SIZE - 1) * ATTR_WIDTH) + BORDER_LEFT
        ld b, BORDER_SIZE
        ld a, %00111111
border_bottom:
        ld (hl), a
        inc hl
        djnz border_bottom

        ; Left and right border columns (middle 8 rows)
        ld hl, ATTR_START + ((BORDER_TOP + 1) * ATTR_WIDTH) + BORDER_LEFT
        ld b, BORDER_SIZE - 2   ; 8 rows (excluding top and bottom)
border_sides:
        push bc
        push hl
        ld a, %00111111         ; White

        ; Left side
        ld (hl), a

        ; Right side (9 cells to the right)
        ld de, BORDER_SIZE - 1
        add hl, de
        ld (hl), a

        pop hl
        ld de, ATTR_WIDTH       ; Move to next row
        add hl, de
        pop bc
        djnz border_sides

        ret

; -----------------------------------------------------------------------------
; Fill the 8x8 board with white (empty cells)
; -----------------------------------------------------------------------------
draw_board:
        ; Calculate board start address
        ; $5800 + (BOARD_TOP × 32) + BOARD_LEFT
        ld hl, ATTR_START + (BOARD_TOP * ATTR_WIDTH) + BOARD_LEFT

        ld b, BOARD_SIZE        ; 8 rows

board_row:
        push bc
        push hl

        ld b, BOARD_SIZE        ; 8 columns
        ld a, %00111000         ; White paper, black ink (empty cell)

board_col:
        ld (hl), a
        inc hl
        djnz board_col

        pop hl
        ld de, ATTR_WIDTH       ; 32 bytes to next row
        add hl, de
        pop bc
        djnz board_row

        ret

        end start
