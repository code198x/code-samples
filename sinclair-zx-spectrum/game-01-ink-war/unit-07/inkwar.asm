; Ink War - Unit 07: Claiming Cells
; Press Space to claim the current cell for the current player
;
; Learning objectives:
; - Track board state in memory (who owns each cell)
; - Detect Space key for claiming
; - Check if cell is empty before claiming
; - Update both memory state and display

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
KEYBOARD_PORT equ $FE

; Keyboard half-rows
ROW_A_G     equ $FD
ROW_Q_T     equ $FB
ROW_P_Y     equ $DF
ROW_SPC_B   equ $7F

; Cell states
EMPTY       equ 0
PLAYER1     equ 1
PLAYER2     equ 2

; Colours
BLACK_ATTR  equ %00000000
WHITE_ATTR  equ %00111111
EMPTY_ATTR  equ %00111000   ; White paper, black ink
CURSOR_ATTR equ %01110000   ; Bright yellow paper
P1_ATTR     equ %01010000   ; Bright red paper
P2_ATTR     equ %01001000   ; Bright blue paper

; =============================================================================
; VARIABLES
; =============================================================================

cursor_row:     defb 0
cursor_col:     defb 0
prev_keys:      defb 0
current_player: defb PLAYER1    ; Start with Player 1

; Board state: 64 bytes, one per cell
; 0 = empty, 1 = player 1, 2 = player 2
board_state:    defs 64, 0      ; Initialise all to empty

; =============================================================================
; MAIN PROGRAM
; =============================================================================

start:
        xor a
        out (BORDER_PORT), a

        call clear_screen
        call draw_border
        call draw_board

        ; Start cursor at centre
        ld a, 3
        ld (cursor_row), a
        ld (cursor_col), a
        call draw_cursor

main_loop:
        halt

        call read_keys          ; D = newly pressed keys
        call move_cursor
        call check_claim        ; Check for Space press

        jr main_loop

; =============================================================================
; CLAIM ROUTINES
; =============================================================================

; -----------------------------------------------------------------------------
; Check if Space was pressed and try to claim the cell
; Input: D = newly pressed keys (bit 4 = Space)
; -----------------------------------------------------------------------------
check_claim:
        bit 4, d                ; Space pressed?
        ret z                   ; No? Return

        ; Get board state index: row × 8 + column
        ld a, (cursor_row)
        add a, a                ; ×2
        add a, a                ; ×4
        add a, a                ; ×8
        ld hl, board_state
        ld e, a
        ld d, 0
        add hl, de              ; HL = board_state + (row × 8)

        ld a, (cursor_col)
        ld e, a
        ld d, 0
        add hl, de              ; HL = board_state + (row × 8) + col

        ; Check if cell is empty
        ld a, (hl)
        or a                    ; Is it 0 (empty)?
        jr nz, cell_occupied    ; Not empty - can't claim

        ; Cell is empty - claim it!
        ld a, (current_player)
        ld (hl), a              ; Store player in board state

        ; Update display
        call update_cell_display

        ; Flash border green to confirm
        ld a, 4                 ; Green
        out (BORDER_PORT), a
        call short_delay
        xor a
        out (BORDER_PORT), a

        ret

cell_occupied:
        ; Can't claim - flash border red
        ld a, 2                 ; Red
        out (BORDER_PORT), a
        call short_delay
        xor a
        out (BORDER_PORT), a
        ret

; -----------------------------------------------------------------------------
; Update the display for the cell at cursor position
; Shows the current player's colour
; -----------------------------------------------------------------------------
update_cell_display:
        ld a, (cursor_row)
        ld b, a
        ld a, (cursor_col)
        ld c, a
        call get_cell_address   ; HL = attribute address

        ; Get colour for current player
        ld a, (current_player)
        cp PLAYER1
        jr nz, is_player2
        ld a, P1_ATTR           ; Red
        jr store_colour
is_player2:
        ld a, P2_ATTR           ; Blue
store_colour:
        ld (hl), a
        ret

; =============================================================================
; CURSOR ROUTINES
; =============================================================================

draw_cursor:
        ld a, (cursor_row)
        ld b, a
        ld a, (cursor_col)
        ld c, a
        call get_cell_address

        ; Check if cell is claimed
        push hl
        call get_board_state    ; A = state of this cell
        pop hl
        or a
        jr z, cursor_on_empty

        ; Cell is claimed - use FLASH to show cursor
        ld a, (hl)              ; Get current colour
        or %10000000            ; Add FLASH bit
        ld (hl), a
        ret

cursor_on_empty:
        ld a, CURSOR_ATTR       ; Yellow for empty cells
        ld (hl), a
        ret

erase_cursor:
        ld a, (cursor_row)
        ld b, a
        ld a, (cursor_col)
        ld c, a
        call get_cell_address

        ; Restore cell to its actual colour based on state
        push hl
        call get_board_state
        pop hl

        ; Convert state to colour
        or a
        jr nz, erase_claimed
        ld a, EMPTY_ATTR
        jr erase_done
erase_claimed:
        cp PLAYER1
        jr nz, erase_p2
        ld a, P1_ATTR
        jr erase_done
erase_p2:
        ld a, P2_ATTR
erase_done:
        ld (hl), a
        ret

; -----------------------------------------------------------------------------
; Get board state for cell at cursor position
; Output: A = state (0/1/2)
; -----------------------------------------------------------------------------
get_board_state:
        ld a, (cursor_row)
        add a, a
        add a, a
        add a, a                ; ×8
        ld hl, board_state
        ld e, a
        ld d, 0
        add hl, de
        ld a, (cursor_col)
        ld e, a
        ld d, 0
        add hl, de
        ld a, (hl)
        ret

get_cell_address:
        ld a, BOARD_TOP
        add a, b
        ld l, a
        ld h, 0
        add hl, hl
        add hl, hl
        add hl, hl
        add hl, hl
        add hl, hl
        ld a, BOARD_LEFT
        add a, c
        ld e, a
        ld d, 0
        add hl, de
        ld de, ATTR_START
        add hl, de
        ret

; =============================================================================
; INPUT ROUTINES
; =============================================================================

read_keys:
        ld e, 0

        ld a, ROW_Q_T
        in a, (KEYBOARD_PORT)
        bit 0, a
        jr nz, not_q
        set 0, e
not_q:
        ld a, ROW_A_G
        in a, (KEYBOARD_PORT)
        bit 0, a
        jr nz, not_a
        set 1, e
not_a:
        ld a, ROW_P_Y
        in a, (KEYBOARD_PORT)
        bit 1, a
        jr nz, not_o
        set 2, e
not_o:
        bit 0, a
        jr nz, not_p
        set 3, e
not_p:
        ld a, ROW_SPC_B
        in a, (KEYBOARD_PORT)
        bit 0, a
        jr nz, not_space
        set 4, e
not_space:
        ld a, (prev_keys)
        cpl
        and e
        ld d, a
        ld a, e
        ld (prev_keys), a
        ret

move_cursor:
        ld a, d
        and %00001111
        ret z

        call erase_cursor

        bit 0, d
        jr z, not_up
        ld a, (cursor_row)
        or a
        jr z, not_up
        dec a
        ld (cursor_row), a
not_up:
        bit 1, d
        jr z, not_down
        ld a, (cursor_row)
        cp BOARD_SIZE - 1
        jr z, not_down
        inc a
        ld (cursor_row), a
not_down:
        bit 2, d
        jr z, not_left
        ld a, (cursor_col)
        or a
        jr z, not_left
        dec a
        ld (cursor_col), a
not_left:
        bit 3, d
        jr z, not_right
        ld a, (cursor_col)
        cp BOARD_SIZE - 1
        jr z, not_right
        inc a
        ld (cursor_col), a
not_right:
        call draw_cursor
        ret

; =============================================================================
; UTILITY ROUTINES
; =============================================================================

short_delay:
        ld bc, $0800
delay_loop:
        dec bc
        ld a, b
        or c
        jr nz, delay_loop
        ret

clear_screen:
        ld hl, ATTR_START
        ld de, ATTR_START + 1
        ld bc, ATTR_SIZE - 1
        ld (hl), BLACK_ATTR
        ldir
        ret

draw_border:
        ld a, WHITE_ATTR
        ld hl, ATTR_START + (BORDER_TOP * ATTR_WIDTH) + BORDER_LEFT
        ld b, BORDER_SIZE
border_top:
        ld (hl), a
        inc hl
        djnz border_top
        ld hl, ATTR_START + ((BORDER_TOP + BORDER_SIZE - 1) * ATTR_WIDTH) + BORDER_LEFT
        ld b, BORDER_SIZE
border_bottom:
        ld (hl), a
        inc hl
        djnz border_bottom
        ld hl, ATTR_START + ((BORDER_TOP + 1) * ATTR_WIDTH) + BORDER_LEFT
        ld b, BORDER_SIZE - 2
border_sides:
        push bc
        push hl
        ld (hl), a
        ld de, BORDER_SIZE - 1
        add hl, de
        ld (hl), a
        pop hl
        ld de, ATTR_WIDTH
        add hl, de
        pop bc
        djnz border_sides
        ret

draw_board:
        ld hl, ATTR_START + (BOARD_TOP * ATTR_WIDTH) + BOARD_LEFT
        ld c, BOARD_SIZE
draw_board_row:
        push hl
        ld b, BOARD_SIZE
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
