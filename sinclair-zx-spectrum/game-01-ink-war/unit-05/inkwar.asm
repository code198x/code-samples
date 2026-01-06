;══════════════════════════════════════════════════════════════
; INK WAR
; A territory control game for the ZX Spectrum
; Unit 5: Turn Logic
;══════════════════════════════════════════════════════════════

        org $8000

;───────────────────────────────────────
; Constants
;───────────────────────────────────────
ATTR_BASE       equ 22528       ; Start of attribute memory
BOARD_ATTR      equ 22664       ; Board starts at row 4, col 8
BOARD_SIZE      equ 8           ; 8x8 game cells

; Colours (paper * 8 + ink)
WHITE_ON_WHITE  equ %00111111   ; Paper 7, Ink 7
RED_ON_RED      equ %00010010   ; Paper 2, Ink 2
CYAN_ON_CYAN    equ %00101101   ; Paper 5, Ink 5

; Keyboard half-rows (accent address for IN)
KEY_ROW_QAOP    equ $FB         ; Row: Q, A (bit 0 = Q, bit 1 = A... no wait)
KEY_ROW_Q       equ $FB         ; Q W E R T
KEY_ROW_A       equ $FD         ; A S D F G
KEY_ROW_P       equ $DF         ; P O I U Y
KEY_ROW_SPACE   equ $7F         ; SPACE, SYMBOL SHIFT, M, N, B

; Movement delay (frames between moves)
MOVE_DELAY      equ 8

;───────────────────────────────────────
; Entry point
;───────────────────────────────────────
start:
        ; Clear screen to black
        call clear_screen

        ; Draw the game board
        call draw_board

        ; Highlight cursor at starting position
        ld a, (cursor_y)
        ld b, a
        ld a, (cursor_x)
        ld c, a
        call get_cell_addr
        call highlight_cursor

        ; Set initial turn indicator (Player 1 = Red border)
        call update_ui_colours

        ; Set up interrupts for timing
        im 1
        ei

        ; Main loop
main_loop:
        halt                    ; Wait for vsync (50Hz timing)

        call check_keyboard

        jr main_loop

;───────────────────────────────────────
; Clear screen to black
;───────────────────────────────────────
clear_screen:
        ; Clear pixel memory
        ld hl, 16384
        ld de, 16385
        ld bc, 6143
        ld (hl), 0
        ldir

        ; Clear attributes to black on black
        ld hl, ATTR_BASE
        ld de, ATTR_BASE + 1
        ld bc, 767
        ld (hl), 0
        ldir
        ret

;───────────────────────────────────────
; Draw the 8x8 game board
; All cells start as white (neutral)
;───────────────────────────────────────
draw_board:
        ld hl, BOARD_ATTR
        ld b, BOARD_SIZE        ; 8 rows of game cells

.row_loop:
        push bc
        ld b, BOARD_SIZE        ; 8 columns of game cells

.cell_loop:
        push bc
        push hl

        ; Fill 2x2 character block with white
        ld a, WHITE_ON_WHITE

        ; Top-left
        ld (hl), a
        ; Top-right
        inc hl
        ld (hl), a
        ; Bottom-left (next row, back one column)
        ld de, 31
        add hl, de
        ld (hl), a
        ; Bottom-right
        inc hl
        ld (hl), a

        pop hl
        ; Move to next cell (2 columns right)
        inc hl
        inc hl

        pop bc
        djnz .cell_loop

        ; Move to next row of cells
        pop bc
        push bc
        ld a, BOARD_SIZE
        sub b                   ; A = rows completed (1-8)
        inc a                   ; A = next row number

        ; Calculate: BOARD_ATTR + (row * 64)
        ld h, 0
        ld l, a
        add hl, hl              ; × 2
        add hl, hl              ; × 4
        add hl, hl              ; × 8
        add hl, hl              ; × 16
        add hl, hl              ; × 32
        add hl, hl              ; × 64
        ld de, BOARD_ATTR
        add hl, de

        pop bc
        djnz .row_loop

        ret

;───────────────────────────────────────
; Get attribute address for a game cell
; Input: B = row (0-7), C = column (0-7)
; Output: HL = address of top-left attribute
;───────────────────────────────────────
get_cell_addr:
        ld hl, BOARD_ATTR

        ; Add row offset: y × 64
        ld a, b
        rlca
        rlca
        rlca
        rlca
        rlca
        rlca
        ld e, a
        ld d, 0
        add hl, de

        ; Add column offset: x × 2
        ld a, c
        add a, a
        ld e, a
        ld d, 0
        add hl, de

        ret

;───────────────────────────────────────
; Highlight a cell by setting FLASH bit
; Input: HL = address of top-left attribute
;───────────────────────────────────────
highlight_cursor:
        ; Top-left
        ld a, (hl)
        set 7, a
        ld (hl), a

        ; Top-right
        inc hl
        ld a, (hl)
        set 7, a
        ld (hl), a

        ; Move to bottom-left (31 bytes forward)
        ld de, 31
        add hl, de

        ; Bottom-left
        ld a, (hl)
        set 7, a
        ld (hl), a

        ; Bottom-right
        inc hl
        ld a, (hl)
        set 7, a
        ld (hl), a

        ret

;───────────────────────────────────────
; Clear cursor highlight (remove FLASH)
; Input: HL = address of top-left attribute
;───────────────────────────────────────
clear_cursor:
        ; Top-left
        ld a, (hl)
        res 7, a
        ld (hl), a

        ; Top-right
        inc hl
        ld a, (hl)
        res 7, a
        ld (hl), a

        ; Move to bottom-left
        ld de, 31
        add hl, de

        ; Bottom-left
        ld a, (hl)
        res 7, a
        ld (hl), a

        ; Bottom-right
        inc hl
        ld a, (hl)
        res 7, a
        ld (hl), a

        ret

;───────────────────────────────────────
; Get cursor's current attribute address
; Output: HL = address
;───────────────────────────────────────
get_cursor_addr:
        ld a, (cursor_y)
        ld b, a
        ld a, (cursor_x)
        ld c, a
        call get_cell_addr
        ret

;───────────────────────────────────────
; Check keyboard and handle input
;───────────────────────────────────────
check_keyboard:
        ; Check SPACE for claiming (edge detection)
        ld a, $7F               ; SPACE row
        in a, ($FE)
        bit 0, a                ; SPACE is bit 0
        jr nz, .space_not_pressed

        ; SPACE is pressed - check if it was already held
        ld a, (space_held)
        or a
        jr nz, .check_movement  ; Already held - ignore

        ; New press! Mark as held and claim
        ld a, 1
        ld (space_held), a
        call claim_cell
        jr .check_movement

.space_not_pressed:
        ; Clear the held flag
        xor a
        ld (space_held), a

.check_movement:
        ; Check movement delay
        ld a, (move_delay)
        or a
        jr z, .can_move

        ; Still in delay - decrement and return
        dec a
        ld (move_delay), a
        ret

.can_move:
        ; Check Q (up)
        ld a, $FB
        in a, ($FE)
        bit 0, a
        jr nz, .not_up
        call move_up
        ret

.not_up:
        ; Check A (down)
        ld a, $FD
        in a, ($FE)
        bit 0, a
        jr nz, .not_down
        call move_down
        ret

.not_down:
        ; Check O (left)
        ld a, $DF
        in a, ($FE)
        bit 1, a
        jr nz, .not_left
        call move_left
        ret

.not_left:
        ; Check P (right)
        ld a, $DF
        in a, ($FE)
        bit 0, a
        jr nz, .not_right
        call move_right
        ret

.not_right:
        ret

;───────────────────────────────────────
; Movement routines
;───────────────────────────────────────
move_up:
        ld a, (cursor_y)
        or a
        ret z                   ; Already at top

        ; Clear old cursor
        call get_cursor_addr
        call clear_cursor

        ; Move up
        ld a, (cursor_y)
        dec a
        ld (cursor_y), a

        ; Highlight new position
        call get_cursor_addr
        call highlight_cursor

        ; Reset delay
        ld a, MOVE_DELAY
        ld (move_delay), a
        ret

move_down:
        ld a, (cursor_y)
        cp 7
        ret z                   ; Already at bottom

        call get_cursor_addr
        call clear_cursor

        ld a, (cursor_y)
        inc a
        ld (cursor_y), a

        call get_cursor_addr
        call highlight_cursor

        ld a, MOVE_DELAY
        ld (move_delay), a
        ret

move_left:
        ld a, (cursor_x)
        or a
        ret z                   ; Already at left edge

        call get_cursor_addr
        call clear_cursor

        ld a, (cursor_x)
        dec a
        ld (cursor_x), a

        call get_cursor_addr
        call highlight_cursor

        ld a, MOVE_DELAY
        ld (move_delay), a
        ret

move_right:
        ld a, (cursor_x)
        cp 7
        ret z                   ; Already at right edge

        call get_cursor_addr
        call clear_cursor

        ld a, (cursor_x)
        inc a
        ld (cursor_x), a

        call get_cursor_addr
        call highlight_cursor

        ld a, MOVE_DELAY
        ld (move_delay), a
        ret

;───────────────────────────────────────
; Get board state address for a game cell
; Input: B = row (0-7), C = column (0-7)
; Output: HL = address in board_state
;───────────────────────────────────────
get_board_addr:
        ld hl, board_state

        ; Calculate offset: y × 8 + x
        ld a, b
        rlca
        rlca
        rlca                    ; × 8
        add a, c                ; + x
        ld e, a
        ld d, 0
        add hl, de

        ret

;───────────────────────────────────────
; Claim the current cell for the current player
; Swaps player after successful claim
;───────────────────────────────────────
claim_cell:
        ; Get cursor position
        ld a, (cursor_x)
        ld c, a
        ld a, (cursor_y)
        ld b, a

        ; Get board state address
        call get_board_addr

        ; Check if already owned
        ld a, (hl)
        or a
        jr z, .claim_it         ; Empty - can claim

        ; Already owned by someone - can't claim
        ret

.claim_it:
        ; Mark cell as owned by current player
        ld a, (current_player)
        ld (hl), a

        ; Update the display
        ld a, (cursor_x)
        ld c, a
        ld a, (cursor_y)
        ld b, a
        call get_cell_addr
        call set_cell_colour

        ; Swap to other player
        call swap_player
        ret

;───────────────────────────────────────
; Set the colour of a cell based on current player
; Input: HL = address of top-left attribute
;───────────────────────────────────────
set_cell_colour:
        ; Get colour for current player
        ld a, (current_player)
        cp 1
        jr nz, .player_2
        ld a, RED_ON_RED
        jr .set_colour
.player_2:
        ld a, CYAN_ON_CYAN

.set_colour:
        ; Preserve FLASH bit from cursor
        ld b, a                 ; Save colour in B

        ; Top-left
        ld a, (hl)
        and %10000000           ; Keep FLASH bit
        or b                    ; Add colour
        ld (hl), a

        ; Top-right
        inc hl
        ld a, (hl)
        and %10000000
        or b
        ld (hl), a

        ; Move to bottom-left
        ld de, 31
        add hl, de

        ; Bottom-left
        ld a, (hl)
        and %10000000
        or b
        ld (hl), a

        ; Bottom-right
        inc hl
        ld a, (hl)
        and %10000000
        or b
        ld (hl), a

        ret

;───────────────────────────────────────
; Swap to the other player
;───────────────────────────────────────
swap_player:
        ld a, (current_player)
        xor 3                   ; 1 XOR 3 = 2, 2 XOR 3 = 1
        ld (current_player), a
        call update_ui_colours
        ret

;───────────────────────────────────────
; Update border colour to show current player
;───────────────────────────────────────
update_ui_colours:
        ld a, (current_player)
        cp 1
        jr nz, .uuc_player_2
        ld a, 2                 ; Red border for Player 1
        jr .uuc_set_border
.uuc_player_2:
        ld a, 5                 ; Cyan border for Player 2
.uuc_set_border:
        out (254), a
        ret

;───────────────────────────────────────
; Variables
;───────────────────────────────────────
cursor_x:       defb 0          ; Column (0-7)
cursor_y:       defb 0          ; Row (0-7)
move_delay:     defb 0          ; Frames until next move allowed
space_held:     defb 0          ; 1 if SPACE was held last frame
current_player: defb 1          ; 1 = Red (Player 1), 2 = Cyan (Player 2)

;───────────────────────────────────────
; Board state (64 bytes, one per cell)
; 0 = empty, 1 = Player 1, 2 = Player 2
;───────────────────────────────────────
board_state:    defs 64, 0

        end start
