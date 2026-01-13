; ============================================================================
; INK WAR - Unit 2: Claiming Cells
; ============================================================================
; Two players take turns claiming cells on the board.
; Press Space to claim the cell under the cursor.
;
; Controls: Q=Up, A=Down, O=Left, P=Right, SPACE=Claim
; ============================================================================

            org     32768

; ----------------------------------------------------------------------------
; Constants
; ----------------------------------------------------------------------------

ATTR_BASE   equ     $5800           ; Start of attribute memory
BOARD_ROW   equ     8               ; Board starts at row 8
BOARD_COL   equ     12              ; Board starts at column 12
BOARD_SIZE  equ     8               ; 8x8 playing field

; Attribute colours (FBPPPIII format)
BORDER_ATTR equ     %00000000       ; Black on black (border)
EMPTY_ATTR  equ     %00111000       ; White paper, black ink (empty cell)
CURSOR_ATTR equ     %10111000       ; White paper, black ink + FLASH
P1_ATTR     equ     %01010000       ; Red paper, black ink + BRIGHT (Player 1)
P2_ATTR     equ     %01001000       ; Blue paper, black ink + BRIGHT (Player 2)
P1_CURSOR   equ     %11010000       ; Red paper + FLASH (Player 1 cursor on own cell)
P2_CURSOR   equ     %11001000       ; Blue paper + FLASH (Player 2 cursor on own cell)

; Keyboard ports (active low)
KEY_PORT    equ     $fe
ROW_QAOP    equ     $fb             ; Q W E R T row
ROW_ASDF    equ     $fd             ; A S D F G row
ROW_YUIOP   equ     $df             ; Y U I O P row
ROW_SPACE   equ     $7f             ; SPACE SYM M N B row

; Game states
STATE_EMPTY equ     0
STATE_P1    equ     1
STATE_P2    equ     2

; ----------------------------------------------------------------------------
; Entry Point
; ----------------------------------------------------------------------------

start:
            call    init_screen     ; Clear screen and set border
            call    init_game       ; Initialise game state
            call    draw_board      ; Draw the game board
            call    draw_cursor     ; Show cursor at starting position

main_loop:
            halt                    ; Wait for frame (50Hz timing)

            call    read_keyboard   ; Check for input
            call    handle_input    ; Process movement or claim

            jp      main_loop       ; Repeat forever

; ----------------------------------------------------------------------------
; Initialise Screen
; ----------------------------------------------------------------------------

init_screen:
            xor     a
            out     (KEY_PORT), a   ; Black border

            ld      hl, ATTR_BASE
            ld      de, ATTR_BASE+1
            ld      bc, 767
            ld      (hl), 0
            ldir

            ret

; ----------------------------------------------------------------------------
; Initialise Game State
; ----------------------------------------------------------------------------

init_game:
            ; Clear board state (all empty)
            ld      hl, board_state
            ld      b, 64
            xor     a
.clear_loop:
            ld      (hl), a
            inc     hl
            djnz    .clear_loop

            ; Player 1 starts
            ld      a, 1
            ld      (current_player), a

            ; Cursor at top-left
            xor     a
            ld      (cursor_row), a
            ld      (cursor_col), a

            ret

; ----------------------------------------------------------------------------
; Draw Board
; ----------------------------------------------------------------------------

draw_board:
            ld      b, BOARD_SIZE
            ld      c, BOARD_ROW

.row_loop:
            push    bc

            ld      b, BOARD_SIZE
            ld      d, BOARD_COL

.col_loop:
            push    bc

            ; Calculate attribute address
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
            djnz    .col_loop

            pop     bc
            inc     c
            djnz    .row_loop

            ret

; ----------------------------------------------------------------------------
; Draw Cursor
; ----------------------------------------------------------------------------
; Shows cursor with appropriate colour based on cell state

draw_cursor:
            ; Get cell state at cursor position
            call    get_cell_state  ; A = state at cursor

            ; Determine cursor attribute based on state
            cp      STATE_P1
            jr      z, .dc_p1
            cp      STATE_P2
            jr      z, .dc_p2

            ; Empty cell - use standard cursor
            ld      a, CURSOR_ATTR
            jr      .dc_set

.dc_p1:
            ld      a, P1_CURSOR
            jr      .dc_set

.dc_p2:
            ld      a, P2_CURSOR

.dc_set:
            push    af              ; Save attribute

            ; Calculate attribute address
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

            pop     af              ; Restore attribute
            ld      (hl), a

            ret

; ----------------------------------------------------------------------------
; Clear Cursor
; ----------------------------------------------------------------------------
; Restores cell to its proper colour (empty, P1, or P2)

clear_cursor:
            ; Get cell state
            call    get_cell_state

            ; Determine attribute based on state
            cp      STATE_P1
            jr      z, .cc_p1
            cp      STATE_P2
            jr      z, .cc_p2

            ; Empty cell
            ld      a, EMPTY_ATTR
            jr      .cc_set

.cc_p1:
            ld      a, P1_ATTR
            jr      .cc_set

.cc_p2:
            ld      a, P2_ATTR

.cc_set:
            push    af

            ; Calculate attribute address
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
; Returns: A = state at cursor position (0=empty, 1=P1, 2=P2)

get_cell_state:
            ld      a, (cursor_row)
            add     a, a            ; *2
            add     a, a            ; *4
            add     a, a            ; *8
            ld      hl, board_state
            ld      b, 0
            ld      c, a
            add     hl, bc
            ld      a, (cursor_col)
            ld      c, a
            add     hl, bc          ; HL = &board_state[row*8+col]
            ld      a, (hl)
            ret

; ----------------------------------------------------------------------------
; Read Keyboard
; ----------------------------------------------------------------------------

read_keyboard:
            xor     a
            ld      (key_pressed), a

            ; Check Q (up)
            ld      a, ROW_QAOP
            in      a, (KEY_PORT)
            bit     0, a
            jr      nz, .not_q
            ld      a, 1
            ld      (key_pressed), a
            ret
.not_q:
            ; Check A (down)
            ld      a, ROW_ASDF
            in      a, (KEY_PORT)
            bit     0, a
            jr      nz, .not_a
            ld      a, 2
            ld      (key_pressed), a
            ret
.not_a:
            ; Check O (left)
            ld      a, ROW_YUIOP
            in      a, (KEY_PORT)
            bit     1, a
            jr      nz, .not_o
            ld      a, 3
            ld      (key_pressed), a
            ret
.not_o:
            ; Check P (right)
            ld      a, ROW_YUIOP
            in      a, (KEY_PORT)
            bit     0, a
            jr      nz, .not_p
            ld      a, 4
            ld      (key_pressed), a
            ret
.not_p:
            ; Check SPACE (claim)
            ld      a, ROW_SPACE
            in      a, (KEY_PORT)
            bit     0, a
            jr      nz, .not_space
            ld      a, 5
            ld      (key_pressed), a
.not_space:
            ret

; ----------------------------------------------------------------------------
; Handle Input
; ----------------------------------------------------------------------------

handle_input:
            ld      a, (key_pressed)
            or      a
            ret     z               ; No key

            cp      5               ; Space?
            jr      z, try_claim

            ; Movement key - use existing move logic
            call    clear_cursor

            ld      a, (key_pressed)

            cp      1               ; Up?
            jr      nz, .not_up
            ld      a, (cursor_row)
            or      a
            jr      z, .done
            dec     a
            ld      (cursor_row), a
            jr      .done
.not_up:
            cp      2               ; Down?
            jr      nz, .not_down
            ld      a, (cursor_row)
            cp      BOARD_SIZE-1
            jr      z, .done
            inc     a
            ld      (cursor_row), a
            jr      .done
.not_down:
            cp      3               ; Left?
            jr      nz, .not_left
            ld      a, (cursor_col)
            or      a
            jr      z, .done
            dec     a
            ld      (cursor_col), a
            jr      .done
.not_left:
            cp      4               ; Right?
            jr      nz, .done
            ld      a, (cursor_col)
            cp      BOARD_SIZE-1
            jr      z, .done
            inc     a
            ld      (cursor_col), a

.done:
            call    draw_cursor
            ret

; ----------------------------------------------------------------------------
; Try Claim Cell
; ----------------------------------------------------------------------------

try_claim:
            ; Check if cell is empty
            call    get_cell_state
            or      a
            ret     nz              ; Not empty - can't claim

            ; Claim the cell
            call    claim_cell

            ; Play success sound
            call    sound_claim

            ; Switch player
            ld      a, (current_player)
            xor     3               ; Toggle between 1 and 2
            ld      (current_player), a

            ; Redraw cursor with new state
            call    draw_cursor

            ret

; ----------------------------------------------------------------------------
; Claim Cell
; ----------------------------------------------------------------------------
; Claims current cell for current player

claim_cell:
            ; Calculate board state index
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
            add     hl, bc          ; HL = &board_state[row*8+col]

            ; Set to current player
            ld      a, (current_player)
            ld      (hl), a

            ; Update attribute colour
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
            jr      z, .player1
            ld      (hl), P2_ATTR
            ret
.player1:
            ld      (hl), P1_ATTR
            ret

; ----------------------------------------------------------------------------
; Sound - Claim
; ----------------------------------------------------------------------------
; Short rising tone for successful claim

sound_claim:
            ld      hl, 400         ; Starting pitch
            ld      b, 20           ; Duration

.loop:
            push    bc
            push    hl

            ; Generate tone
            ld      b, h
            ld      c, l
.tone_loop:
            ld      a, $10          ; Speaker bit on
            out     (KEY_PORT), a
            call    .delay
            xor     a               ; Speaker bit off
            out     (KEY_PORT), a
            call    .delay
            dec     bc
            ld      a, b
            or      c
            jr      nz, .tone_loop

            pop     hl
            pop     bc

            ; Increase pitch (lower delay = higher frequency)
            ld      de, 20
            or      a
            sbc     hl, de

            djnz    .loop
            ret

.delay:
            push    bc
            ld      b, 5
.delay_loop:
            djnz    .delay_loop
            pop     bc
            ret

; ----------------------------------------------------------------------------
; Variables
; ----------------------------------------------------------------------------

cursor_row:     defb    0
cursor_col:     defb    0
key_pressed:    defb    0
current_player: defb    1           ; 1 = Player 1 (Red), 2 = Player 2 (Blue)
board_state:    defs    64, 0       ; 64 bytes, all initialised to 0

; ----------------------------------------------------------------------------
; End
; ----------------------------------------------------------------------------

            end     start
