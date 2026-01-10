; Ink War - Unit 06: The Cursor
; A movable cursor on the game board
;
; Learning objectives:
; - Track cursor position in memory
; - Draw and erase the cursor
; - Move cursor with keyboard input
; - Constrain cursor to board boundaries

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

; Colours
BLACK_ATTR  equ %00000000
WHITE_ATTR  equ %00111111
EMPTY_ATTR  equ %00111000   ; White paper, black ink
CURSOR_ATTR equ %01110000   ; Bright yellow paper, black ink (visible cursor)

; =============================================================================
; VARIABLES
; =============================================================================

cursor_row: defb 0          ; Current cursor row (0-7)
cursor_col: defb 0          ; Current cursor column (0-7)
prev_keys:  defb 0          ; Previous key state

; =============================================================================
; MAIN PROGRAM
; =============================================================================

start:
        ; Set border to black
        xor a
        out (BORDER_PORT), a

        ; Draw the game board
        call clear_screen
        call draw_border
        call draw_board

        ; Initialise cursor at centre
        ld a, 3
        ld (cursor_row), a
        ld (cursor_col), a

        ; Draw initial cursor
        call draw_cursor

main_loop:
        halt                ; Wait for vblank (50Hz timing)

        ; Read keys and move cursor
        call read_keys
        call move_cursor

        jr main_loop

; =============================================================================
; CURSOR ROUTINES
; =============================================================================

; -----------------------------------------------------------------------------
; Draw the cursor at current position
; Uses FLASH attribute to make it blink
; -----------------------------------------------------------------------------
draw_cursor:
        ld a, (cursor_row)
        ld b, a
        ld a, (cursor_col)
        ld c, a
        call get_cell_address   ; HL = attribute address

        ld a, CURSOR_ATTR       ; Flashing white
        ld (hl), a
        ret

; -----------------------------------------------------------------------------
; Erase the cursor (restore to empty cell colour)
; -----------------------------------------------------------------------------
erase_cursor:
        ld a, (cursor_row)
        ld b, a
        ld a, (cursor_col)
        ld c, a
        call get_cell_address

        ld a, EMPTY_ATTR        ; Normal white
        ld (hl), a
        ret

; -----------------------------------------------------------------------------
; Get attribute address for a board cell
; Input: B = row (0-7), C = column (0-7)
; Output: HL = attribute address
; -----------------------------------------------------------------------------
get_cell_address:
        ; Screen row = BOARD_TOP + B
        ld a, BOARD_TOP
        add a, b
        ld l, a
        ld h, 0

        ; Multiply by 32
        add hl, hl          ; ×2
        add hl, hl          ; ×4
        add hl, hl          ; ×8
        add hl, hl          ; ×16
        add hl, hl          ; ×32

        ; Add screen column
        ld a, BOARD_LEFT
        add a, c
        ld e, a
        ld d, 0
        add hl, de

        ; Add base address
        ld de, ATTR_START
        add hl, de
        ret

; =============================================================================
; INPUT ROUTINES
; =============================================================================

; -----------------------------------------------------------------------------
; Read keyboard into key state
; Returns: D = newly pressed keys
; -----------------------------------------------------------------------------
read_keys:
        ld e, 0             ; Build key state

        ; Q (up) - bit 0
        ld a, ROW_Q_T
        in a, (KEYBOARD_PORT)
        bit 0, a
        jr nz, not_q
        set 0, e
not_q:

        ; A (down) - bit 1
        ld a, ROW_A_G
        in a, (KEYBOARD_PORT)
        bit 0, a
        jr nz, not_a
        set 1, e
not_a:

        ; O (left) - bit 2
        ld a, ROW_P_Y
        in a, (KEYBOARD_PORT)
        bit 1, a
        jr nz, not_o
        set 2, e
not_o:

        ; P (right) - bit 3
        bit 0, a            ; Same row as O
        jr nz, not_p
        set 3, e
not_p:

        ; Space (action) - bit 4
        ld a, ROW_SPC_B
        in a, (KEYBOARD_PORT)
        bit 0, a
        jr nz, not_space
        set 4, e
not_space:

        ; Debounce: find newly pressed keys
        ld a, (prev_keys)
        cpl
        and e
        ld d, a             ; D = newly pressed

        ; Save current state
        ld a, e
        ld (prev_keys), a

        ret

; -----------------------------------------------------------------------------
; Move cursor based on key input
; Input: D = newly pressed keys (from read_keys)
; -----------------------------------------------------------------------------
move_cursor:
        ; Check if any movement key pressed
        ld a, d
        and %00001111       ; Mask to direction keys only
        ret z               ; Return if no movement

        ; Erase cursor at old position
        call erase_cursor

        ; Check Q (up) - bit 0
        bit 0, d
        jr z, not_up
        ld a, (cursor_row)
        or a                ; Check if already at top (0)
        jr z, not_up        ; Can't go higher
        dec a
        ld (cursor_row), a
not_up:

        ; Check A (down) - bit 1
        bit 1, d
        jr z, not_down
        ld a, (cursor_row)
        cp BOARD_SIZE - 1   ; Check if at bottom (7)
        jr z, not_down      ; Can't go lower
        inc a
        ld (cursor_row), a
not_down:

        ; Check O (left) - bit 2
        bit 2, d
        jr z, not_left
        ld a, (cursor_col)
        or a                ; Check if at left edge (0)
        jr z, not_left
        dec a
        ld (cursor_col), a
not_left:

        ; Check P (right) - bit 3
        bit 3, d
        jr z, not_right
        ld a, (cursor_col)
        cp BOARD_SIZE - 1   ; Check if at right edge (7)
        jr z, not_right
        inc a
        ld (cursor_col), a
not_right:

        ; Draw cursor at new position
        call draw_cursor
        ret

; =============================================================================
; SCREEN ROUTINES
; =============================================================================

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
