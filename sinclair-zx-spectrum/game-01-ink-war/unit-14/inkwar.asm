; Ink War - Unit 14: Results Screen
; Dedicated results screen with scores and win margin
;
; Learning objectives:
; - Create proper results display
; - Show final scores clearly
; - Display winner prominently
; - Calculate and show win margin

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
SCORE_ROW   equ 4
P1_LABEL_COL equ 2
P1_SCORE_COL equ 5
P2_LABEL_COL equ 26
P2_SCORE_COL equ 29

; Winner message position
WINNER_ROW  equ 20
WINNER_COL  equ 11

; Title screen positions
TITLE_ROW   equ 8
TITLE_COL   equ 12
PROMPT_ROW  equ 14
PROMPT_COL  equ 7

; Results screen positions
RESULT_WINNER_ROW equ 6
RESULT_WINNER_COL equ 11
RESULT_SCORES_ROW equ 12
RESULT_P1_COL     equ 8
RESULT_P2_COL     equ 18
RESULT_MARGIN_ROW equ 16
RESULT_MARGIN_COL equ 9
RESULT_PROMPT_ROW equ 20
RESULT_PROMPT_COL equ 9

; ROM character set location
CHAR_ROM    equ $3D00

; Game states
STATE_TITLE   equ 0
STATE_PLAYING equ 1
STATE_RESULTS equ 2

TOTAL_CELLS equ 64

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
p1_score:       defb 0
p2_score:       defb 0
game_state:     defb STATE_TITLE  ; Start at title screen
winner:         defb 0

; Scratch variables for number printing
tens_digit:     defb 0
units_digit:    defb 0
print_row:      defb 0
print_col:      defb 0

board_state:    defs 64, 0

; =============================================================================
; MESSAGES
; =============================================================================

msg_title:      defb "INK WAR", 0
msg_prompt:     defb "PRESS ANY KEY TO START", 0
msg_red_wins:   defb "RED WINS!", 0
msg_blu_wins:   defb "BLU WINS!", 0
msg_draw:       defb "  DRAW!  ", 0
msg_again:      defb "PRESS ANY KEY", 0
msg_red:        defb "RED:", 0
msg_blu:        defb "BLU:", 0
msg_won_by:     defb "WON BY", 0
msg_cells:      defb "CELLS", 0
msg_tied:       defb "TIED AT 32 EACH!", 0

; Results variables
win_margin:     defb 0

; =============================================================================
; MAIN PROGRAM
; =============================================================================

start:
        xor a
        out (BORDER_PORT), a

        ; Draw initial title screen
        call enter_title_state

main_loop:
        halt

        ; Dispatch based on game state
        ld a, (game_state)

        cp STATE_TITLE
        jr z, handle_title

        cp STATE_PLAYING
        jr z, handle_playing

        cp STATE_RESULTS
        jr z, handle_results

        ; Default: go to title
        call enter_title_state
        jr main_loop

; =============================================================================
; STATE HANDLERS
; =============================================================================

; -----------------------------------------------------------------------------
; Title state - wait for any key to start
; -----------------------------------------------------------------------------
handle_title:
        call wait_any_key
        call enter_playing_state
        jr main_loop

; -----------------------------------------------------------------------------
; Playing state - normal game loop
; -----------------------------------------------------------------------------
handle_playing:
        call read_keys
        call move_cursor
        call check_claim
        jr main_loop

; -----------------------------------------------------------------------------
; Results state - show winner, wait for key
; -----------------------------------------------------------------------------
handle_results:
        call flash_winner_border
        call check_any_key
        jr z, main_loop      ; No key - keep flashing

        ; Key pressed - return to title
        call enter_title_state
        jr main_loop

; =============================================================================
; STATE TRANSITIONS
; =============================================================================

; -----------------------------------------------------------------------------
; Enter title state
; -----------------------------------------------------------------------------
enter_title_state:
        ld a, STATE_TITLE
        ld (game_state), a

        call clear_screen
        call clear_pixels

        ; Draw title
        call setup_title_attrs
        ld hl, msg_title
        ld b, TITLE_ROW
        ld c, TITLE_COL
        call print_string

        ; Draw prompt
        call setup_prompt_attrs
        ld hl, msg_prompt
        ld b, PROMPT_ROW
        ld c, PROMPT_COL
        call print_string

        ret

; -----------------------------------------------------------------------------
; Enter playing state
; -----------------------------------------------------------------------------
enter_playing_state:
        ld a, STATE_PLAYING
        ld (game_state), a

        ; Reset game variables
        call reset_game

        ; Draw game screen
        call clear_screen
        call clear_pixels
        call draw_border
        call draw_board
        call draw_turn_indicator
        call draw_scores

        ; Set initial cursor position
        ld a, 3
        ld (cursor_row), a
        ld (cursor_col), a
        call draw_cursor

        ret

; -----------------------------------------------------------------------------
; Enter results state
; -----------------------------------------------------------------------------
enter_results_state:
        ld a, STATE_RESULTS
        ld (game_state), a

        ; Calculate winner and margin
        call calculate_results

        ; Draw dedicated results screen
        call clear_screen
        call clear_pixels
        call draw_results_screen

        ; Clear prev_keys to avoid instant transition
        xor a
        ld (prev_keys), a

        ret

; -----------------------------------------------------------------------------
; Calculate results - winner and margin
; -----------------------------------------------------------------------------
calculate_results:
        ld a, (p1_score)
        ld b, a
        ld a, (p2_score)

        cp b
        jr z, calc_draw
        jr c, calc_p1_wins

        ; P2 wins
        ld c, WINNER_P2
        sub b               ; margin = p2_score - p1_score
        jr calc_store

calc_p1_wins:
        ld c, WINNER_P1
        ld a, b
        ld b, a
        ld a, (p2_score)
        ld d, a
        ld a, b
        sub d               ; margin = p1_score - p2_score
        jr calc_store

calc_draw:
        ld c, WINNER_DRAW
        xor a               ; margin = 0

calc_store:
        ld (win_margin), a
        ld a, c
        ld (winner), a
        ret

; -----------------------------------------------------------------------------
; Draw the results screen
; -----------------------------------------------------------------------------
draw_results_screen:
        ; Draw winner message at top
        call draw_winner_message

        ; Draw scores
        call draw_result_scores

        ; Draw win margin (or tied message)
        call draw_margin_message

        ; Draw "press any key" prompt
        call draw_result_prompt

        ret

draw_winner_message:
        ld a, (winner)
        or a
        jr z, draw_draw_msg

        cp WINNER_P1
        jr z, draw_p1_wins

        ; P2 wins - cyan
        ld hl, msg_blu_wins
        ld a, %00000101     ; Cyan ink
        jr draw_winner_text

draw_p1_wins:
        ld hl, msg_red_wins
        ld a, %00000010     ; Red ink
        jr draw_winner_text

draw_draw_msg:
        ld hl, msg_draw
        ld a, %00000111     ; White ink

draw_winner_text:
        push hl
        push af

        ; Set attributes for winner row
        ld hl, ATTR_START + (RESULT_WINNER_ROW * ATTR_WIDTH) + RESULT_WINNER_COL
        pop af
        push af
        ld b, 9
set_winner_attr:
        ld (hl), a
        inc hl
        djnz set_winner_attr

        pop af
        pop hl
        ld b, RESULT_WINNER_ROW
        ld c, RESULT_WINNER_COL
        call print_string
        ret

draw_result_scores:
        ; Red score label
        ld hl, ATTR_START + (RESULT_SCORES_ROW * ATTR_WIDTH) + RESULT_P1_COL
        ld a, %00000010     ; Red ink
        ld b, 6
set_p1_score_attr:
        ld (hl), a
        inc hl
        djnz set_p1_score_attr

        ld hl, msg_red
        ld b, RESULT_SCORES_ROW
        ld c, RESULT_P1_COL
        call print_string

        ; Print P1 score
        ld a, (p1_score)
        ld b, RESULT_SCORES_ROW
        ld c, RESULT_P1_COL + 5
        call print_two_digit

        ; Blue score label
        ld hl, ATTR_START + (RESULT_SCORES_ROW * ATTR_WIDTH) + RESULT_P2_COL
        ld a, %00000101     ; Cyan ink
        ld b, 6
set_p2_score_attr:
        ld (hl), a
        inc hl
        djnz set_p2_score_attr

        ld hl, msg_blu
        ld b, RESULT_SCORES_ROW
        ld c, RESULT_P2_COL
        call print_string

        ; Print P2 score
        ld a, (p2_score)
        ld b, RESULT_SCORES_ROW
        ld c, RESULT_P2_COL + 5
        call print_two_digit

        ret

draw_margin_message:
        ld a, (winner)
        or a
        jr z, draw_tied_msg

        ; Set white attributes for margin row
        ld hl, ATTR_START + (RESULT_MARGIN_ROW * ATTR_WIDTH) + RESULT_MARGIN_COL
        ld a, %00000111     ; White ink
        ld b, 14
set_margin_attr:
        ld (hl), a
        inc hl
        djnz set_margin_attr

        ; "WON BY"
        ld hl, msg_won_by
        ld b, RESULT_MARGIN_ROW
        ld c, RESULT_MARGIN_COL
        call print_string

        ; Print margin number
        ld a, (win_margin)
        ld b, RESULT_MARGIN_ROW
        ld c, RESULT_MARGIN_COL + 7
        call print_two_digit

        ; "CELLS"
        ld hl, msg_cells
        ld b, RESULT_MARGIN_ROW
        ld c, RESULT_MARGIN_COL + 10
        call print_string

        ret

draw_tied_msg:
        ; Set white attributes for tied message
        ld hl, ATTR_START + (RESULT_MARGIN_ROW * ATTR_WIDTH) + RESULT_MARGIN_COL - 1
        ld a, %00000111     ; White ink
        ld b, 16
set_tied_attr:
        ld (hl), a
        inc hl
        djnz set_tied_attr

        ld hl, msg_tied
        ld b, RESULT_MARGIN_ROW
        ld c, RESULT_MARGIN_COL - 1
        call print_string
        ret

draw_result_prompt:
        ; Set yellow attributes for prompt
        ld hl, ATTR_START + (RESULT_PROMPT_ROW * ATTR_WIDTH) + RESULT_PROMPT_COL
        ld a, %00000110     ; Yellow ink
        ld b, 13
set_prompt_attr:
        ld (hl), a
        inc hl
        djnz set_prompt_attr

        ld hl, msg_again
        ld b, RESULT_PROMPT_ROW
        ld c, RESULT_PROMPT_COL
        call print_string
        ret

; -----------------------------------------------------------------------------
; Reset game for new play
; -----------------------------------------------------------------------------
reset_game:
        ; Clear board state
        ld hl, board_state
        ld b, 64
        xor a
reset_board:
        ld (hl), a
        inc hl
        djnz reset_board

        ; Reset variables
        ld a, PLAYER1
        ld (current_player), a

        xor a
        ld (p1_score), a
        ld (p2_score), a
        ld (winner), a
        ld (prev_keys), a

        ld a, 3
        ld (cursor_row), a
        ld (cursor_col), a

        ret

; =============================================================================
; KEY HANDLING
; =============================================================================

; -----------------------------------------------------------------------------
; Wait for any key press
; -----------------------------------------------------------------------------
wait_any_key:
        ; Wait for all keys to be released first
wait_release:
        xor a
        in a, (KEYBOARD_PORT)
        cp $FF
        jr nz, wait_release

        ; Now wait for a key press
wait_press:
        halt
        xor a
        in a, (KEYBOARD_PORT)
        cp $FF
        jr z, wait_press

        ret

; -----------------------------------------------------------------------------
; Check if any key is pressed (non-blocking)
; Returns: Z flag set if no key, cleared if key pressed
; -----------------------------------------------------------------------------
check_any_key:
        xor a
        in a, (KEYBOARD_PORT)
        cp $FF
        ret                 ; Z set if $FF (no keys)

; =============================================================================
; TITLE SCREEN ATTRIBUTES
; =============================================================================

setup_title_attrs:
        ; Title in yellow
        ld hl, ATTR_START + (TITLE_ROW * ATTR_WIDTH) + TITLE_COL
        ld a, %00000110     ; Yellow ink
        ld b, 7             ; "INK WAR" = 7 chars
title_attr:
        ld (hl), a
        inc hl
        djnz title_attr
        ret

setup_prompt_attrs:
        ; Prompt in white
        ld hl, ATTR_START + (PROMPT_ROW * ATTR_WIDTH) + PROMPT_COL
        ld a, %00000111     ; White ink
        ld b, 22            ; Message length
prompt_attr:
        ld (hl), a
        inc hl
        djnz prompt_attr
        ret

; =============================================================================
; WINNER DETERMINATION
; =============================================================================

flash_winner_border:
        ld a, (winner)
        or a
        jr z, flash_white

        cp WINNER_P1
        jr z, flash_red

flash_blue:
        ld a, 5
        jr do_flash

flash_red:
        ld a, 2
        jr do_flash

flash_white:
        ld a, 7

do_flash:
        out (BORDER_PORT), a
        call short_delay

        xor a
        out (BORDER_PORT), a
        call short_delay

        ret

; =============================================================================
; GAME END DETECTION
; =============================================================================

check_game_end:
        ld hl, board_state
        ld bc, TOTAL_CELLS
        ld d, 0

check_end_loop:
        ld a, (hl)
        or a
        jr nz, cell_not_empty
        inc d

cell_not_empty:
        inc hl
        dec bc
        ld a, b
        or c
        jr nz, check_end_loop

        ld a, d
        or a
        ret nz

        ; Game over - transition to results
        call clear_turn_indicator
        call enter_results_state

        ret

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

count_cells:
        ld hl, board_state
        ld bc, 64
        ld d, 0
        ld e, 0

count_loop:
        ld a, (hl)
        or a
        jr z, count_next

        cp PLAYER1
        jr nz, count_p2
        inc d
        jr count_next
count_p2:
        inc e

count_next:
        inc hl
        dec bc
        ld a, b
        or c
        jr nz, count_loop

        ld a, d
        ld (p1_score), a
        ld a, e
        ld (p2_score), a
        ret

draw_scores:
        call count_cells
        call setup_score_area

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

        ld a, (p1_score)
        ld b, SCORE_ROW
        ld c, P1_SCORE_COL
        call print_two_digit

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

        ld a, (p2_score)
        ld b, SCORE_ROW
        ld c, P2_SCORE_COL
        call print_two_digit

        ret

print_two_digit:
        ld (print_row), a
        ld a, b
        ld (units_digit), a
        ld a, c
        ld (tens_digit), a

        ld a, (print_row)
        ld b, 0

        cp 10
        jr c, td_no_tens

td_calc_tens:
        sub 10
        inc b
        cp 10
        jr nc, td_calc_tens

td_no_tens:
        ld (print_col), a
        ld a, b
        ld (print_row), a

        ld a, (units_digit)
        ld b, a
        ld a, (tens_digit)
        ld c, a

        ld a, (print_row)
        or a
        jr z, td_space

        add a, '0'
        call print_char
        jr td_units

td_space:
        ld a, ' '
        call print_char

td_units:
        ld a, (units_digit)
        ld b, a
        ld a, (tens_digit)
        inc a
        ld c, a

        ld a, (print_col)
        add a, '0'
        call print_char

        ret

print_string:
        ld a, (hl)
        or a
        ret z

        push hl
        push bc
        call print_char
        pop bc
        pop hl

        inc hl
        inc c
        jr print_string

print_char:
        push af
        push bc

        ld a, b
        and %00011000
        or %01000000
        ld h, a

        ld a, b
        and %00000111
        rrca
        rrca
        rrca
        or c
        ld l, a

        pop bc
        pop af
        push hl

        sub 32
        ld l, a
        ld h, 0
        add hl, hl
        add hl, hl
        add hl, hl
        ld de, CHAR_ROM
        add hl, de

        ex de, hl
        pop hl

        ld b, 8
print_char_loop:
        ld a, (de)
        ld (hl), a
        inc de
        inc h
        djnz print_char_loop

        ret

setup_score_area:
        ld hl, ATTR_START + (SCORE_ROW * ATTR_WIDTH) + P1_LABEL_COL
        ld a, %00000010
        ld b, 5
p1_attr_loop:
        ld (hl), a
        inc hl
        djnz p1_attr_loop

        ld hl, ATTR_START + (SCORE_ROW * ATTR_WIDTH) + P2_LABEL_COL
        ld a, %00000101
        ld b, 5
p2_attr_loop:
        ld (hl), a
        inc hl
        djnz p2_attr_loop

        ret

; =============================================================================
; PIXEL CLEAR
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

        call draw_scores
        call check_game_end

        ld a, (game_state)
        cp STATE_RESULTS
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
