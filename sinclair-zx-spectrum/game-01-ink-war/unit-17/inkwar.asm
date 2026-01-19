; ============================================================================
; INK WAR - Unit 17: Custom Character Set
; ============================================================================
; Enhanced visuals with custom-designed characters for borders and UI.
; Characters are loaded at startup for a more polished appearance.
;
; Phase 2 begins - focusing on visual polish and enhanced features.
;
; Controls: Q=Up, A=Down, O=Left, P=Right, SPACE=Claim
;           1=Two Player, 2=AI Easy, 3=AI Medium, 4=AI Hard
; ============================================================================

            org     32768

; ----------------------------------------------------------------------------
; Constants
; ----------------------------------------------------------------------------

ATTR_BASE   equ     $5800
DISPLAY_FILE equ    $4000
ROM_CHARSET equ     $3D00           ; ROM character set (space onwards)
CHARS_SYSVAR equ    $5C36           ; System variable for charset address

BOARD_ROW   equ     8
BOARD_COL   equ     12
BOARD_SIZE  equ     8

; Display positions
SCORE_ROW   equ     2               ; Score display row
P1_SCORE_COL equ    10              ; "P1: nn" column
P2_SCORE_COL equ    18              ; "P2: nn" column
TURN_ROW    equ     4               ; Turn indicator row
TURN_COL    equ     14              ; Turn indicator column
RESULT_ROW  equ     20              ; Winner message row
RESULT_COL  equ     11              ; Winner message column

; Game constants
TOTAL_CELLS equ     64              ; 8x8 board

; Customised colours (from Unit 3)
EMPTY_ATTR  equ     %01101000       ; Cyan paper + BRIGHT
BORDER_ATTR equ     %01110000       ; Yellow paper + BRIGHT
CURSOR_ATTR equ     %01111000       ; White paper + BRIGHT

P1_ATTR     equ     %01010000       ; Red paper + BRIGHT
P2_ATTR     equ     %01001000       ; Blue paper + BRIGHT
P1_CURSOR   equ     %01111010       ; White paper + Red ink + BRIGHT
P2_CURSOR   equ     %01111001       ; White paper + Blue ink + BRIGHT

; Text display attributes
TEXT_ATTR   equ     %00111000       ; White paper, black ink
P1_TEXT     equ     %01010111       ; Red paper, white ink + BRIGHT
P2_TEXT     equ     %01001111       ; Blue paper, white ink + BRIGHT

P1_BORDER   equ     2
P2_BORDER   equ     1
ERROR_BORDER equ    2               ; Red border for errors

; Keyboard ports
KEY_PORT    equ     $fe
ROW_QAOP    equ     $fb
ROW_ASDF    equ     $fd
ROW_YUIOP   equ     $df
ROW_SPACE   equ     $7f

; Cell states
STATE_EMPTY equ     0
STATE_P1    equ     1
STATE_P2    equ     2

; Game states (state machine)
GS_TITLE    equ     0
GS_PLAYING  equ     1
GS_RESULTS  equ     2

; Game modes
GM_TWO_PLAYER equ   0
GM_VS_AI    equ     1

; AI difficulty levels
AI_EASY     equ     0               ; Random moves
AI_MEDIUM   equ     1               ; Adjacent priority only
AI_HARD     equ     2               ; Full strategy (defense + position)

; AI timing
AI_DELAY    equ     25              ; Frames before AI moves (~0.5 sec)

; Title screen positions
TITLE_ROW   equ     6
TITLE_COL   equ     12              ; "INK WAR" (7 chars) centred
MODE1_ROW   equ     12              ; "1 - TWO PLAYER"
MODE1_COL   equ     9
MODE2_ROW   equ     14              ; "2 - AI EASY"
MODE2_COL   equ     10
MODE3_ROW   equ     16              ; "3 - AI MEDIUM"
MODE3_COL   equ     9
MODE4_ROW   equ     18              ; "4 - AI HARD"
MODE4_COL   equ     10

; Results screen positions
GAMEOVER_ROW equ    18              ; "GAME OVER" header
GAMEOVER_COL equ    11              ; (32-9)/2 = 11.5
FINAL_ROW   equ     20              ; Final score row
FINAL_P1_COL equ    8               ; "P1: nn"
FINAL_P2_COL equ    20              ; "P2: nn"
WINNER_ROW  equ     22              ; Winner announcement
WINNER_COL  equ     10              ; Centred
MARGIN_ROW  equ     23              ; "BY nn CELLS"
MARGIN_COL  equ     11
CONTINUE_ROW equ    22              ; "PRESS ANY KEY" after results
CONTINUE_COL equ    9               ; (32-13)/2 = 9.5

; Input timing
KEY_DELAY   equ     8               ; Frames between key repeats

; Custom character codes (mapped to unused positions)
CHAR_CORNER_TL equ  128             ; Top-left corner
CHAR_CORNER_TR equ  129             ; Top-right corner
CHAR_CORNER_BL equ  130             ; Bottom-left corner
CHAR_CORNER_BR equ  131             ; Bottom-right corner
CHAR_HORIZ     equ  132             ; Horizontal line
CHAR_VERT      equ  133             ; Vertical line

; Video capture mode
VIDEO_MODE  equ     0

; ----------------------------------------------------------------------------
; Entry Point
; ----------------------------------------------------------------------------

start:
            ; Install custom character set
            call    install_charset

            ; Play startup jingle
            call    sound_startup

    IF VIDEO_MODE
            ; VIDEO_MODE: Skip title, start AI Easy game immediately
            ld      a, GM_VS_AI
            ld      (game_mode), a
            ld      a, AI_EASY
            ld      (ai_difficulty), a
            call    start_game
    ELSE
            ; Normal mode: Start at title screen
            ld      a, GS_TITLE
            ld      (game_state), a
            call    init_screen
            call    draw_title_screen

            ; Black border for title
            xor     a
            out     (KEY_PORT), a
    ENDIF

main_loop:
            halt

            ; Dispatch based on game state
            ld      a, (game_state)
            or      a
            jr      z, state_title      ; GS_TITLE = 0
            cp      GS_PLAYING
            jr      z, state_playing
            ; Must be GS_RESULTS - handled inline after game over

            jp      main_loop

; ----------------------------------------------------------------------------
; Install Custom Character Set
; ----------------------------------------------------------------------------
; Copies ROM charset to RAM and adds custom characters for borders/UI

install_charset:
            ; Copy ROM charset (characters 32-127) to our charset area
            ld      hl, ROM_CHARSET
            ld      de, custom_charset
            ld      bc, 768             ; 96 characters * 8 bytes
            ldir

            ; Set CHARS system variable to point to our charset - 256
            ; (CHARS points 256 bytes before first character)
            ld      hl, custom_charset - 256
            ld      (CHARS_SYSVAR), hl

            ret

; ----------------------------------------------------------------------------
; State: Title
; ----------------------------------------------------------------------------
; Waits for 1 (Two Player), 2 (AI Easy), 3 (AI Medium), 4 (AI Hard)

ROW_12345   equ     $f7             ; Keyboard row for 1,2,3,4,5

state_title:
            ; Read keyboard row for keys 1-5
            ld      a, ROW_12345
            in      a, (KEY_PORT)

            ; Check for key 1 (Two Player)
            bit     0, a                ; Key 1
            jr      z, .st_two_player

            ; Check for key 2 (AI Easy)
            bit     1, a                ; Key 2
            jr      z, .st_ai_easy

            ; Check for key 3 (AI Medium)
            bit     2, a                ; Key 3
            jr      z, .st_ai_medium

            ; Check for key 4 (AI Hard)
            bit     3, a                ; Key 4
            jr      z, .st_ai_hard

            jp      main_loop           ; No valid key - keep waiting

.st_two_player:
            call    sound_select
            xor     a                   ; GM_TWO_PLAYER = 0
            ld      (game_mode), a
            call    start_game
            jp      main_loop

.st_ai_easy:
            call    sound_select
            ld      a, GM_VS_AI
            ld      (game_mode), a
            ld      a, AI_EASY
            ld      (ai_difficulty), a
            call    start_game
            jp      main_loop

.st_ai_medium:
            call    sound_select
            ld      a, GM_VS_AI
            ld      (game_mode), a
            ld      a, AI_MEDIUM
            ld      (ai_difficulty), a
            call    start_game
            jp      main_loop

.st_ai_hard:
            call    sound_select
            ld      a, GM_VS_AI
            ld      (game_mode), a
            ld      a, AI_HARD
            ld      (ai_difficulty), a
            call    start_game
            jp      main_loop

; ----------------------------------------------------------------------------
; State: Playing
; ----------------------------------------------------------------------------

state_playing:
            ; Check if AI's turn (Player 2 in vs AI mode)
            ld      a, (game_mode)
            or      a
            jr      z, .sp_human        ; Two player mode - human controls

            ; vs AI mode - check if Player 2's turn
            ld      a, (current_player)
            cp      2
            jr      z, .sp_ai_turn

.sp_human:
            ; Human player's turn
            call    read_keyboard
            call    handle_input
            jp      main_loop

.sp_ai_turn:
            ; AI's turn - use delay counter
            ld      a, (ai_timer)
            or      a
            jr      z, .sp_ai_move      ; Timer expired, make move

            ; Still waiting
            dec     a
            ld      (ai_timer), a
            jp      main_loop

.sp_ai_move:
            ; Reset timer for next AI turn
            ld      a, AI_DELAY
            ld      (ai_timer), a

            ; AI makes a move
            call    ai_make_move
            jp      main_loop

; ----------------------------------------------------------------------------
; Start Game
; ----------------------------------------------------------------------------
; Transitions from title to playing state

start_game:
            ld      a, GS_PLAYING
            ld      (game_state), a

            call    init_screen
            call    init_game
            call    draw_board_border
            call    draw_board
            call    draw_ui
            call    draw_cursor
            call    update_border

            ; Wait for key release before playing
            call    wait_key_release

            ret

; ----------------------------------------------------------------------------
; Initialise Screen
; ----------------------------------------------------------------------------

init_screen:
            xor     a
            out     (KEY_PORT), a

            ; Clear display file (pixels)
            ld      hl, DISPLAY_FILE
            ld      de, DISPLAY_FILE+1
            ld      bc, 6143
            ld      (hl), 0
            ldir

            ; Clear all attributes to white paper, black ink
            ld      hl, ATTR_BASE
            ld      de, ATTR_BASE+1
            ld      bc, 767
            ld      (hl), TEXT_ATTR     ; White background for text areas
            ldir

            ret

; ----------------------------------------------------------------------------
; Draw UI
; ----------------------------------------------------------------------------
; Draws score display and turn indicator

draw_ui:
            call    draw_scores
            call    draw_turn_indicator
            ret

; ----------------------------------------------------------------------------
; Draw Scores
; ----------------------------------------------------------------------------
; Displays "P1: nn  P2: nn" with player colours

draw_scores:
            ; Count cells for each player
            call    count_cells

            ; Draw P1 label "P1:"
            ld      b, SCORE_ROW
            ld      c, P1_SCORE_COL
            ld      a, 'P'
            call    print_char
            inc     c
            ld      a, '1'
            call    print_char
            inc     c
            ld      a, ':'
            call    print_char
            inc     c

            ; Print P1 score
            ld      a, (p1_count)
            call    print_two_digits

            ; Set P1 colour attribute
            ld      a, SCORE_ROW
            ld      c, P1_SCORE_COL
            ld      b, 5                ; "P1:nn" = 5 characters
            ld      e, P1_TEXT
            call    set_attr_range

            ; Draw P2 label "P2:"
            ld      b, SCORE_ROW
            ld      c, P2_SCORE_COL
            ld      a, 'P'
            call    print_char
            inc     c
            ld      a, '2'
            call    print_char
            inc     c
            ld      a, ':'
            call    print_char
            inc     c

            ; Print P2 score
            ld      a, (p2_count)
            call    print_two_digits

            ; Set P2 colour attribute
            ld      a, SCORE_ROW
            ld      c, P2_SCORE_COL
            ld      b, 5
            ld      e, P2_TEXT
            call    set_attr_range

            ret

; ----------------------------------------------------------------------------
; Draw Turn Indicator
; ----------------------------------------------------------------------------
; Shows "TURN" with current player's colour

draw_turn_indicator:
            ; Print "TURN"
            ld      b, TURN_ROW
            ld      c, TURN_COL
            ld      a, 'T'
            call    print_char
            inc     c
            ld      a, 'U'
            call    print_char
            inc     c
            ld      a, 'R'
            call    print_char
            inc     c
            ld      a, 'N'
            call    print_char

            ; Set attribute based on current player
            ld      a, (current_player)
            cp      1
            jr      z, .dti_p1
            ld      e, P2_TEXT
            jr      .dti_set
.dti_p1:
            ld      e, P1_TEXT

.dti_set:
            ld      a, TURN_ROW
            ld      c, TURN_COL
            ld      b, 4                ; "TURN" = 4 chars
            call    set_attr_range

            ret

; ----------------------------------------------------------------------------
; Print Character
; ----------------------------------------------------------------------------
; A = ASCII character (32-127), B = row (0-23), C = column (0-31)
; Writes character directly to display file using custom character set

print_char:
            push    bc
            push    de
            push    hl
            push    af

            ; Calculate character data address in custom charset
            ; Character - 32 gives offset, * 8 for bytes per char
            sub     32              ; Convert ASCII to charset offset
            ld      l, a
            ld      h, 0
            add     hl, hl
            add     hl, hl
            add     hl, hl          ; HL = (char-32) * 8
            ld      de, custom_charset
            add     hl, de          ; HL = source address in custom charset

            push    hl              ; Save character data address

            ; Calculate display file address
            ; Screen address: high byte varies with row, low byte = column
            ld      a, b            ; A = row (0-23)
            and     %00011000       ; Get which third (0, 8, 16)
            add     a, $40          ; Add display file base high byte
            ld      d, a

            ld      a, b            ; A = row
            and     %00000111       ; Get line within character row
            rrca
            rrca
            rrca                    ; Shift to bits 5-7
            add     a, c            ; Add column
            ld      e, a            ; DE = screen address

            pop     hl              ; HL = character data

            ; Copy 8 bytes (8 pixel rows of character)
            ld      b, 8
.pc_loop:
            ld      a, (hl)
            ld      (de), a
            inc     hl
            inc     d               ; Next screen line (add 256)
            djnz    .pc_loop

            pop     af
            pop     hl
            pop     de
            pop     bc
            ret

; ----------------------------------------------------------------------------
; Print Two Digits
; ----------------------------------------------------------------------------
; A = number (0-99), B = row, C = column (will advance by 2)
; Prints number as two digits

print_two_digits:
            push    bc

            ; Calculate tens digit
            ld      d, 0            ; Tens counter
.ptd_tens:
            cp      10
            jr      c, .ptd_print
            sub     10
            inc     d
            jr      .ptd_tens

.ptd_print:
            push    af              ; Save units digit

            ; Print tens digit
            ld      a, d
            add     a, '0'
            call    print_char
            inc     c

            ; Print units digit
            pop     af
            add     a, '0'
            call    print_char
            inc     c

            pop     bc
            ret

; ----------------------------------------------------------------------------
; Count Cells
; ----------------------------------------------------------------------------
; Counts cells owned by each player

count_cells:
            xor     a
            ld      (p1_count), a
            ld      (p2_count), a

            ld      hl, board_state
            ld      b, 64               ; 64 cells

.cc_loop:
            ld      a, (hl)
            cp      STATE_P1
            jr      nz, .cc_not_p1
            ld      a, (p1_count)
            inc     a
            ld      (p1_count), a
            jr      .cc_next
.cc_not_p1:
            cp      STATE_P2
            jr      nz, .cc_next
            ld      a, (p2_count)
            inc     a
            ld      (p2_count), a
.cc_next:
            inc     hl
            djnz    .cc_loop

            ret

; ----------------------------------------------------------------------------
; Set Attribute Range
; ----------------------------------------------------------------------------
; A = row, C = start column, B = count, E = attribute

set_attr_range:
            push    bc
            push    de

            ; Calculate start address: ATTR_BASE + row*32 + col
            ld      l, a
            ld      h, 0
            add     hl, hl
            add     hl, hl
            add     hl, hl
            add     hl, hl
            add     hl, hl          ; HL = row * 32
            ld      a, c
            add     a, l
            ld      l, a
            ld      bc, ATTR_BASE
            add     hl, bc          ; HL = attribute address

            pop     de              ; E = attribute
            pop     bc              ; B = count

.sar_loop:
            ld      (hl), e
            inc     hl
            djnz    .sar_loop

            ret

; ----------------------------------------------------------------------------
; Update Border
; ----------------------------------------------------------------------------

update_border:
            ld      a, (current_player)
            cp      1
            jr      z, .ub_p1
            ld      a, P2_BORDER
            jr      .ub_set
.ub_p1:
            ld      a, P1_BORDER
.ub_set:
            out     (KEY_PORT), a
            ret

; ----------------------------------------------------------------------------
; Initialise Game State
; ----------------------------------------------------------------------------

init_game:
            ld      hl, board_state
            ld      b, 64
            xor     a
.ig_loop:
            ld      (hl), a
            inc     hl
            djnz    .ig_loop

            ld      a, 1
            ld      (current_player), a

            xor     a
            ld      (cursor_row), a
            ld      (cursor_col), a
            ld      (p1_count), a
            ld      (p2_count), a
            ld      (last_key), a           ; No previous key
            ld      (key_timer), a          ; No delay active

            ; Initialize AI timer
            ld      a, AI_DELAY
            ld      (ai_timer), a

            ret

; ----------------------------------------------------------------------------
; Draw Board Border (Enhanced with Custom Characters)
; ----------------------------------------------------------------------------

draw_board_border:
            ; Top border row
            ld      c, BOARD_ROW-1
            ld      d, BOARD_COL-1
            ld      b, BOARD_SIZE+2
            call    draw_border_row

            ; Bottom border row
            ld      c, BOARD_ROW+BOARD_SIZE
            ld      d, BOARD_COL-1
            ld      b, BOARD_SIZE+2
            call    draw_border_row

            ; Left border column
            ld      c, BOARD_ROW
            ld      d, BOARD_COL-1
            ld      b, BOARD_SIZE
            call    draw_border_col

            ; Right border column
            ld      c, BOARD_ROW
            ld      d, BOARD_COL+BOARD_SIZE
            ld      b, BOARD_SIZE
            call    draw_border_col

            ret

draw_border_row:
            push    bc
.dbr_loop:
            push    bc
            push    de

            ld      a, c
            ld      l, a
            ld      h, 0
            add     hl, hl
            add     hl, hl
            add     hl, hl
            add     hl, hl
            add     hl, hl
            ld      a, d
            add     a, l
            ld      l, a
            ld      bc, ATTR_BASE
            add     hl, bc

            ld      (hl), BORDER_ATTR

            pop     de
            pop     bc
            inc     d
            djnz    .dbr_loop
            pop     bc
            ret

draw_border_col:
            push    bc
.dbc_loop:
            push    bc
            push    de

            ld      a, c
            ld      l, a
            ld      h, 0
            add     hl, hl
            add     hl, hl
            add     hl, hl
            add     hl, hl
            add     hl, hl
            ld      a, d
            add     a, l
            ld      l, a
            ld      bc, ATTR_BASE
            add     hl, bc

            ld      (hl), BORDER_ATTR

            pop     de
            pop     bc
            inc     c
            djnz    .dbc_loop
            pop     bc
            ret

; ----------------------------------------------------------------------------
; Draw Board
; ----------------------------------------------------------------------------

draw_board:
            ld      b, BOARD_SIZE
            ld      c, BOARD_ROW

.db_row:
            push    bc

            ld      b, BOARD_SIZE
            ld      d, BOARD_COL

.db_col:
            push    bc

            ld      a, c
            ld      l, a
            ld      h, 0
            add     hl, hl
            add     hl, hl
            add     hl, hl
            add     hl, hl
            add     hl, hl
            ld      a, d
            add     a, l
            ld      l, a
            ld      bc, ATTR_BASE
            add     hl, bc

            ld      (hl), EMPTY_ATTR

            pop     bc
            inc     d
            djnz    .db_col

            pop     bc
            inc     c
            djnz    .db_row

            ret

; ----------------------------------------------------------------------------
; Draw Cursor
; ----------------------------------------------------------------------------

draw_cursor:
            call    get_cell_state

            cp      STATE_P1
            jr      z, .dc_p1
            cp      STATE_P2
            jr      z, .dc_p2

            ld      a, CURSOR_ATTR
            jr      .dc_set

.dc_p1:
            ld      a, P1_CURSOR
            jr      .dc_set

.dc_p2:
            ld      a, P2_CURSOR

.dc_set:
            push    af

            ld      a, (cursor_row)
            add     a, BOARD_ROW
            ld      l, a
            ld      h, 0
            add     hl, hl
            add     hl, hl
            add     hl, hl
            add     hl, hl
            add     hl, hl
            ld      a, (cursor_col)
            add     a, BOARD_COL
            add     a, l
            ld      l, a
            ld      bc, ATTR_BASE
            add     hl, bc

            pop     af
            ld      (hl), a

            ret

; ----------------------------------------------------------------------------
; Clear Cursor
; ----------------------------------------------------------------------------

clear_cursor:
            call    get_cell_state

            cp      STATE_P1
            jr      z, .clc_p1
            cp      STATE_P2
            jr      z, .clc_p2

            ld      a, EMPTY_ATTR
            jr      .clc_set

.clc_p1:
            ld      a, P1_ATTR
            jr      .clc_set

.clc_p2:
            ld      a, P2_ATTR

.clc_set:
            push    af

            ld      a, (cursor_row)
            add     a, BOARD_ROW
            ld      l, a
            ld      h, 0
            add     hl, hl
            add     hl, hl
            add     hl, hl
            add     hl, hl
            add     hl, hl
            ld      a, (cursor_col)
            add     a, BOARD_COL
            add     a, l
            ld      l, a
            ld      bc, ATTR_BASE
            add     hl, bc

            pop     af
            ld      (hl), a

            ret

; ----------------------------------------------------------------------------
; Get Cell State
; ----------------------------------------------------------------------------

get_cell_state:
            ld      a, (cursor_row)
            add     a, a
            add     a, a
            add     a, a
            ld      hl, board_state
            ld      b, 0
            ld      c, a
            add     hl, bc
            ld      a, (cursor_col)
            ld      c, a
            add     hl, bc
            ld      a, (hl)
            ret

; ----------------------------------------------------------------------------
; Read Keyboard
; ----------------------------------------------------------------------------

read_keyboard:
            xor     a
            ld      (key_pressed), a

            ld      a, ROW_QAOP
            in      a, (KEY_PORT)
            bit     0, a
            jr      nz, .rk_not_q
            ld      a, 1
            ld      (key_pressed), a
            ret
.rk_not_q:
            ld      a, ROW_ASDF
            in      a, (KEY_PORT)
            bit     0, a
            jr      nz, .rk_not_a
            ld      a, 2
            ld      (key_pressed), a
            ret
.rk_not_a:
            ld      a, ROW_YUIOP
            in      a, (KEY_PORT)
            bit     1, a
            jr      nz, .rk_not_o
            ld      a, 3
            ld      (key_pressed), a
            ret
.rk_not_o:
            ld      a, ROW_YUIOP
            in      a, (KEY_PORT)
            bit     0, a
            jr      nz, .rk_not_p
            ld      a, 4
            ld      (key_pressed), a
            ret
.rk_not_p:
            ld      a, ROW_SPACE
            in      a, (KEY_PORT)
            bit     0, a
            jr      nz, .rk_not_space
            ld      a, 5
            ld      (key_pressed), a
.rk_not_space:
            ret

; ----------------------------------------------------------------------------
; Handle Input
; ----------------------------------------------------------------------------
; Implements key repeat delay for smooth cursor movement

handle_input:
            ld      a, (key_pressed)
            or      a
            jr      nz, .hi_have_key

            ; No key pressed - reset tracking
            xor     a
            ld      (last_key), a
            ld      (key_timer), a
            ret

.hi_have_key:
            ; Space (claim) always works immediately
            cp      5
            jr      z, try_claim

            ; Check if same key as last frame
            ld      b, a                    ; Save current key
            ld      a, (last_key)
            cp      b
            jr      nz, .hi_new_key

            ; Same key - check timer
            ld      a, (key_timer)
            or      a
            jr      z, .hi_allow            ; Timer expired, allow repeat
            dec     a
            ld      (key_timer), a
            ret                             ; Still waiting

.hi_new_key:
            ; New key pressed - save it and reset timer
            ld      a, b
            ld      (last_key), a
            ld      a, KEY_DELAY
            ld      (key_timer), a

.hi_allow:
            ; Process movement
            call    clear_cursor

            ld      a, (key_pressed)

            cp      1
            jr      nz, .hi_not_up
            ld      a, (cursor_row)
            or      a
            jr      z, .hi_done
            dec     a
            ld      (cursor_row), a
            jr      .hi_done
.hi_not_up:
            cp      2
            jr      nz, .hi_not_down
            ld      a, (cursor_row)
            cp      BOARD_SIZE-1
            jr      z, .hi_done
            inc     a
            ld      (cursor_row), a
            jr      .hi_done
.hi_not_down:
            cp      3
            jr      nz, .hi_not_left
            ld      a, (cursor_col)
            or      a
            jr      z, .hi_done
            dec     a
            ld      (cursor_col), a
            jr      .hi_done
.hi_not_left:
            cp      4
            jr      nz, .hi_done
            ld      a, (cursor_col)
            cp      BOARD_SIZE-1
            jr      z, .hi_done
            inc     a
            ld      (cursor_col), a

.hi_done:
            call    draw_cursor
            ret

; ----------------------------------------------------------------------------
; Try Claim Cell
; ----------------------------------------------------------------------------

try_claim:
            call    get_cell_state
            or      a
            jr      z, .tc_valid

            ; Cell already claimed - error feedback
            call    sound_error
            call    flash_border_error
            call    update_border       ; Restore correct border colour
            ret

.tc_valid:
            ; Valid move - claim the cell
            call    claim_cell
            call    sound_claim

            ld      a, (current_player)
            xor     3
            ld      (current_player), a

            call    draw_ui             ; Update scores and turn indicator

            ; Check if game is over
            call    check_game_over
            or      a
            jr      z, .tc_continue

            ; Game over - play appropriate sound and show results
            call    play_result_sound
            call    show_results
            call    victory_celebration
            call    wait_for_key

            ; Return to title screen
            ld      a, GS_TITLE
            ld      (game_state), a
            call    init_screen
            call    draw_title_screen
            xor     a
            out     (KEY_PORT), a       ; Black border for title
            ret

.tc_continue:
            call    update_border
            call    draw_cursor

            ret

; ----------------------------------------------------------------------------
; Claim Cell
; ----------------------------------------------------------------------------

claim_cell:
            ld      a, (cursor_row)
            add     a, a
            add     a, a
            add     a, a
            ld      hl, board_state
            ld      b, 0
            ld      c, a
            add     hl, bc
            ld      a, (cursor_col)
            ld      c, a
            add     hl, bc

            ld      a, (current_player)
            ld      (hl), a

            push    af

            ld      a, (cursor_row)
            add     a, BOARD_ROW
            ld      l, a
            ld      h, 0
            add     hl, hl
            add     hl, hl
            add     hl, hl
            add     hl, hl
            add     hl, hl
            ld      a, (cursor_col)
            add     a, BOARD_COL
            add     a, l
            ld      l, a
            ld      bc, ATTR_BASE
            add     hl, bc

            pop     af
            cp      1
            jr      z, .clm_is_p1
            ld      (hl), P2_ATTR
            ret
.clm_is_p1:
            ld      (hl), P1_ATTR
            ret

; ----------------------------------------------------------------------------
; Sound - Claim
; ----------------------------------------------------------------------------

sound_claim:
            ld      hl, 400
            ld      b, 20

.scl_loop:
            push    bc
            push    hl

            ld      b, h
            ld      c, l
.scl_tone:
            ld      a, $10
            out     (KEY_PORT), a
            call    .scl_delay
            xor     a
            out     (KEY_PORT), a
            call    .scl_delay
            dec     bc
            ld      a, b
            or      c
            jr      nz, .scl_tone

            pop     hl
            pop     bc

            ld      de, 20
            or      a
            sbc     hl, de

            djnz    .scl_loop
            ret

.scl_delay:
            push    bc
            ld      b, 5
.scl_delay_loop:
            djnz    .scl_delay_loop
            pop     bc
            ret

; ----------------------------------------------------------------------------
; Sound - Error
; ----------------------------------------------------------------------------
; Harsh buzz for invalid move

sound_error:
            ld      b, 30               ; Duration

.se_loop:
            push    bc

            ; Low frequency buzz (longer delay = lower pitch)
            ld      a, $10
            out     (KEY_PORT), a
            ld      c, 80               ; Longer delay for low pitch
.se_delay1:
            dec     c
            jr      nz, .se_delay1

            xor     a
            out     (KEY_PORT), a
            ld      c, 80
.se_delay2:
            dec     c
            jr      nz, .se_delay2

            pop     bc
            djnz    .se_loop

            ret

; ----------------------------------------------------------------------------
; Sound - Menu Select
; ----------------------------------------------------------------------------
; Quick high beep for menu selection

sound_select:
            ld      b, 15               ; Short duration

.ss_loop:
            push    bc

            ld      a, $10
            out     (KEY_PORT), a
            ld      c, 20               ; High pitch (short delay)
.ss_delay1:
            dec     c
            jr      nz, .ss_delay1

            xor     a
            out     (KEY_PORT), a
            ld      c, 20
.ss_delay2:
            dec     c
            jr      nz, .ss_delay2

            pop     bc
            djnz    .ss_loop

            ret

; ----------------------------------------------------------------------------
; Sound - Startup
; ----------------------------------------------------------------------------
; Quick ascending jingle when game loads

sound_startup:
            ; Three quick ascending notes
            ld      hl, 50              ; Starting pitch
            ld      b, 3                ; Three notes

.sst_note:
            push    bc
            push    hl

            ; Play note
            ld      b, 12               ; Short duration
.sst_tone:
            push    bc
            ld      a, $10
            out     (KEY_PORT), a
            ld      b, l
.sst_d1:    djnz    .sst_d1
            xor     a
            out     (KEY_PORT), a
            ld      b, l
.sst_d2:    djnz    .sst_d2
            pop     bc
            djnz    .sst_tone

            pop     hl
            pop     bc

            ; Decrease delay (higher pitch) for next note
            ld      a, l
            sub     12
            ld      l, a

            ; Brief pause between notes
            push    bc
            ld      bc, 1000
.sst_pause: dec     bc
            ld      a, b
            or      c
            jr      nz, .sst_pause
            pop     bc

            djnz    .sst_note
            ret

; ----------------------------------------------------------------------------
; Sound - Victory
; ----------------------------------------------------------------------------
; Triumphant ascending fanfare

sound_victory:
            ; Play three ascending notes
            ld      hl, 60              ; Starting pitch (low)
            ld      b, 3                ; Three notes

.sv_note:
            push    bc
            push    hl

            ; Play note
            ld      b, 25               ; Note duration
.sv_tone:
            push    bc
            ld      a, $10
            out     (KEY_PORT), a
            ld      b, l
.sv_d1:     djnz    .sv_d1
            xor     a
            out     (KEY_PORT), a
            ld      b, l
.sv_d2:     djnz    .sv_d2
            pop     bc
            djnz    .sv_tone

            pop     hl
            pop     bc

            ; Decrease delay (higher pitch) for next note
            ld      a, l
            sub     15
            ld      l, a

            ; Brief pause between notes
            push    bc
            ld      bc, 2000
.sv_pause:  dec     bc
            ld      a, b
            or      c
            jr      nz, .sv_pause
            pop     bc

            djnz    .sv_note
            ret

; ----------------------------------------------------------------------------
; Sound - Draw
; ----------------------------------------------------------------------------
; Neutral two-tone sound for draw

sound_draw:
            ; First tone (mid pitch)
            ld      b, 20
.sd_tone1:
            push    bc
            ld      a, $10
            out     (KEY_PORT), a
            ld      c, 40
.sd_d1:     dec     c
            jr      nz, .sd_d1
            xor     a
            out     (KEY_PORT), a
            ld      c, 40
.sd_d2:     dec     c
            jr      nz, .sd_d2
            pop     bc
            djnz    .sd_tone1

            ; Brief pause
            ld      bc, 1500
.sd_pause:  dec     bc
            ld      a, b
            or      c
            jr      nz, .sd_pause

            ; Second tone (same pitch - neutral)
            ld      b, 20
.sd_tone2:
            push    bc
            ld      a, $10
            out     (KEY_PORT), a
            ld      c, 40
.sd_d3:     dec     c
            jr      nz, .sd_d3
            xor     a
            out     (KEY_PORT), a
            ld      c, 40
.sd_d4:     dec     c
            jr      nz, .sd_d4
            pop     bc
            djnz    .sd_tone2

            ret

; ----------------------------------------------------------------------------
; Play Result Sound
; ----------------------------------------------------------------------------
; Plays victory or draw sound based on game result

play_result_sound:
            ; Compare scores
            ld      a, (p1_count)
            ld      b, a
            ld      a, (p2_count)
            cp      b
            jr      z, .prs_draw        ; Equal = draw
            ; Someone won - play victory
            call    sound_victory
            ret
.prs_draw:
            call    sound_draw
            ret

; ----------------------------------------------------------------------------
; Flash Border Error
; ----------------------------------------------------------------------------
; Flash border red briefly to indicate error

flash_border_error:
            ; Flash red 3 times
            ld      b, 3

.fbe_loop:
            push    bc

            ; Red border
            ld      a, ERROR_BORDER
            out     (KEY_PORT), a

            ; Short delay (about 3 frames)
            ld      bc, 8000
.fbe_delay1:
            dec     bc
            ld      a, b
            or      c
            jr      nz, .fbe_delay1

            ; Black border (brief off)
            xor     a
            out     (KEY_PORT), a

            ; Short delay
            ld      bc, 4000
.fbe_delay2:
            dec     bc
            ld      a, b
            or      c
            jr      nz, .fbe_delay2

            pop     bc
            djnz    .fbe_loop

            ret

; ----------------------------------------------------------------------------
; Check Game Over
; ----------------------------------------------------------------------------
; Returns A=1 if game is over (board full), A=0 otherwise

check_game_over:
            ; Game is over when p1_count + p2_count == 64
            ld      a, (p1_count)
            ld      b, a
            ld      a, (p2_count)
            add     a, b
            cp      TOTAL_CELLS
            jr      z, .cgo_over
            xor     a               ; Not over
            ret
.cgo_over:
            ld      a, 1            ; Game over
            ret

; ----------------------------------------------------------------------------
; Show Results
; ----------------------------------------------------------------------------
; Displays enhanced results screen with final scores and winner

show_results:
            ; Clear turn indicator
            ld      a, TURN_ROW
            ld      c, TURN_COL
            ld      b, 4
            ld      e, TEXT_ATTR
            call    set_attr_range

            ; Display "GAME OVER" header
            ld      b, GAMEOVER_ROW
            ld      c, GAMEOVER_COL
            ld      hl, msg_gameover
            ld      e, TEXT_ATTR
            call    print_message

            ; Display final P1 score
            ld      b, FINAL_ROW
            ld      c, FINAL_P1_COL
            ld      a, 'P'
            call    print_char
            inc     c
            ld      a, '1'
            call    print_char
            inc     c
            ld      a, ':'
            call    print_char
            inc     c
            ld      a, (p1_count)
            call    print_two_digits
            ; Set P1 colour
            ld      a, FINAL_ROW
            ld      c, FINAL_P1_COL
            ld      b, 5
            ld      e, P1_TEXT
            call    set_attr_range

            ; Display final P2 score
            ld      b, FINAL_ROW
            ld      c, FINAL_P2_COL
            ld      a, 'P'
            call    print_char
            inc     c
            ld      a, '2'
            call    print_char
            inc     c
            ld      a, ':'
            call    print_char
            inc     c
            ld      a, (p2_count)
            call    print_two_digits
            ; Set P2 colour
            ld      a, FINAL_ROW
            ld      c, FINAL_P2_COL
            ld      b, 5
            ld      e, P2_TEXT
            call    set_attr_range

            ; Determine winner and display message
            ld      a, (p1_count)
            ld      b, a
            ld      a, (p2_count)
            cp      b
            jr      c, .sr_p1_wins      ; p2 < p1, so p1 wins
            jr      z, .sr_draw         ; p1 == p2, draw
            ; p2 > p1, p2 wins
            jr      .sr_p2_wins

.sr_p1_wins:
            ; Display "P1 WINS!"
            ld      b, WINNER_ROW
            ld      c, WINNER_COL
            ld      hl, msg_p1_wins
            ld      e, P1_TEXT
            call    print_message
            ; Calculate and show margin
            ld      a, (p1_count)
            ld      b, a
            ld      a, (p2_count)
            neg
            add     a, b            ; A = p1 - p2
            call    show_margin
            jr      .sr_prompt

.sr_p2_wins:
            ; Display "P2 WINS!"
            ld      b, WINNER_ROW
            ld      c, WINNER_COL
            ld      hl, msg_p2_wins
            ld      e, P2_TEXT
            call    print_message
            ; Calculate and show margin
            ld      a, (p2_count)
            ld      b, a
            ld      a, (p1_count)
            neg
            add     a, b            ; A = p2 - p1
            call    show_margin
            jr      .sr_prompt

.sr_draw:
            ; Display "DRAW!" (centred on winner row)
            ld      b, WINNER_ROW
            ld      c, WINNER_COL + 2
            ld      hl, msg_draw
            ld      e, TEXT_ATTR
            call    print_message
            ; No margin for draw - skip to prompt

.sr_prompt:
            ; Display "PRESS ANY KEY" prompt (on next row down)
            ld      b, WINNER_ROW + 2
            ld      c, CONTINUE_COL
            ld      hl, msg_continue
            ld      e, TEXT_ATTR
            call    print_message
            ret

; ----------------------------------------------------------------------------
; Show Margin
; ----------------------------------------------------------------------------
; Displays "BY nn CELLS" for victory margin
; A = margin (difference in scores)

show_margin:
            push    af              ; Save margin
            ; Print "BY "
            ld      b, MARGIN_ROW
            ld      c, MARGIN_COL
            ld      hl, msg_by
            ld      e, TEXT_ATTR
            call    print_message
            ; Print margin number
            ld      c, MARGIN_COL + 3
            pop     af
            call    print_two_digits
            ; Print " CELLS"
            ld      c, MARGIN_COL + 5
            ld      hl, msg_cells
            call    print_message
            ret

; ----------------------------------------------------------------------------
; Print Message
; ----------------------------------------------------------------------------
; HL = pointer to null-terminated string
; B = row, C = starting column, E = attribute for message area

print_message:
            ; Save parameters we need later
            push    de              ; Save attribute in E
            push    bc              ; Save row (B) and start column (C)

            ; Print characters
.pm_loop:
            ld      a, (hl)
            or      a
            jr      z, .pm_done
            call    print_char
            inc     hl
            inc     c
            jr      .pm_loop

.pm_done:
            ; C now has end column
            ; Calculate length: end_col - start_col
            ld      a, c            ; A = end column
            pop     bc              ; B = row, C = start column
            sub     c               ; A = length
            ld      d, a            ; D = length (save it)

            ; Set up for set_attr_range: A=row, C=start_col, B=count, E=attr
            ld      a, b            ; A = row
            ld      b, d            ; B = count (length)
            pop     de              ; E = attribute
            call    set_attr_range

            ret

; ----------------------------------------------------------------------------
; Victory Celebration
; ----------------------------------------------------------------------------
; Flashes border in winner's colour

victory_celebration:
            ; Determine winner's border colour
            ld      a, (p1_count)
            ld      b, a
            ld      a, (p2_count)
            cp      b
            jr      c, .vc_p1           ; p2 < p1
            jr      z, .vc_draw         ; draw - use white
            ld      d, P2_BORDER        ; p2 wins
            jr      .vc_flash
.vc_p1:
            ld      d, P1_BORDER
            jr      .vc_flash
.vc_draw:
            ld      d, 7                ; White for draw

.vc_flash:
            ; Flash border 5 times
            ld      b, 5

.vc_loop:
            push    bc

            ; Winner's colour
            ld      a, d
            out     (KEY_PORT), a

            ; Delay
            ld      bc, 15000
.vc_delay1:
            dec     bc
            ld      a, b
            or      c
            jr      nz, .vc_delay1

            ; Black
            xor     a
            out     (KEY_PORT), a

            ; Delay
            ld      bc, 10000
.vc_delay2:
            dec     bc
            ld      a, b
            or      c
            jr      nz, .vc_delay2

            pop     bc
            djnz    .vc_loop

            ret

; ----------------------------------------------------------------------------
; Draw Title Screen
; ----------------------------------------------------------------------------
; Displays game title and prompt

draw_title_screen:
            ; Draw "INK WAR" title
            ld      b, TITLE_ROW
            ld      c, TITLE_COL
            ld      hl, msg_title
            ld      e, TEXT_ATTR
            call    print_message

            ; Draw "1 - TWO PLAYER"
            ld      b, MODE1_ROW
            ld      c, MODE1_COL
            ld      hl, msg_mode1
            ld      e, TEXT_ATTR
            call    print_message

            ; Draw "2 - AI EASY"
            ld      b, MODE2_ROW
            ld      c, MODE2_COL
            ld      hl, msg_mode2
            ld      e, TEXT_ATTR
            call    print_message

            ; Draw "3 - AI MEDIUM"
            ld      b, MODE3_ROW
            ld      c, MODE3_COL
            ld      hl, msg_mode3
            ld      e, TEXT_ATTR
            call    print_message

            ; Draw "4 - AI HARD"
            ld      b, MODE4_ROW
            ld      c, MODE4_COL
            ld      hl, msg_mode4
            ld      e, TEXT_ATTR
            call    print_message

            ; Draw version
            ld      b, 22
            ld      c, 10
            ld      hl, msg_version
            ld      e, TEXT_ATTR
            call    print_message

            ret

; ----------------------------------------------------------------------------
; Wait Key Release
; ----------------------------------------------------------------------------
; Waits until all keys are released

wait_key_release:
.wkr_loop:
            xor     a
            in      a, (KEY_PORT)
            cpl                     ; Invert (keys are active low)
            and     %00011111       ; Mask to key bits
            jr      nz, .wkr_loop   ; Still holding a key
            ret

; ----------------------------------------------------------------------------
; Wait For Key
; ----------------------------------------------------------------------------
; Waits until any key is pressed

wait_for_key:
            ; First wait for all keys to be released
.wfk_release:
            xor     a
            in      a, (KEY_PORT)
            cpl                     ; Invert (keys are active low)
            and     %00011111       ; Mask to key bits
            jr      nz, .wfk_release

            ; Now wait for a key press
.wfk_wait:
            halt                    ; Wait for interrupt
            xor     a
            in      a, (KEY_PORT)
            cpl
            and     %00011111
            jr      z, .wfk_wait

            ret

; ----------------------------------------------------------------------------
; AI Make Move
; ----------------------------------------------------------------------------
; AI picks a cell based on difficulty level

ai_make_move:
            ; Dispatch based on difficulty
            ld      a, (ai_difficulty)
            or      a
            jr      z, .aim_easy            ; AI_EASY = 0
            cp      AI_MEDIUM
            jr      z, .aim_medium
            ; AI_HARD - full strategy
            call    find_best_adjacent_cell
            jr      .aim_have_cell

.aim_easy:
            ; Random moves
            call    find_random_empty_cell
            jr      .aim_have_cell

.aim_medium:
            ; Adjacent priority only (no defense/position)
            call    find_adjacent_only
            ; Fall through to .aim_have_cell

.aim_have_cell:
            ; A = cell index (0-63), or $FF if board full

            cp      $ff
            ret     z               ; No empty cells (shouldn't happen)

            ; Convert index to row/col and set cursor
            ld      b, a
            and     %00000111       ; Column = index AND 7
            ld      (cursor_col), a
            ld      a, b
            rrca
            rrca
            rrca
            and     %00000111       ; Row = index >> 3
            ld      (cursor_row), a

            ; Claim the cell (reuse existing code)
            call    claim_cell
            call    sound_claim

            ; Switch player
            ld      a, (current_player)
            xor     3
            ld      (current_player), a

            call    draw_ui

            ; Check if game is over
            call    check_game_over
            or      a
            jr      z, .aim_continue

            ; Game over - play appropriate sound and show results
            call    play_result_sound
            call    show_results
            call    victory_celebration
            call    wait_for_key

            ; Return to title screen
            ld      a, GS_TITLE
            ld      (game_state), a
            call    init_screen
            call    draw_title_screen
            xor     a
            out     (KEY_PORT), a       ; Black border for title
            ret

.aim_continue:
            call    update_border
            call    draw_cursor
            ret

; ----------------------------------------------------------------------------
; Find Best Cell (Offense + Defense + Position)
; ----------------------------------------------------------------------------
; Returns A = index of empty cell with best combined score, or $FF if none
; Score = adjacent AI + adjacent human + position bonus (corner=2, edge=1)
; This makes the AI value strategic positions in addition to adjacency

find_best_adjacent_cell:
            ; Initialize best tracking
            ld      a, $ff
            ld      (best_cell), a      ; No best cell yet
            xor     a
            ld      (best_score), a     ; Best score = 0

            ; Scan all 64 cells
            ld      c, 0                ; C = current cell index

.fbac_loop:
            ; Check if cell is empty
            ld      hl, board_state
            ld      d, 0
            ld      e, c
            add     hl, de
            ld      a, (hl)
            or      a
            jr      nz, .fbac_next      ; Not empty, skip

            ; Empty cell - count adjacent AI cells (offense)
            push    bc
            ld      a, c
            call    count_adjacent_ai
            ld      b, a                ; B = AI adjacent count

            ; Count adjacent human cells (defense)
            ld      a, c
            call    count_adjacent_p1
            add     a, b                ; A = adjacency score
            ld      b, a                ; B = adjacency score

            ; Add position bonus (corners=2, edges=1)
            ld      a, c
            call    get_position_bonus
            add     a, b                ; A = total score
            pop     bc

            ; Compare with best score
            ld      b, a                ; B = this score
            ld      a, (best_score)
            cp      b
            jr      nc, .fbac_next      ; Current best >= this score

            ; New best found
            ld      a, b
            ld      (best_score), a
            ld      a, c
            ld      (best_cell), a

.fbac_next:
            inc     c
            ld      a, c
            cp      64
            jr      c, .fbac_loop       ; Continue if c < 64

            ; Check if we found a good cell
            ld      a, (best_score)
            or      a
            jr      z, .fbac_random     ; No scored cells, use random

            ; Return best cell
            ld      a, (best_cell)
            ret

.fbac_random:
            ; Fall back to random empty cell
            call    find_random_empty_cell
            ret

best_cell:      defb    0
best_score:     defb    0

; ----------------------------------------------------------------------------
; Find Adjacent Only (Medium Difficulty)
; ----------------------------------------------------------------------------
; Returns A = index of empty cell with most AI neighbors, or $FF if none
; Only considers AI adjacency - no defense or position bonus

find_adjacent_only:
            ; Initialize best tracking
            ld      a, $ff
            ld      (best_cell), a
            xor     a
            ld      (best_score), a

            ; Scan all 64 cells
            ld      c, 0

.fao_loop:
            ; Check if cell is empty
            ld      hl, board_state
            ld      d, 0
            ld      e, c
            add     hl, de
            ld      a, (hl)
            or      a
            jr      nz, .fao_next

            ; Empty cell - count adjacent AI cells only
            push    bc
            ld      a, c
            call    count_adjacent_ai
            pop     bc

            ; Compare with best score
            ld      b, a
            ld      a, (best_score)
            cp      b
            jr      nc, .fao_next

            ; New best found
            ld      a, b
            ld      (best_score), a
            ld      a, c
            ld      (best_cell), a

.fao_next:
            inc     c
            ld      a, c
            cp      64
            jr      c, .fao_loop

            ; Check if we found an adjacent cell
            ld      a, (best_score)
            or      a
            jr      z, .fao_random

            ; Return best adjacent cell
            ld      a, (best_cell)
            ret

.fao_random:
            ; Fall back to random empty cell
            call    find_random_empty_cell
            ret

; ----------------------------------------------------------------------------
; Get Position Bonus
; ----------------------------------------------------------------------------
; A = cell index (0-63)
; Returns A = position bonus (corner=2, edge=1, center=0)

get_position_bonus:
            ; Get row and column from index
            ld      b, a
            and     %00000111           ; Column (0-7)
            ld      c, a
            ld      a, b
            rrca
            rrca
            rrca
            and     %00000111           ; Row (0-7)
            ld      b, a                ; B = row, C = col

            ; Check for corner (row=0 or 7, col=0 or 7)
            ld      a, b
            or      a
            jr      z, .gpb_row_edge    ; Row 0
            cp      7
            jr      z, .gpb_row_edge    ; Row 7
            ; Row is not edge
            ld      a, c
            or      a
            jr      z, .gpb_edge        ; Col 0, row not edge = edge
            cp      7
            jr      z, .gpb_edge        ; Col 7, row not edge = edge
            ; Neither row nor col is edge = center
            xor     a                   ; Return 0
            ret

.gpb_row_edge:
            ; Row is 0 or 7, check column
            ld      a, c
            or      a
            jr      z, .gpb_corner      ; Col 0 = corner
            cp      7
            jr      z, .gpb_corner      ; Col 7 = corner
            ; Row edge but not corner
            jr      .gpb_edge

.gpb_corner:
            ld      a, 2                ; Corner bonus
            ret

.gpb_edge:
            ld      a, 1                ; Edge bonus
            ret

; ----------------------------------------------------------------------------
; Count Adjacent AI Cells
; ----------------------------------------------------------------------------
; A = cell index (0-63)
; Returns A = count of adjacent cells owned by AI (P2)

count_adjacent_ai:
            ld      (temp_cell), a
            xor     a
            ld      (adj_count), a

            ; Get row and column
            ld      a, (temp_cell)
            ld      b, a
            and     %00000111           ; Column
            ld      c, a
            ld      a, b
            rrca
            rrca
            rrca
            and     %00000111           ; Row
            ld      b, a                ; B = row, C = col

            ; Check up (row-1)
            ld      a, b
            or      a
            jr      z, .caa_skip_up     ; Row 0, no up neighbor
            dec     a                   ; Row - 1
            push    bc
            ld      b, a
            call    .caa_check_cell
            pop     bc
.caa_skip_up:

            ; Check down (row+1)
            ld      a, b
            cp      7
            jr      z, .caa_skip_down   ; Row 7, no down neighbor
            inc     a                   ; Row + 1
            push    bc
            ld      b, a
            call    .caa_check_cell
            pop     bc
.caa_skip_down:

            ; Check left (col-1)
            ld      a, c
            or      a
            jr      z, .caa_skip_left   ; Col 0, no left neighbor
            dec     a                   ; Col - 1
            push    bc
            ld      c, a
            call    .caa_check_cell
            pop     bc
.caa_skip_left:

            ; Check right (col+1)
            ld      a, c
            cp      7
            jr      z, .caa_skip_right  ; Col 7, no right neighbor
            inc     a                   ; Col + 1
            push    bc
            ld      c, a
            call    .caa_check_cell
            pop     bc
.caa_skip_right:

            ld      a, (adj_count)
            ret

            ; Helper: check if cell at (B,C) is AI owned
.caa_check_cell:
            ; Calculate index: row*8 + col
            ld      a, b
            rlca
            rlca
            rlca                        ; Row * 8
            add     a, c                ; + col
            ld      hl, board_state
            ld      d, 0
            ld      e, a
            add     hl, de
            ld      a, (hl)
            cp      STATE_P2            ; AI is Player 2
            ret     nz                  ; Not AI cell
            ; AI cell - increment count
            ld      a, (adj_count)
            inc     a
            ld      (adj_count), a
            ret

temp_cell:      defb    0
adj_count:      defb    0

; ----------------------------------------------------------------------------
; Count Adjacent Human Cells
; ----------------------------------------------------------------------------
; A = cell index (0-63)
; Returns A = count of adjacent cells owned by human (P1)

count_adjacent_p1:
            ld      (temp_cell), a
            xor     a
            ld      (adj_count), a

            ; Get row and column
            ld      a, (temp_cell)
            ld      b, a
            and     %00000111           ; Column
            ld      c, a
            ld      a, b
            rrca
            rrca
            rrca
            and     %00000111           ; Row
            ld      b, a                ; B = row, C = col

            ; Check up (row-1)
            ld      a, b
            or      a
            jr      z, .cap_skip_up     ; Row 0, no up neighbor
            dec     a                   ; Row - 1
            push    bc
            ld      b, a
            call    .cap_check_cell
            pop     bc
.cap_skip_up:

            ; Check down (row+1)
            ld      a, b
            cp      7
            jr      z, .cap_skip_down   ; Row 7, no down neighbor
            inc     a                   ; Row + 1
            push    bc
            ld      b, a
            call    .cap_check_cell
            pop     bc
.cap_skip_down:

            ; Check left (col-1)
            ld      a, c
            or      a
            jr      z, .cap_skip_left   ; Col 0, no left neighbor
            dec     a                   ; Col - 1
            push    bc
            ld      c, a
            call    .cap_check_cell
            pop     bc
.cap_skip_left:

            ; Check right (col+1)
            ld      a, c
            cp      7
            jr      z, .cap_skip_right  ; Col 7, no right neighbor
            inc     a                   ; Col + 1
            push    bc
            ld      c, a
            call    .cap_check_cell
            pop     bc
.cap_skip_right:

            ld      a, (adj_count)
            ret

            ; Helper: check if cell at (B,C) is human owned
.cap_check_cell:
            ; Calculate index: row*8 + col
            ld      a, b
            rlca
            rlca
            rlca                        ; Row * 8
            add     a, c                ; + col
            ld      hl, board_state
            ld      d, 0
            ld      e, a
            add     hl, de
            ld      a, (hl)
            cp      STATE_P1            ; Human is Player 1
            ret     nz                  ; Not human cell
            ; Human cell - increment count
            ld      a, (adj_count)
            inc     a
            ld      (adj_count), a
            ret

; ----------------------------------------------------------------------------
; Find Random Empty Cell
; ----------------------------------------------------------------------------
; Returns A = index of a random empty cell (0-63), or $FF if none

find_random_empty_cell:
            ; Get random starting position
            call    get_random
            and     %00111111       ; Limit to 0-63

            ld      c, a            ; C = start index
            ld      b, 64           ; B = cells to check

.frec_loop:
            ; Check if cell at index C is empty
            ld      hl, board_state
            ld      d, 0
            ld      e, c
            add     hl, de
            ld      a, (hl)
            or      a
            jr      z, .frec_found  ; Found empty cell

            ; Try next cell (wrap around)
            inc     c
            ld      a, c
            and     %00111111       ; Wrap at 64
            ld      c, a

            djnz    .frec_loop

            ; No empty cells found
            ld      a, $ff
            ret

.frec_found:
            ld      a, c            ; Return cell index
            ret

; ----------------------------------------------------------------------------
; Get Random
; ----------------------------------------------------------------------------
; Returns A = pseudo-random number using R register

get_random:
            ld      a, r            ; R register changes every instruction
            ld      b, a
            ld      a, (random_seed)
            add     a, b
            rlca
            xor     b
            ld      (random_seed), a
            ret

random_seed:    defb    $5a         ; Seed value

; ----------------------------------------------------------------------------
; Messages
; ----------------------------------------------------------------------------

msg_p1_wins:    defb    "P1 WINS!", 0
msg_p2_wins:    defb    "P2 WINS!", 0
msg_draw:       defb    "DRAW!", 0
msg_title:      defb    "INK WAR", 0
msg_mode1:      defb    "1 - TWO PLAYER", 0
msg_mode2:      defb    "2 - AI EASY", 0
msg_mode3:      defb    "3 - AI MEDIUM", 0
msg_mode4:      defb    "4 - AI HARD", 0
msg_continue:   defb    "PRESS ANY KEY", 0
msg_gameover:   defb    "GAME OVER", 0
msg_final:      defb    "FINAL SCORE", 0
msg_by:         defb    "BY ", 0
msg_cells:      defb    " CELLS", 0
msg_version:    defb    "PHASE 2 V0.1", 0

; ----------------------------------------------------------------------------
; Variables
; ----------------------------------------------------------------------------

game_state:     defb    0               ; 0=title, 1=playing, 2=results
game_mode:      defb    0               ; 0=two player, 1=vs AI
ai_difficulty:  defb    0               ; 0=easy, 1=medium, 2=hard
cursor_row:     defb    0
cursor_col:     defb    0
key_pressed:    defb    0
last_key:       defb    0               ; Previous frame's key for repeat detection
key_timer:      defb    0               ; Countdown for key repeat delay
ai_timer:       defb    0               ; Countdown before AI moves
current_player: defb    1
p1_count:       defb    0
p2_count:       defb    0
board_state:    defs    64, 0

; ----------------------------------------------------------------------------
; Custom Character Set (768 bytes for characters 32-127)
; ----------------------------------------------------------------------------
; This area will be filled with ROM charset at startup,
; then we can modify specific characters for custom graphics

custom_charset: defs    768, 0

; ----------------------------------------------------------------------------
; End
; ----------------------------------------------------------------------------

            end     start
