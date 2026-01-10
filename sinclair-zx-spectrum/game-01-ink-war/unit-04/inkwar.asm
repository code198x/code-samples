; Ink War - Unit 04: Player Colours
; Define player colours and demonstrate claiming cells
;
; Learning objectives:
; - Define player colour constants
; - Create a subroutine to colour a cell by row/column
; - Understand game state: empty, player 1, player 2
; - See a preview of gameplay

        org $8000

; =============================================================================
; CONSTANTS
; =============================================================================

; Screen layout
ATTR_START  equ $5800
ATTR_WIDTH  equ 32
ATTR_SIZE   equ 768

; Board positioning
BOARD_SIZE  equ 8
BOARD_TOP   equ 8
BOARD_LEFT  equ 12
BORDER_TOP  equ 7
BORDER_LEFT equ 11
BORDER_SIZE equ 10

; Ports
BORDER_PORT equ $FE

; Cell states
EMPTY       equ 0
PLAYER1     equ 1
PLAYER2     equ 2

; Attribute colours for each state
; Format: FBPPPIII (Flash, Bright, Paper, Ink)
EMPTY_ATTR  equ %00111000   ; White paper, black ink
P1_ATTR     equ %01010000   ; Bright red paper, black ink
P2_ATTR     equ %01001000   ; Bright blue paper, black ink
BORDER_ATTR equ %00111111   ; White paper, white ink (solid)
BLACK_ATTR  equ %00000000   ; Black paper, black ink

; =============================================================================
; MAIN PROGRAM
; =============================================================================

start:
        ; Set screen border to black
        xor a
        out (BORDER_PORT), a

        ; Clear screen and draw the game board
        call clear_screen
        call draw_border
        call draw_board

        ; Now demonstrate player colours by placing some claims
        ; This simulates a game in progress

        ; Player 1 claims: (0,0), (0,1), (1,0), (2,3), (3,3), (4,4)
        ld b, 0             ; Row
        ld c, 0             ; Column
        ld a, PLAYER1
        call set_cell

        ld b, 0
        ld c, 1
        ld a, PLAYER1
        call set_cell

        ld b, 1
        ld c, 0
        ld a, PLAYER1
        call set_cell

        ld b, 1
        ld c, 1
        ld a, PLAYER1
        call set_cell

        ld b, 2
        ld c, 2
        ld a, PLAYER1
        call set_cell

        ; Player 2 claims: (7,7), (7,6), (6,7), (5,5), (6,6)
        ld b, 7
        ld c, 7
        ld a, PLAYER2
        call set_cell

        ld b, 7
        ld c, 6
        ld a, PLAYER2
        call set_cell

        ld b, 6
        ld c, 7
        ld a, PLAYER2
        call set_cell

        ld b, 6
        ld c, 6
        ld a, PLAYER2
        call set_cell

        ld b, 5
        ld c, 5
        ld a, PLAYER2
        call set_cell

forever:
        jr forever

; =============================================================================
; SUBROUTINES
; =============================================================================

; -----------------------------------------------------------------------------
; Set a cell to a player's colour
; Input: B = board row (0-7), C = board column (0-7), A = player (0/1/2)
; -----------------------------------------------------------------------------
set_cell:
        push af             ; Save player value

        ; Calculate attribute address
        ; Screen row = BOARD_TOP + B
        ; Screen column = BOARD_LEFT + C
        ; Address = $5800 + (screen_row × 32) + screen_column

        ; Calculate screen row
        ld a, BOARD_TOP
        add a, b            ; A = screen row

        ; Multiply by 32 (shift left 5 times)
        ld l, a
        ld h, 0             ; HL = screen row
        add hl, hl          ; ×2
        add hl, hl          ; ×4
        add hl, hl          ; ×8
        add hl, hl          ; ×16
        add hl, hl          ; ×32

        ; Add screen column
        ld a, BOARD_LEFT
        add a, c            ; A = screen column
        ld e, a
        ld d, 0
        add hl, de          ; HL = (row × 32) + column

        ; Add attribute base address
        ld de, ATTR_START
        add hl, de          ; HL = final attribute address

        ; Get colour for this player
        pop af              ; Restore player value
        call get_player_colour

        ; Write to screen
        ld (hl), a

        ret

; -----------------------------------------------------------------------------
; Get the attribute colour for a player
; Input: A = player (0=empty, 1=player1, 2=player2)
; Output: A = attribute byte
; -----------------------------------------------------------------------------
get_player_colour:
        cp EMPTY
        jr nz, not_empty
        ld a, EMPTY_ATTR
        ret
not_empty:
        cp PLAYER1
        jr nz, not_p1
        ld a, P1_ATTR
        ret
not_p1:
        ld a, P2_ATTR
        ret

; -----------------------------------------------------------------------------
; Clear entire screen to black
; -----------------------------------------------------------------------------
clear_screen:
        ld hl, ATTR_START
        ld de, ATTR_START + 1
        ld bc, ATTR_SIZE - 1
        ld (hl), BLACK_ATTR
        ldir
        ret

; -----------------------------------------------------------------------------
; Draw the border frame
; -----------------------------------------------------------------------------
draw_border:
        ld a, BORDER_ATTR

        ; Top row
        ld hl, ATTR_START + (BORDER_TOP * ATTR_WIDTH) + BORDER_LEFT
        ld b, BORDER_SIZE
border_top:
        ld (hl), a
        inc hl
        djnz border_top

        ; Bottom row
        ld hl, ATTR_START + ((BORDER_TOP + BORDER_SIZE - 1) * ATTR_WIDTH) + BORDER_LEFT
        ld b, BORDER_SIZE
border_bottom:
        ld (hl), a
        inc hl
        djnz border_bottom

        ; Left and right sides
        ld hl, ATTR_START + ((BORDER_TOP + 1) * ATTR_WIDTH) + BORDER_LEFT
        ld b, BORDER_SIZE - 2
border_sides:
        push bc
        push hl
        ld (hl), a              ; Left
        ld de, BORDER_SIZE - 1
        add hl, de
        ld (hl), a              ; Right
        pop hl
        ld de, ATTR_WIDTH
        add hl, de
        pop bc
        djnz border_sides

        ret

; -----------------------------------------------------------------------------
; Fill board with empty cells
; -----------------------------------------------------------------------------
draw_board:
        ld hl, ATTR_START + (BOARD_TOP * ATTR_WIDTH) + BOARD_LEFT
        ld c, BOARD_SIZE        ; Row counter

draw_board_row:
        push hl
        ld b, BOARD_SIZE        ; Column counter
        ld a, EMPTY_ATTR

draw_board_col:
        ld (hl), a
        inc hl
        djnz draw_board_col

        pop hl
        ld de, ATTR_WIDTH
        add hl, de
        dec c
        jr nz, draw_board_row

        ret

        end start
