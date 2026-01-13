; ============================================================================
; INK WAR - Unit 1: Hello Spectrum
; ============================================================================
; A territory control game for the ZX Spectrum
; This scaffold provides: board display, cursor, keyboard movement
;
; Controls: Q=Up, A=Down, O=Left, P=Right
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

; Keyboard ports (active low)
KEY_PORT    equ     $fe
ROW_QAOP    equ     $fb             ; Q W E R T row (bits: T R E W Q)
ROW_ASDF    equ     $fd             ; A S D F G row (bits: G F D S A)
ROW_YUIOP   equ     $df             ; Y U I O P row (bits: P O I U Y)

; ----------------------------------------------------------------------------
; Entry Point
; ----------------------------------------------------------------------------

start:
            call    init_screen     ; Clear screen and set border
            call    draw_board      ; Draw the game board
            call    draw_cursor     ; Show cursor at starting position

main_loop:
            halt                    ; Wait for frame (50Hz timing)

            call    read_keyboard   ; Check for input
            call    move_cursor     ; Update cursor if moved

            jp      main_loop       ; Repeat forever

; ----------------------------------------------------------------------------
; Initialise Screen
; ----------------------------------------------------------------------------
; Clears the screen to black and sets border colour

init_screen:
            ; Set border to black
            xor     a               ; A = 0 (black)
            out     (KEY_PORT), a   ; Set border colour

            ; Clear attributes to black
            ld      hl, ATTR_BASE   ; Start of attributes
            ld      de, ATTR_BASE+1
            ld      bc, 767         ; 768 bytes - 1
            ld      (hl), 0         ; Black on black
            ldir                    ; Fill all attributes

            ret

; ----------------------------------------------------------------------------
; Draw Board
; ----------------------------------------------------------------------------
; Draws the 8x8 game board with border

draw_board:
            ; Draw border (10x10 area, black)
            ; Border is already black from init, so we just draw the cells

            ; Draw the 8x8 playing field (white cells)
            ld      b, BOARD_SIZE   ; 8 rows
            ld      c, BOARD_ROW    ; Start at row 8

.row_loop:
            push    bc

            ld      b, BOARD_SIZE   ; 8 columns
            ld      d, BOARD_COL    ; Start at column 12

.col_loop:
            push    bc

            ; Calculate attribute address: ATTR_BASE + row*32 + col
            ld      a, c            ; Row
            ld      l, a
            ld      h, 0
            add     hl, hl          ; *2
            add     hl, hl          ; *4
            add     hl, hl          ; *8
            add     hl, hl          ; *16
            add     hl, hl          ; *32
            ld      a, d            ; Column
            add     a, l
            ld      l, a
            ld      bc, ATTR_BASE
            add     hl, bc          ; HL = attribute address

            ld      (hl), EMPTY_ATTR ; Set to white (empty cell)

            pop     bc
            inc     d               ; Next column
            djnz    .col_loop

            pop     bc
            inc     c               ; Next row
            djnz    .row_loop

            ret

; ----------------------------------------------------------------------------
; Draw Cursor
; ----------------------------------------------------------------------------
; Shows the cursor at current position with FLASH attribute

draw_cursor:
            ; Calculate attribute address for cursor position
            ld      a, (cursor_row)
            add     a, BOARD_ROW    ; Add board offset
            ld      l, a
            ld      h, 0
            add     hl, hl          ; *32
            add     hl, hl
            add     hl, hl
            add     hl, hl
            add     hl, hl
            ld      a, (cursor_col)
            add     a, BOARD_COL    ; Add board offset
            add     a, l
            ld      l, a
            ld      bc, ATTR_BASE
            add     hl, bc

            ld      (hl), CURSOR_ATTR ; Set FLASH attribute

            ret

; ----------------------------------------------------------------------------
; Clear Cursor
; ----------------------------------------------------------------------------
; Removes cursor flash from current position

clear_cursor:
            ; Calculate attribute address for cursor position
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

            ld      (hl), EMPTY_ATTR ; Remove FLASH, back to white

            ret

; ----------------------------------------------------------------------------
; Read Keyboard
; ----------------------------------------------------------------------------
; Checks Q/A/O/P keys and sets direction flags

read_keyboard:
            xor     a
            ld      (key_pressed), a ; Clear previous

            ; Check Q (up) - port $FBFE, bit 0
            ld      a, ROW_QAOP
            in      a, (KEY_PORT)
            bit     0, a            ; Q is bit 0
            jr      nz, .not_q
            ld      a, 1            ; Up
            ld      (key_pressed), a
            ret
.not_q:
            ; Check A (down) - port $FDFE, bit 0
            ld      a, ROW_ASDF
            in      a, (KEY_PORT)
            bit     0, a            ; A is bit 0
            jr      nz, .not_a
            ld      a, 2            ; Down
            ld      (key_pressed), a
            ret
.not_a:
            ; Check O (left) - port $DFFE, bit 1
            ld      a, ROW_YUIOP
            in      a, (KEY_PORT)
            bit     1, a            ; O is bit 1
            jr      nz, .not_o
            ld      a, 3            ; Left
            ld      (key_pressed), a
            ret
.not_o:
            ; Check P (right) - port $DFFE, bit 0
            ld      a, ROW_YUIOP
            in      a, (KEY_PORT)
            bit     0, a            ; P is bit 0
            jr      nz, .not_p
            ld      a, 4            ; Right
            ld      (key_pressed), a
.not_p:
            ret

; ----------------------------------------------------------------------------
; Move Cursor
; ----------------------------------------------------------------------------
; Moves cursor based on key_pressed value

move_cursor:
            ld      a, (key_pressed)
            or      a
            ret     z               ; No key pressed

            call    clear_cursor    ; Remove old cursor

            ld      a, (key_pressed)

            cp      1               ; Up?
            jr      nz, .not_up
            ld      a, (cursor_row)
            or      a
            jr      z, .done        ; Already at top
            dec     a
            ld      (cursor_row), a
            jr      .done
.not_up:
            cp      2               ; Down?
            jr      nz, .not_down
            ld      a, (cursor_row)
            cp      BOARD_SIZE-1
            jr      z, .done        ; Already at bottom
            inc     a
            ld      (cursor_row), a
            jr      .done
.not_down:
            cp      3               ; Left?
            jr      nz, .not_left
            ld      a, (cursor_col)
            or      a
            jr      z, .done        ; Already at left
            dec     a
            ld      (cursor_col), a
            jr      .done
.not_left:
            cp      4               ; Right?
            jr      nz, .done
            ld      a, (cursor_col)
            cp      BOARD_SIZE-1
            jr      z, .done        ; Already at right
            inc     a
            ld      (cursor_col), a

.done:
            call    draw_cursor     ; Draw new cursor
            ret

; ----------------------------------------------------------------------------
; Variables
; ----------------------------------------------------------------------------

cursor_row: defb    0               ; Cursor row (0-7)
cursor_col: defb    0               ; Cursor column (0-7)
key_pressed: defb   0               ; Last key: 0=none, 1=up, 2=down, 3=left, 4=right

; ----------------------------------------------------------------------------
; End
; ----------------------------------------------------------------------------

            end     start
