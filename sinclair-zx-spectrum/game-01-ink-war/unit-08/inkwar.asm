;══════════════════════════════════════════════════════════════
; INK WAR
; A territory control game for the ZX Spectrum
; Unit 8: Better AI
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

; Keyboard half-rows
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

        ; Give each player a starting corner
        call init_starting_cells

        ; Position cursor at (1,0) - adjacent to Player 1's corner
        ld a, 1
        ld (cursor_x), a
        xor a
        ld (cursor_y), a

        ; Highlight cursor at starting position
        ld b, 0
        ld c, 1
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

        ; Increment frame counter for AI randomness
        ld a, (frame_counter)
        inc a
        ld (frame_counter), a

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
; Set up starting cells for both players
;───────────────────────────────────────
init_starting_cells:
        ; Player 1 gets (0,0) - top-left
        ld hl, board_state
        ld (hl), 1

        ; Colour it red
        ld b, 0
        ld c, 0
        call get_cell_addr
        ld a, RED_ON_RED
        ld b, a
        call set_cell_direct

        ; Player 2 gets (7,7) - bottom-right
        ld hl, board_state + 63
        ld (hl), 2

        ; Colour it cyan
        ld b, 7
        ld c, 7
        call get_cell_addr
        ld a, CYAN_ON_CYAN
        ld b, a
        call set_cell_direct

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
        ld a, $7F
        in a, ($FE)
        bit 0, a
        jr nz, .space_not_pressed

        ; SPACE is pressed - check if it was already held
        ld a, (space_held)
        or a
        jr nz, .check_movement

        ; New press! Mark as held and claim
        ld a, 1
        ld (space_held), a
        call claim_cell
        jr .check_movement

.space_not_pressed:
        xor a
        ld (space_held), a

.check_movement:
        ; Check movement delay
        ld a, (move_delay)
        or a
        jr z, .can_move

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
        ret z

        call get_cursor_addr
        call clear_cursor

        ld a, (cursor_y)
        dec a
        ld (cursor_y), a

        call get_cursor_addr
        call highlight_cursor

        ld a, MOVE_DELAY
        ld (move_delay), a
        ret

move_down:
        ld a, (cursor_y)
        cp 7
        ret z

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
        ret z

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
        ret z

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
; Get the owner of a cell
; Input: B = row (0-7), C = column (0-7)
; Output: A = owner (0=empty, 1=Player 1, 2=Player 2)
;───────────────────────────────────────
get_owner:
        call get_board_addr
        ld a, (hl)
        ret

;───────────────────────────────────────
; Check if cursor is adjacent to current player's territory
; Output: Z flag set if valid (adjacent), NZ if invalid
;───────────────────────────────────────
check_adjacency:
        ; Check Up
        ld a, (cursor_y)
        or a
        jr z, .skip_up

        dec a
        ld b, a
        ld a, (cursor_x)
        ld c, a
        call get_owner
        ld b, a
        ld a, (current_player)
        cp b
        ret z

.skip_up:
        ; Check Down
        ld a, (cursor_y)
        cp 7
        jr z, .skip_down

        inc a
        ld b, a
        ld a, (cursor_x)
        ld c, a
        call get_owner
        ld b, a
        ld a, (current_player)
        cp b
        ret z

.skip_down:
        ; Check Left
        ld a, (cursor_x)
        or a
        jr z, .skip_left

        dec a
        ld c, a
        ld a, (cursor_y)
        ld b, a
        call get_owner
        ld b, a
        ld a, (current_player)
        cp b
        ret z

.skip_left:
        ; Check Right
        ld a, (cursor_x)
        cp 7
        jr z, .skip_right

        inc a
        ld c, a
        ld a, (cursor_y)
        ld b, a
        call get_owner
        ld b, a
        ld a, (current_player)
        cp b
        ret z

.skip_right:
        or 1
        ret

;───────────────────────────────────────
; Check if cell (B,C) is adjacent to current player's territory
; Input: B = y, C = x
; Output: Z flag set if valid (adjacent), NZ if invalid
;───────────────────────────────────────
check_adjacency_at:
        push bc

        ; Check Up
        ld a, b
        or a
        jr z, .skip_up

        dec a
        ld b, a
        call get_owner
        ld e, a
        ld a, (current_player)
        cp e
        jr z, .found

.skip_up:
        pop bc
        push bc

        ; Check Down
        ld a, b
        cp 7
        jr z, .skip_down

        inc a
        ld b, a
        call get_owner
        ld e, a
        ld a, (current_player)
        cp e
        jr z, .found

.skip_down:
        pop bc
        push bc

        ; Check Left
        ld a, c
        or a
        jr z, .skip_left

        dec a
        ld c, a
        call get_owner
        ld e, a
        ld a, (current_player)
        cp e
        jr z, .found

.skip_left:
        pop bc
        push bc

        ; Check Right
        ld a, c
        cp 7
        jr z, .skip_right

        inc a
        ld c, a
        call get_owner
        ld e, a
        ld a, (current_player)
        cp e
        jr z, .found

.skip_right:
        pop bc
        or 1
        ret

.found:
        pop bc
        xor a
        ret

;───────────────────────────────────────
; Claim the current cell for the current player
;───────────────────────────────────────
claim_cell:
        ; Get cursor position
        ld a, (cursor_x)
        ld c, a
        ld a, (cursor_y)
        ld b, a

        ; Check if empty
        call get_board_addr
        ld a, (hl)
        or a
        ret nz

        ; Check if adjacent
        call check_adjacency
        ret nz

        ; Valid! Claim it
        ld a, (cursor_x)
        ld c, a
        ld a, (cursor_y)
        ld b, a
        call get_board_addr
        ld a, (current_player)
        ld (hl), a

        ; Update display
        ld a, (cursor_x)
        ld c, a
        ld a, (cursor_y)
        ld b, a
        call get_cell_addr
        call set_cell_colour

        ; AI's turn
        call ai_think_delay
        call ai_pick_move
        call ai_make_move

        ret

;───────────────────────────────────────
; Set the colour of a cell based on current player
; Input: HL = address of top-left attribute
;───────────────────────────────────────
set_cell_colour:
        ld a, (current_player)
        cp 1
        jr nz, .player_2
        ld a, RED_ON_RED
        jr .set_colour
.player_2:
        ld a, CYAN_ON_CYAN

.set_colour:
        ld b, a

        ; Top-left
        ld a, (hl)
        and %10000000
        or b
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
; Set cell colour directly
; Input: HL = address, B = colour
;───────────────────────────────────────
set_cell_direct:
        ; Top-left
        ld a, (hl)
        and %10000000
        or b
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
; Swap player (kept for compatibility)
;───────────────────────────────────────
swap_player:
        ld a, (current_player)
        xor 3
        ld (current_player), a
        call update_ui_colours
        ret

;───────────────────────────────────────
; Update border colour to show current player
;───────────────────────────────────────
update_ui_colours:
        ld a, (current_player)
        cp 1
        jr nz, .player_2
        ld a, 2                 ; Red
        jr .set_border
.player_2:
        ld a, 5                 ; Cyan
.set_border:
        out (254), a
        ret

;───────────────────────────────────────
; AI: Pause to show "thinking"
;───────────────────────────────────────
ai_think_delay:
        ld b, 25
.delay_loop:
        halt
        djnz .delay_loop
        ret

;───────────────────────────────────────
; AI: Find the best move
;───────────────────────────────────────
ai_pick_move:
        xor a
        ld (best_score), a

        ; Set player to AI
        ld a, 2
        ld (current_player), a

        ; Scan all cells
        ld b, 0
.y_loop:
        ld c, 0
.x_loop:
        push bc

        ; Check if empty
        call get_owner
        or a
        jr nz, .skip

        ; Check if adjacent
        pop bc
        push bc
        call check_adjacency_at
        jr nz, .skip

        ; Score this cell
        pop bc
        push bc
        call score_cell

        ; Better than best?
        ld e, a
        ld a, (best_score)
        cp e
        jr nc, .skip

        ; New best!
        ld a, e
        ld (best_score), a
        pop bc
        push bc
        ld a, c
        ld (best_x), a
        ld a, b
        ld (best_y), a

.skip:
        pop bc
        inc c
        ld a, c
        cp 8
        jr nz, .x_loop

        inc b
        ld a, b
        cp 8
        jr nz, .y_loop

        ; Restore human player
        ld a, 1
        ld (current_player), a

        ret

;───────────────────────────────────────
; AI: Score a cell (improved with blocking + randomness)
; Input: B = y, C = x
; Output: A = score
;───────────────────────────────────────
score_cell:
        xor a
        ld (tmp_score), a

        push bc

        ; Score neighbours
        call score_neighbour_up
        pop bc
        push bc
        call score_neighbour_down
        pop bc
        push bc
        call score_neighbour_left
        pop bc
        push bc
        call score_neighbour_right

        ; Blocking bonus
        pop bc
        push bc
        call count_enemy_neighbours
        cp 2
        jr c, .no_block

        ld a, (tmp_score)
        add a, 4                ; Block bonus
        ld (tmp_score), a

.no_block:
        ; Random tie-breaker
        ld a, (frame_counter)
        and %00000001           ; 0 or 1
        ld b, a
        ld a, (tmp_score)
        add a, b
        ld (tmp_score), a

        pop bc
        ld a, (tmp_score)
        ret

;───────────────────────────────────────
; AI: Score neighbour above
;───────────────────────────────────────
score_neighbour_up:
        ld a, b
        or a
        ret z

        dec a
        ld b, a
        call get_owner

        or a
        jr z, .neutral
        cp 2
        jr z, .friendly
        ld a, (tmp_score)
        sub 2
        ld (tmp_score), a
        ret
.friendly:
        ld a, (tmp_score)
        add a, 3
        ld (tmp_score), a
        ret
.neutral:
        ld a, (tmp_score)
        inc a
        ld (tmp_score), a
        ret

;───────────────────────────────────────
; AI: Score neighbour below
;───────────────────────────────────────
score_neighbour_down:
        ld a, b
        cp 7
        ret z

        inc a
        ld b, a
        call get_owner

        or a
        jr z, .neutral
        cp 2
        jr z, .friendly
        ld a, (tmp_score)
        sub 2
        ld (tmp_score), a
        ret
.friendly:
        ld a, (tmp_score)
        add a, 3
        ld (tmp_score), a
        ret
.neutral:
        ld a, (tmp_score)
        inc a
        ld (tmp_score), a
        ret

;───────────────────────────────────────
; AI: Score neighbour to left
;───────────────────────────────────────
score_neighbour_left:
        ld a, c
        or a
        ret z

        dec a
        ld c, a
        call get_owner

        or a
        jr z, .neutral
        cp 2
        jr z, .friendly
        ld a, (tmp_score)
        sub 2
        ld (tmp_score), a
        ret
.friendly:
        ld a, (tmp_score)
        add a, 3
        ld (tmp_score), a
        ret
.neutral:
        ld a, (tmp_score)
        inc a
        ld (tmp_score), a
        ret

;───────────────────────────────────────
; AI: Score neighbour to right
;───────────────────────────────────────
score_neighbour_right:
        ld a, c
        cp 7
        ret z

        inc a
        ld c, a
        call get_owner

        or a
        jr z, .neutral
        cp 2
        jr z, .friendly
        ld a, (tmp_score)
        sub 2
        ld (tmp_score), a
        ret
.friendly:
        ld a, (tmp_score)
        add a, 3
        ld (tmp_score), a
        ret
.neutral:
        ld a, (tmp_score)
        inc a
        ld (tmp_score), a
        ret

;───────────────────────────────────────
; AI: Count enemy neighbours
; Input: B = y, C = x
; Output: A = count
;───────────────────────────────────────
count_enemy_neighbours:
        xor a
        ld (enemy_count), a
        push bc

        ; Check Up
        ld a, b
        or a
        jr z, .skip_up
        dec a
        ld b, a
        call get_owner
        cp 1
        jr nz, .skip_up
        ld a, (enemy_count)
        inc a
        ld (enemy_count), a
.skip_up:
        pop bc
        push bc

        ; Check Down
        ld a, b
        cp 7
        jr z, .skip_down
        inc a
        ld b, a
        call get_owner
        cp 1
        jr nz, .skip_down
        ld a, (enemy_count)
        inc a
        ld (enemy_count), a
.skip_down:
        pop bc
        push bc

        ; Check Left
        ld a, c
        or a
        jr z, .skip_left
        dec a
        ld c, a
        call get_owner
        cp 1
        jr nz, .skip_left
        ld a, (enemy_count)
        inc a
        ld (enemy_count), a
.skip_left:
        pop bc
        push bc

        ; Check Right
        ld a, c
        cp 7
        jr z, .skip_right
        inc a
        ld c, a
        call get_owner
        cp 1
        jr nz, .skip_right
        ld a, (enemy_count)
        inc a
        ld (enemy_count), a
.skip_right:
        pop bc

        ld a, (enemy_count)
        ret

;───────────────────────────────────────
; AI: Execute the chosen move
;───────────────────────────────────────
ai_make_move:
        ld a, (best_score)
        or a
        ret z

        ld a, 2
        ld (current_player), a

        ; Claim cell
        ld a, (best_y)
        ld b, a
        ld a, (best_x)
        ld c, a
        call get_board_addr
        ld a, 2
        ld (hl), a

        ; Update display
        ld a, (best_y)
        ld b, a
        ld a, (best_x)
        ld c, a
        call get_cell_addr
        call set_cell_colour

        ; Back to human
        ld a, 1
        ld (current_player), a
        call update_ui_colours

        ret

;───────────────────────────────────────
; Variables
;───────────────────────────────────────
cursor_x:       defb 0
cursor_y:       defb 0
move_delay:     defb 0
space_held:     defb 0
current_player: defb 1
frame_counter:  defb 0          ; For AI randomness

;───────────────────────────────────────
; AI variables
;───────────────────────────────────────
best_score:     defb 0
best_x:         defb 0
best_y:         defb 0
tmp_score:      defb 0
enemy_count:    defb 0

;───────────────────────────────────────
; Board state
;───────────────────────────────────────
board_state:    defs 64, 0

        end start
