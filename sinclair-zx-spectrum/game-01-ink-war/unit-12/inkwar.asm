; Ink War - Unit 12: Determining the Winner
; Compare scores and announce the winner
;
; Learning objectives:
; - Compare final scores
; - Determine winner or draw
; - Display winner announcement
; - Celebrate victory visually

        org $8000

; =============================================================================
; CONSTANTS
; =============================================================================

SCREEN_START equ $4000
ATTR_START  equ $5800
ATTR_WIDTH  equ 32
ATTR_SIZE   equ 768

BOARD_SIZE  equ 8
BOARD_TOP   equ 8
BOARD_LEFT  equ 12
BORDER_TOP  equ 7
BORDER_LEFT equ 11
BORDER_SIZE equ 10

BORDER_PORT equ $FE
KEYBOARD_PORT equ $FE

ROW_A_G     equ $FD
ROW_Q_T     equ $FB
ROW_P_Y     equ $DF
ROW_SPC_B   equ $7F

EMPTY       equ 0
PLAYER1     equ 1
PLAYER2     equ 2

BLACK_ATTR  equ %00000000
WHITE_ATTR  equ %00111111
EMPTY_ATTR  equ %00111000
P1_ATTR     equ %01010000
P2_ATTR     equ %01001000

INDICATOR_ROW equ 2
INDICATOR_COL equ 12

; Score display positions
SCORE_ROW   equ 4           ; Row for score display
P1_LABEL_COL equ 2          ; "P1:" label
P1_SCORE_COL equ 5          ; Score value
P2_LABEL_COL equ 26         ; "P2:" label
P2_SCORE_COL equ 29         ; Score value

; Winner message position
WINNER_ROW  equ 20          ; Row for winner message
WINNER_COL  equ 11          ; Starting column

; ROM character set location
CHAR_ROM    equ $3D00       ; Character set in ROM

; Game states
STATE_PLAYING   equ 0
STATE_GAME_OVER equ 1

TOTAL_CELLS equ 64          ; 8x8 board

; Winner codes
WINNER_P1   equ 1
WINNER_P2   equ 2
WINNER_DRAW equ 0

; =============================================================================
; VARIABLES
; =============================================================================

cursor_row:     defb 0
cursor_col:     defb 0
prev_keys:      defb 0
current_player: defb PLAYER1
p1_score:       defb 0      ; Player 1 cell count
p2_score:       defb 0      ; Player 2 cell count
game_state:     defb STATE_PLAYING
winner:         defb 0      ; Who won (0=draw, 1=P1, 2=P2)

; Scratch variables for number printing
tens_digit:     defb 0
units_digit:    defb 0
print_row:      defb 0
print_col:      defb 0

board_state:    defs 64, 0

; =============================================================================
; MESSAGES
; =============================================================================

msg_red_wins:   defb "RED WINS!", 0
msg_blu_wins:   defb "BLU WINS!", 0
msg_draw:       defb "  DRAW!  ", 0

; =============================================================================
; MAIN PROGRAM
; =============================================================================

start:
        xor a
        out (BORDER_PORT), a

        call clear_screen
        call clear_pixels
        call draw_border
        call draw_board
        call draw_turn_indicator
        call draw_scores        ; Initial score display

        ld a, 3
        ld (cursor_row), a
        ld (cursor_col), a
        call draw_cursor

main_loop:
        halt

        ; Check game state
        ld a, (game_state)
        cp STATE_GAME_OVER
        jr z, game_over_loop

        ; Still playing - process input
        call read_keys
        call move_cursor
        call check_claim
        jr main_loop

game_over_loop:
        ; Flash the border in winner's colour
        call flash_winner_border
        jr main_loop

; =============================================================================
; WINNER DETERMINATION
; =============================================================================

; -----------------------------------------------------------------------------
; Determine who won and display the result
; Called when game ends
; -----------------------------------------------------------------------------
determine_winner:
        ; Compare scores
        ld a, (p1_score)
        ld b, a
        ld a, (p2_score)

        ; Compare P1 vs P2
        cp b                ; A (P2) - B (P1)
        jr z, result_draw   ; Equal - draw
        jr c, result_p1     ; P2 < P1 - P1 wins
                            ; Otherwise P2 > P1 - P2 wins

result_p2:
        ld a, WINNER_P2
        ld (winner), a
        ld hl, msg_blu_wins
        ld a, %00000101     ; Cyan ink for message
        jr show_winner

result_p1:
        ld a, WINNER_P1
        ld (winner), a
        ld hl, msg_red_wins
        ld a, %00000010     ; Red ink for message
        jr show_winner

result_draw:
        ld a, WINNER_DRAW
        ld (winner), a
        ld hl, msg_draw
        ld a, %00000111     ; White ink for message

show_winner:
        push hl             ; Save message pointer
        push af             ; Save colour

        ; Set attributes for message area
        ld hl, ATTR_START + (WINNER_ROW * ATTR_WIDTH) + WINNER_COL
        pop af              ; Get colour
        push af             ; Keep for later
        ld b, 9             ; Message length
set_msg_attr:
        ld (hl), a
        inc hl
        djnz set_msg_attr

        ; Print the message
        pop af              ; Discard colour
        pop hl              ; Get message pointer
        ld b, WINNER_ROW
        ld c, WINNER_COL
        call print_string

        ret

; -----------------------------------------------------------------------------
; Print a null-terminated string
; Input: HL = string pointer, B = row, C = column
; -----------------------------------------------------------------------------
print_string:
        ld a, (hl)
        or a                ; Check for null terminator
        ret z

        push hl
        push bc
        call print_char
        pop bc
        pop hl

        inc hl              ; Next character
        inc c               ; Next column
        jr print_string

; -----------------------------------------------------------------------------
; Flash border in winner's colour
; Called repeatedly in game over loop
; -----------------------------------------------------------------------------
flash_winner_border:
        ld a, (winner)
        or a
        jr z, flash_white   ; Draw = white flash

        cp WINNER_P1
        jr z, flash_red

flash_blue:
        ld a, 5             ; Cyan
        jr do_flash

flash_red:
        ld a, 2             ; Red
        jr do_flash

flash_white:
        ld a, 7             ; White

do_flash:
        out (BORDER_PORT), a
        call short_delay

        xor a               ; Black
        out (BORDER_PORT), a
        call short_delay

        ret

; =============================================================================
; GAME END DETECTION
; =============================================================================

; -----------------------------------------------------------------------------
; Check if the game has ended (all cells filled)
; -----------------------------------------------------------------------------
check_game_end:
        ; Count empty cells
        ld hl, board_state
        ld bc, TOTAL_CELLS
        ld d, 0             ; Empty cell counter

check_end_loop:
        ld a, (hl)
        or a
        jr nz, cell_not_empty
        inc d               ; Found an empty cell

cell_not_empty:
        inc hl
        dec bc
        ld a, b
        or c
        jr nz, check_end_loop

        ; D now contains count of empty cells
        ld a, d
        or a                ; Any empty cells left?
        ret nz              ; Yes - game continues

        ; No empty cells - game is over!
        ld a, STATE_GAME_OVER
        ld (game_state), a

        ; Clear the turn indicator
        call clear_turn_indicator

        ; Determine and display the winner
        call determine_winner

        ret

; -----------------------------------------------------------------------------
; Clear turn indicator when game ends
; -----------------------------------------------------------------------------
clear_turn_indicator:
        ld hl, ATTR_START + (INDICATOR_ROW * ATTR_WIDTH) + INDICATOR_COL
        ld b, 8
        ld a, BLACK_ATTR
clear_ind_loop:
        ld (hl), a
        inc hl
        djnz clear_ind_loop
        ret

; =============================================================================
; SCORE ROUTINES
; =============================================================================

; -----------------------------------------------------------------------------
; Count cells and update score variables
; -----------------------------------------------------------------------------
count_cells:
        ld hl, board_state
        ld bc, 64           ; 64 cells to check
        ld d, 0             ; P1 count
        ld e, 0             ; P2 count

count_loop:
        ld a, (hl)
        or a
        jr z, count_next    ; Empty - skip

        cp PLAYER1
        jr nz, count_p2
        inc d               ; P1 cell
        jr count_next
count_p2:
        inc e               ; P2 cell

count_next:
        inc hl
        dec bc
        ld a, b
        or c
        jr nz, count_loop

        ; Store results
        ld a, d
        ld (p1_score), a
        ld a, e
        ld (p2_score), a
        ret

; -----------------------------------------------------------------------------
; Draw scores on screen
; Uses direct screen memory writes
; -----------------------------------------------------------------------------
draw_scores:
        ; Count cells first
        call count_cells

        ; Set up attributes for score area
        call setup_score_area

        ; Print "P1:" label
        ld b, SCORE_ROW
        ld c, P1_LABEL_COL
        ld a, 'P'
        call print_char
        ld b, SCORE_ROW
        ld c, P1_LABEL_COL + 1
        ld a, '1'
        call print_char
        ld b, SCORE_ROW
        ld c, P1_LABEL_COL + 2
        ld a, ':'
        call print_char

        ; Print P1 score (two digits)
        ld a, (p1_score)
        ld b, SCORE_ROW
        ld c, P1_SCORE_COL
        call print_two_digit

        ; Print "P2:" label
        ld b, SCORE_ROW
        ld c, P2_LABEL_COL
        ld a, 'P'
        call print_char
        ld b, SCORE_ROW
        ld c, P2_LABEL_COL + 1
        ld a, '2'
        call print_char
        ld b, SCORE_ROW
        ld c, P2_LABEL_COL + 2
        ld a, ':'
        call print_char

        ; Print P2 score (two digits)
        ld a, (p2_score)
        ld b, SCORE_ROW
        ld c, P2_SCORE_COL
        call print_two_digit

        ret

; -----------------------------------------------------------------------------
; Print two-digit number (0-64)
; Input: A = number, B = row, C = starting column
; -----------------------------------------------------------------------------
print_two_digit:
        ; Save position
        ld (print_row), a       ; Temporarily store number here
        ld a, b
        ld (units_digit), a     ; Row in units_digit temporarily
        ld a, c
        ld (tens_digit), a      ; Column in tens_digit temporarily

        ; Now calculate actual digits
        ld a, (print_row)       ; Get number back
        ld b, 0                 ; Tens counter

        cp 10
        jr c, td_no_tens

td_calc_tens:
        sub 10
        inc b
        cp 10
        jr nc, td_calc_tens

td_no_tens:
        ; B = tens digit, A = units digit
        ld (print_col), a       ; Save units in print_col temporarily
        ld a, b
        ld (print_row), a       ; Save tens in print_row

        ; Restore position from our temp storage
        ld a, (units_digit)     ; Row
        ld b, a
        ld a, (tens_digit)      ; Column
        ld c, a

        ; Print tens digit (or space if zero)
        ld a, (print_row)       ; Get tens
        or a
        jr z, td_space

        add a, '0'
        call print_char
        jr td_units

td_space:
        ld a, ' '
        call print_char

td_units:
        ; Print units digit
        ld a, (units_digit)     ; Row
        ld b, a
        ld a, (tens_digit)      ; Column
        inc a                   ; Next column
        ld c, a

        ld a, (print_col)       ; Get units
        add a, '0'
        call print_char

        ret

; -----------------------------------------------------------------------------
; Print a single character to screen
; Input: A = ASCII character, B = row (0-23), C = column (0-31)
; Uses ROM character set at $3D00
; -----------------------------------------------------------------------------
print_char:
        push af             ; Save character
        push bc             ; Save row/col

        ; Calculate screen address for character row B, column C
        ; High byte: $40 + (row/8)*8
        ld a, b             ; Get row
        and %00011000       ; Keep (row/8)*8 in bits 3-4
        or %01000000        ; Add $40 base
        ld h, a

        ; Low byte: (row%8)*32 + column
        ld a, b             ; Get row again
        and %00000111       ; row % 8
        rrca                ; Shift to bits 5-7
        rrca
        rrca                ; Now in bits 5,6,7
        or c                ; Add column
        ld l, a

        ; HL now points to first pixel line of character cell
        pop bc              ; Restore row/col
        pop af              ; Get character back
        push hl             ; Save screen address

        ; Character address = $3D00 + (char - 32) * 8
        sub 32              ; Characters start at space (32)
        ld l, a
        ld h, 0
        add hl, hl          ; * 2
        add hl, hl          ; * 4
        add hl, hl          ; * 8
        ld de, CHAR_ROM
        add hl, de          ; HL = character data address

        ex de, hl           ; DE = char data
        pop hl              ; HL = screen address

        ; Copy 8 bytes (8 pixel lines of character)
        ld b, 8
print_char_loop:
        ld a, (de)
        ld (hl), a
        inc de
        inc h               ; Next pixel line (add $100)
        djnz print_char_loop

        ret

; -----------------------------------------------------------------------------
; Set up attributes for score area
; -----------------------------------------------------------------------------
setup_score_area:
        ; P1 score area - red on black
        ld hl, ATTR_START + (SCORE_ROW * ATTR_WIDTH) + P1_LABEL_COL
        ld a, %00000010     ; Black paper, red ink
        ld b, 5             ; "P1:XX" = 5 chars
p1_attr_loop:
        ld (hl), a
        inc hl
        djnz p1_attr_loop

        ; P2 score area - cyan on black
        ld hl, ATTR_START + (SCORE_ROW * ATTR_WIDTH) + P2_LABEL_COL
        ld a, %00000101     ; Black paper, cyan ink
        ld b, 5             ; "P2:XX" = 5 chars
p2_attr_loop:
        ld (hl), a
        inc hl
        djnz p2_attr_loop

        ret

; =============================================================================
; PIXEL CLEAR (for characters)
; =============================================================================

clear_pixels:
        ld hl, SCREEN_START
        ld de, SCREEN_START + 1
        ld bc, 6143
        ld (hl), 0
        ldir
        ret

; =============================================================================
; MOVE VALIDATION
; =============================================================================

check_claim:
        bit 4, d
        ret z

        call get_board_state_address
        ld a, (hl)
        or a
        jr nz, invalid_move

        call valid_move
        ret

invalid_move:
        call play_error_sound
        ld a, 2
        out (BORDER_PORT), a
        call short_delay
        call short_delay
        xor a
        out (BORDER_PORT), a
        ret

valid_move:
        call get_board_state_address
        ld a, (current_player)
        ld (hl), a
        call update_cell_display
        call play_success_sound
        ld a, 4
        out (BORDER_PORT), a
        call short_delay
        xor a
        out (BORDER_PORT), a

        ; Update scores after claim
        call draw_scores

        ; Check if game has ended
        call check_game_end

        ; If game over, don't switch players
        ld a, (game_state)
        cp STATE_GAME_OVER
        ret z

        call switch_player
        ret

get_board_state_address:
        ld a, (cursor_row)
        add a, a
        add a, a
        add a, a
        ld hl, board_state
        ld e, a
        ld d, 0
        add hl, de
        ld a, (cursor_col)
        ld e, a
        ld d, 0
        add hl, de
        ret

; =============================================================================
; SOUND ROUTINES
; =============================================================================

play_success_sound:
        ld hl, 200
        ld b, 3
success_loop:
        push bc
        push hl
        ld de, 150
        call beep
        pop hl
        ld bc, 30
        or a
        sbc hl, bc
        pop bc
        djnz success_loop
        ret

play_error_sound:
        ld hl, 800
        ld de, 300
        call beep
        ret

beep:
beep_loop:
        ld a, 16
        out (BORDER_PORT), a
        ld b, l
pitch_high:
        djnz pitch_high
        xor a
        out (BORDER_PORT), a
        ld b, l
pitch_low:
        djnz pitch_low
        dec de
        ld a, d
        or e
        jr nz, beep_loop
        ret

; =============================================================================
; TURN SYSTEM
; =============================================================================

switch_player:
        ld a, (current_player)
        ld b, a
        ld a, 3
        sub b
        ld (current_player), a
        call draw_turn_indicator
        call draw_cursor
        ret

draw_turn_indicator:
        ld hl, ATTR_START + (INDICATOR_ROW * ATTR_WIDTH) + INDICATOR_COL
        ld b, 8
        ld a, BLACK_ATTR
clear_ind:
        ld (hl), a
        inc hl
        djnz clear_ind
        ld hl, ATTR_START + (INDICATOR_ROW * ATTR_WIDTH) + INDICATOR_COL
        ld a, (current_player)
        cp PLAYER1
        jr nz, ind_p2
        ld a, P1_ATTR
        jr draw_ind
ind_p2:
        ld a, P2_ATTR
draw_ind:
        ld b, 8
ind_loop:
        ld (hl), a
        inc hl
        djnz ind_loop
        ret

; =============================================================================
; DISPLAY ROUTINES
; =============================================================================

update_cell_display:
        ld a, (cursor_row)
        ld b, a
        ld a, (cursor_col)
        ld c, a
        call get_cell_address
        ld a, (current_player)
        cp PLAYER1
        jr nz, disp_p2
        ld a, P1_ATTR
        jr disp_done
disp_p2:
        ld a, P2_ATTR
disp_done:
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
        push hl
        call get_board_state
        pop hl
        or a
        jr z, cursor_empty
        ld a, (hl)
        or %10000000
        ld (hl), a
        ret
cursor_empty:
        ld a, (current_player)
        cp PLAYER1
        jr nz, cursor_p2
        ld a, P1_ATTR
        jr cursor_flash
cursor_p2:
        ld a, P2_ATTR
cursor_flash:
        or %10000000
        ld (hl), a
        ret

erase_cursor:
        ld a, (cursor_row)
        ld b, a
        ld a, (cursor_col)
        ld c, a
        call get_cell_address
        push hl
        call get_board_state
        pop hl
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

get_board_state:
        ld a, (cursor_row)
        add a, a
        add a, a
        add a, a
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
