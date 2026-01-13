; ============================================================================
; INK WAR - Unit 3: Making It Yours
; ============================================================================
; Customised version demonstrating attribute control:
; - Cyan board cells (not white)
; - Yellow border cells around the board
; - Screen border changes colour with current player
; - Bright cursor (not flashing)
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

; ============================================================================
; CUSTOMISATION SECTION - Change these values to personalise your game!
; ============================================================================

; Attribute format: %FBPPPIII
;   F = Flash (bit 7): 1 = flashing
;   B = Bright (bit 6): 1 = brighter colours
;   PPP = Paper colour (bits 5-3): background
;   III = Ink colour (bits 2-0): foreground
;
; Colour values (0-7):
;   0=Black, 1=Blue, 2=Red, 3=Magenta, 4=Green, 5=Cyan, 6=Yellow, 7=White

; Empty cells - CUSTOMISED: cyan instead of white
;   %01101000 = BRIGHT + Paper 5 (cyan) + Ink 0 (black)
EMPTY_ATTR  equ     %01101000       ; Cyan paper, black ink + BRIGHT

; Board border - CUSTOMISED: yellow border around playing area
;   %01110000 = BRIGHT + Paper 6 (yellow) + Ink 0 (black)
BORDER_ATTR equ     %01110000       ; Yellow paper, black ink + BRIGHT

; Cursor - CUSTOMISED: bright white instead of flashing
;   %01111000 = BRIGHT + Paper 7 (white) + Ink 0 (black)
CURSOR_ATTR equ     %01111000       ; White paper + BRIGHT (no flash)

; Player 1 - Red (unchanged)
P1_ATTR     equ     %01010000       ; Red paper + BRIGHT
P1_CURSOR   equ     %01111010       ; White paper + Red ink + BRIGHT

; Player 2 - Blue (unchanged)
P2_ATTR     equ     %01001000       ; Blue paper + BRIGHT
P2_CURSOR   equ     %01111001       ; White paper + Blue ink + BRIGHT

; Screen border colours for each player
P1_BORDER   equ     2               ; Red border for Player 1's turn
P2_BORDER   equ     1               ; Blue border for Player 2's turn

; ============================================================================
; End of customisation section
; ============================================================================

; Keyboard ports (active low)
KEY_PORT    equ     $fe
ROW_QAOP    equ     $fb
ROW_ASDF    equ     $fd
ROW_YUIOP   equ     $df
ROW_SPACE   equ     $7f

; Game states
STATE_EMPTY equ     0
STATE_P1    equ     1
STATE_P2    equ     2

; ----------------------------------------------------------------------------
; Entry Point
; ----------------------------------------------------------------------------

start:
            call    init_screen
            call    init_game
            call    draw_board_border   ; NEW: Draw visible border
            call    draw_board
            call    draw_cursor
            call    update_border       ; Set initial border colour

main_loop:
            halt

            call    read_keyboard
            call    handle_input

            jp      main_loop

; ----------------------------------------------------------------------------
; Initialise Screen
; ----------------------------------------------------------------------------

init_screen:
            xor     a
            out     (KEY_PORT), a

            ld      hl, ATTR_BASE
            ld      de, ATTR_BASE+1
            ld      bc, 767
            ld      (hl), 0
            ldir

            ret

; ----------------------------------------------------------------------------
; Update Screen Border
; ----------------------------------------------------------------------------
; Sets border colour based on current player

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
.clear_loop:
            ld      (hl), a
            inc     hl
            djnz    .clear_loop

            ld      a, 1
            ld      (current_player), a

            xor     a
            ld      (cursor_row), a
            ld      (cursor_col), a

            ret

; ----------------------------------------------------------------------------
; Draw Board Border
; ----------------------------------------------------------------------------
; Draws a visible border around the 8x8 playing area

draw_board_border:
            ; Top border (row 7, columns 11-20)
            ld      c, BOARD_ROW-1      ; Row 7
            ld      d, BOARD_COL-1      ; Start at column 11
            ld      b, BOARD_SIZE+2     ; 10 cells wide
            call    draw_border_row

            ; Bottom border (row 16, columns 11-20)
            ld      c, BOARD_ROW+BOARD_SIZE  ; Row 16
            ld      d, BOARD_COL-1
            ld      b, BOARD_SIZE+2
            call    draw_border_row

            ; Left border (rows 8-15, column 11)
            ld      c, BOARD_ROW        ; Start at row 8
            ld      d, BOARD_COL-1      ; Column 11
            ld      b, BOARD_SIZE       ; 8 cells tall
            call    draw_border_col

            ; Right border (rows 8-15, column 20)
            ld      c, BOARD_ROW
            ld      d, BOARD_COL+BOARD_SIZE  ; Column 20
            ld      b, BOARD_SIZE
            call    draw_border_col

            ret

; Draw horizontal border row
; C = row, D = start column, B = width
draw_border_row:
            push    bc
.row_loop:
            push    bc
            push    de

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

            ld      (hl), BORDER_ATTR

            pop     de
            pop     bc
            inc     d
            djnz    .row_loop
            pop     bc
            ret

; Draw vertical border column
; C = start row, D = column, B = height
draw_border_col:
            push    bc
.col_loop:
            push    bc
            push    de

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

            ld      (hl), BORDER_ATTR

            pop     de
            pop     bc
            inc     c
            djnz    .col_loop
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
            jr      z, .cc_p1
            cp      STATE_P2
            jr      z, .cc_p2

            ld      a, EMPTY_ATTR
            jr      .cc_set

.cc_p1:
            ld      a, P1_ATTR
            jr      .cc_set

.cc_p2:
            ld      a, P2_ATTR

.cc_set:
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
            jr      nz, .not_q
            ld      a, 1
            ld      (key_pressed), a
            ret
.not_q:
            ld      a, ROW_ASDF
            in      a, (KEY_PORT)
            bit     0, a
            jr      nz, .not_a
            ld      a, 2
            ld      (key_pressed), a
            ret
.not_a:
            ld      a, ROW_YUIOP
            in      a, (KEY_PORT)
            bit     1, a
            jr      nz, .not_o
            ld      a, 3
            ld      (key_pressed), a
            ret
.not_o:
            ld      a, ROW_YUIOP
            in      a, (KEY_PORT)
            bit     0, a
            jr      nz, .not_p
            ld      a, 4
            ld      (key_pressed), a
            ret
.not_p:
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
            ret     z

            cp      5
            jr      z, try_claim

            call    clear_cursor

            ld      a, (key_pressed)

            cp      1
            jr      nz, .not_up
            ld      a, (cursor_row)
            or      a
            jr      z, .done
            dec     a
            ld      (cursor_row), a
            jr      .done
.not_up:
            cp      2
            jr      nz, .not_down
            ld      a, (cursor_row)
            cp      BOARD_SIZE-1
            jr      z, .done
            inc     a
            ld      (cursor_row), a
            jr      .done
.not_down:
            cp      3
            jr      nz, .not_left
            ld      a, (cursor_col)
            or      a
            jr      z, .done
            dec     a
            ld      (cursor_col), a
            jr      .done
.not_left:
            cp      4
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
            call    get_cell_state
            or      a
            ret     nz

            call    claim_cell
            call    sound_claim

            ld      a, (current_player)
            xor     3
            ld      (current_player), a

            call    update_border       ; Update border for new player
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
            jr      z, .cc_is_p1
            ld      (hl), P2_ATTR
            ret
.cc_is_p1:
            ld      (hl), P1_ATTR
            ret

; ----------------------------------------------------------------------------
; Sound - Claim
; ----------------------------------------------------------------------------

sound_claim:
            ld      hl, 400
            ld      b, 20

.loop:
            push    bc
            push    hl

            ld      b, h
            ld      c, l
.tone_loop:
            ld      a, $10
            out     (KEY_PORT), a
            call    .delay
            xor     a
            out     (KEY_PORT), a
            call    .delay
            dec     bc
            ld      a, b
            or      c
            jr      nz, .tone_loop

            pop     hl
            pop     bc

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
current_player: defb    1
board_state:    defs    64, 0

; ----------------------------------------------------------------------------
; End
; ----------------------------------------------------------------------------

            end     start
