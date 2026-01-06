;══════════════════════════════════════════════════════════════
; INK WAR
; A territory control game for the ZX Spectrum
; Unit 11: Sound Effects
;══════════════════════════════════════════════════════════════

        org $8000

;───────────────────────────────────────
; Constants
;───────────────────────────────────────
ATTR_BASE       equ 22528
BOARD_ATTR      equ 22664
BOARD_SIZE      equ 8

; Colours (paper * 8 + ink)
WHITE_ON_WHITE  equ %00111111
RED_ON_RED      equ %00010010
CYAN_ON_CYAN    equ %00101101

; Keyboard half-rows
KEY_ROW_Q       equ $FB
KEY_ROW_A       equ $FD
KEY_ROW_P       equ $DF
KEY_ROW_SPACE   equ $7F

; Movement delay
MOVE_DELAY      equ 8

; ROM routines
OPEN_CHANNEL    equ $1601

;───────────────────────────────────────
; Entry point
;───────────────────────────────────────
start:
        call clear_screen
        call draw_board
        call init_starting_cells

        ; Position cursor
        ld a, 1
        ld (cursor_x), a
        xor a
        ld (cursor_y), a

        ; Highlight cursor
        ld b, 0
        ld c, 1
        call get_cell_addr
        call highlight_cursor

        call update_ui_colours

        im 1
        ei

main_loop:
        halt

        ; Increment frame counter
        ld a, (frame_counter)
        inc a
        ld (frame_counter), a

        call check_keyboard

        jr main_loop

;───────────────────────────────────────
; Clear screen to black
;───────────────────────────────────────
clear_screen:
        ld hl, 16384
        ld de, 16385
        ld bc, 6143
        ld (hl), 0
        ldir

        ld hl, ATTR_BASE
        ld de, ATTR_BASE + 1
        ld bc, 767
        ld (hl), 0
        ldir
        ret

;───────────────────────────────────────
; Draw the 8x8 game board
;───────────────────────────────────────
draw_board:
        ld hl, BOARD_ATTR
        ld b, BOARD_SIZE

.row_loop:
        push bc
        ld b, BOARD_SIZE

.cell_loop:
        push bc
        push hl

        ld a, WHITE_ON_WHITE
        ld (hl), a
        inc hl
        ld (hl), a
        ld de, 31
        add hl, de
        ld (hl), a
        inc hl
        ld (hl), a

        pop hl
        inc hl
        inc hl

        pop bc
        djnz .cell_loop

        pop bc
        push bc
        ld a, BOARD_SIZE
        sub b
        inc a

        ld h, 0
        ld l, a
        add hl, hl
        add hl, hl
        add hl, hl
        add hl, hl
        add hl, hl
        add hl, hl
        ld de, BOARD_ATTR
        add hl, de

        pop bc
        djnz .row_loop

        ret

;───────────────────────────────────────
; Set up starting cells
;───────────────────────────────────────
init_starting_cells:
        ld hl, board_state
        ld (hl), 1

        ld b, 0
        ld c, 0
        call get_cell_addr
        ld a, RED_ON_RED
        ld b, a
        call set_cell_direct

        ld hl, board_state + 63
        ld (hl), 2

        ld b, 7
        ld c, 7
        call get_cell_addr
        ld a, CYAN_ON_CYAN
        ld b, a
        call set_cell_direct

        ret

;───────────────────────────────────────
; Get attribute address for a game cell
;───────────────────────────────────────
get_cell_addr:
        ld hl, BOARD_ATTR

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

        ld a, c
        add a, a
        ld e, a
        ld d, 0
        add hl, de

        ret

;───────────────────────────────────────
; Highlight a cell (set FLASH)
;───────────────────────────────────────
highlight_cursor:
        ld a, (hl)
        set 7, a
        ld (hl), a

        inc hl
        ld a, (hl)
        set 7, a
        ld (hl), a

        ld de, 31
        add hl, de

        ld a, (hl)
        set 7, a
        ld (hl), a

        inc hl
        ld a, (hl)
        set 7, a
        ld (hl), a

        ret

;───────────────────────────────────────
; Clear cursor (remove FLASH)
;───────────────────────────────────────
clear_cursor:
        ld a, (hl)
        res 7, a
        ld (hl), a

        inc hl
        ld a, (hl)
        res 7, a
        ld (hl), a

        ld de, 31
        add hl, de

        ld a, (hl)
        res 7, a
        ld (hl), a

        inc hl
        ld a, (hl)
        res 7, a
        ld (hl), a

        ret

;───────────────────────────────────────
; Get cursor's attribute address
;───────────────────────────────────────
get_cursor_addr:
        ld a, (cursor_y)
        ld b, a
        ld a, (cursor_x)
        ld c, a
        call get_cell_addr
        ret

;───────────────────────────────────────
; Check keyboard
;───────────────────────────────────────
check_keyboard:
        ; Check SPACE
        ld a, $7F
        in a, ($FE)
        bit 0, a
        jr nz, .space_not_pressed

        ld a, (space_held)
        or a
        jr nz, .check_movement

        ld a, 1
        ld (space_held), a
        call claim_cell
        jr .check_movement

.space_not_pressed:
        xor a
        ld (space_held), a

.check_movement:
        ld a, (move_delay)
        or a
        jr z, .can_move

        dec a
        ld (move_delay), a
        ret

.can_move:
        ld a, $FB
        in a, ($FE)
        bit 0, a
        jr nz, .not_up
        call move_up
        ret

.not_up:
        ld a, $FD
        in a, ($FE)
        bit 0, a
        jr nz, .not_down
        call move_down
        ret

.not_down:
        ld a, $DF
        in a, ($FE)
        bit 1, a
        jr nz, .not_left
        call move_left
        ret

.not_left:
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
        call beep_move
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
        call beep_move
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
        call beep_move
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
        call beep_move
        ret

;───────────────────────────────────────
; Get board state address
;───────────────────────────────────────
get_board_addr:
        ld hl, board_state

        ld a, b
        rlca
        rlca
        rlca
        add a, c
        ld e, a
        ld d, 0
        add hl, de

        ret

;───────────────────────────────────────
; Get owner of a cell
;───────────────────────────────────────
get_owner:
        call get_board_addr
        ld a, (hl)
        ret

;───────────────────────────────────────
; Check cursor adjacency
;───────────────────────────────────────
check_adjacency:
        ld a, (cursor_y)
        or a
        jr z, .ca_skip_up

        dec a
        ld b, a
        ld a, (cursor_x)
        ld c, a
        call get_owner
        ld b, a
        ld a, (current_player)
        cp b
        ret z

.ca_skip_up:
        ld a, (cursor_y)
        cp 7
        jr z, .ca_skip_down

        inc a
        ld b, a
        ld a, (cursor_x)
        ld c, a
        call get_owner
        ld b, a
        ld a, (current_player)
        cp b
        ret z

.ca_skip_down:
        ld a, (cursor_x)
        or a
        jr z, .ca_skip_left

        dec a
        ld c, a
        ld a, (cursor_y)
        ld b, a
        call get_owner
        ld b, a
        ld a, (current_player)
        cp b
        ret z

.ca_skip_left:
        ld a, (cursor_x)
        cp 7
        jr z, .ca_skip_right

        inc a
        ld c, a
        ld a, (cursor_y)
        ld b, a
        call get_owner
        ld b, a
        ld a, (current_player)
        cp b
        ret z

.ca_skip_right:
        or 1
        ret

;───────────────────────────────────────
; Check adjacency at (B,C)
;───────────────────────────────────────
check_adjacency_at:
        push bc

        ld a, b
        or a
        jr z, .caa_skip_up

        dec a
        ld b, a
        call get_owner
        ld e, a
        ld a, (current_player)
        cp e
        jr z, .caa_found

.caa_skip_up:
        pop bc
        push bc

        ld a, b
        cp 7
        jr z, .caa_skip_down

        inc a
        ld b, a
        call get_owner
        ld e, a
        ld a, (current_player)
        cp e
        jr z, .caa_found

.caa_skip_down:
        pop bc
        push bc

        ld a, c
        or a
        jr z, .caa_skip_left

        dec a
        ld c, a
        call get_owner
        ld e, a
        ld a, (current_player)
        cp e
        jr z, .caa_found

.caa_skip_left:
        pop bc
        push bc

        ld a, c
        cp 7
        jr z, .caa_skip_right

        inc a
        ld c, a
        call get_owner
        ld e, a
        ld a, (current_player)
        cp e
        jr z, .caa_found

.caa_skip_right:
        pop bc
        or 1
        ret

.caa_found:
        pop bc
        xor a
        ret

;───────────────────────────────────────
; Claim current cell
;───────────────────────────────────────
claim_cell:
        ld a, (cursor_x)
        ld c, a
        ld a, (cursor_y)
        ld b, a

        call get_board_addr
        ld a, (hl)
        or a
        ret nz

        call check_adjacency
        ret nz

        ; Claim it
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

        call beep_claim

        ; Decrement moves and check for game over
        ld a, (moves_remaining)
        dec a
        ld (moves_remaining), a
        or a
        jp z, check_game_over

        ; AI's turn
        call ai_think_delay
        call ai_pick_move
        call ai_make_move

        ret

;───────────────────────────────────────
; Set cell colour based on current player
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

        ld a, (hl)
        and %10000000
        or b
        ld (hl), a

        inc hl
        ld a, (hl)
        and %10000000
        or b
        ld (hl), a

        ld de, 31
        add hl, de

        ld a, (hl)
        and %10000000
        or b
        ld (hl), a

        inc hl
        ld a, (hl)
        and %10000000
        or b
        ld (hl), a

        ret

;───────────────────────────────────────
; Set cell colour directly
;───────────────────────────────────────
set_cell_direct:
        ld a, (hl)
        and %10000000
        or b
        ld (hl), a

        inc hl
        ld a, (hl)
        and %10000000
        or b
        ld (hl), a

        ld de, 31
        add hl, de

        ld a, (hl)
        and %10000000
        or b
        ld (hl), a

        inc hl
        ld a, (hl)
        and %10000000
        or b
        ld (hl), a

        ret

;───────────────────────────────────────
; Update border colour
;───────────────────────────────────────
update_ui_colours:
        ld a, (current_player)
        cp 1
        jr nz, .uuc_player_2
        ld a, 2
        jr .uuc_set_border
.uuc_player_2:
        ld a, 5
.uuc_set_border:
        ld (border_colour), a
        out (254), a
        ret

;───────────────────────────────────────
; AI: Think delay
;───────────────────────────────────────
ai_think_delay:
        ld b, 25
.delay_loop:
        halt
        djnz .delay_loop
        ret

;───────────────────────────────────────
; AI: Find best move
;───────────────────────────────────────
ai_pick_move:
        xor a
        ld (best_score), a

        ld a, 2
        ld (current_player), a

        ld b, 0
.y_loop:
        ld c, 0
.x_loop:
        push bc

        call get_owner
        or a
        jr nz, .skip

        pop bc
        push bc
        call check_adjacency_at
        jr nz, .skip

        pop bc
        push bc
        call score_cell

        ld e, a
        ld a, (best_score)
        cp e
        jr nc, .skip

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

        ld a, 1
        ld (current_player), a

        ret

;───────────────────────────────────────
; AI: Score a cell
;───────────────────────────────────────
score_cell:
        xor a
        ld (tmp_score), a

        push bc

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

        pop bc
        push bc
        call count_enemy_neighbours
        cp 2
        jr c, .no_block

        ld a, (tmp_score)
        add a, 4
        ld (tmp_score), a

.no_block:
        ld a, (frame_counter)
        and %00000001
        ld b, a
        ld a, (tmp_score)
        add a, b
        ld (tmp_score), a

        pop bc
        ld a, (tmp_score)
        ret

;───────────────────────────────────────
; AI: Score neighbour routines
;───────────────────────────────────────
score_neighbour_up:
        ld a, b
        or a
        ret z
        dec a
        ld b, a
        call get_owner
        or a
        jr z, .snu_neutral
        cp 2
        jr z, .snu_friendly
        ld a, (tmp_score)
        sub 2
        ld (tmp_score), a
        ret
.snu_friendly:
        ld a, (tmp_score)
        add a, 3
        ld (tmp_score), a
        ret
.snu_neutral:
        ld a, (tmp_score)
        inc a
        ld (tmp_score), a
        ret

score_neighbour_down:
        ld a, b
        cp 7
        ret z
        inc a
        ld b, a
        call get_owner
        or a
        jr z, .snd_neutral
        cp 2
        jr z, .snd_friendly
        ld a, (tmp_score)
        sub 2
        ld (tmp_score), a
        ret
.snd_friendly:
        ld a, (tmp_score)
        add a, 3
        ld (tmp_score), a
        ret
.snd_neutral:
        ld a, (tmp_score)
        inc a
        ld (tmp_score), a
        ret

score_neighbour_left:
        ld a, c
        or a
        ret z
        dec a
        ld c, a
        call get_owner
        or a
        jr z, .snl_neutral
        cp 2
        jr z, .snl_friendly
        ld a, (tmp_score)
        sub 2
        ld (tmp_score), a
        ret
.snl_friendly:
        ld a, (tmp_score)
        add a, 3
        ld (tmp_score), a
        ret
.snl_neutral:
        ld a, (tmp_score)
        inc a
        ld (tmp_score), a
        ret

score_neighbour_right:
        ld a, c
        cp 7
        ret z
        inc a
        ld c, a
        call get_owner
        or a
        jr z, .snr_neutral
        cp 2
        jr z, .snr_friendly
        ld a, (tmp_score)
        sub 2
        ld (tmp_score), a
        ret
.snr_friendly:
        ld a, (tmp_score)
        add a, 3
        ld (tmp_score), a
        ret
.snr_neutral:
        ld a, (tmp_score)
        inc a
        ld (tmp_score), a
        ret

;───────────────────────────────────────
; AI: Count enemy neighbours
;───────────────────────────────────────
count_enemy_neighbours:
        xor a
        ld (enemy_count), a
        push bc

        ld a, b
        or a
        jr z, .cen_skip_up
        dec a
        ld b, a
        call get_owner
        cp 1
        jr nz, .cen_skip_up
        ld a, (enemy_count)
        inc a
        ld (enemy_count), a
.cen_skip_up:
        pop bc
        push bc

        ld a, b
        cp 7
        jr z, .cen_skip_down
        inc a
        ld b, a
        call get_owner
        cp 1
        jr nz, .cen_skip_down
        ld a, (enemy_count)
        inc a
        ld (enemy_count), a
.cen_skip_down:
        pop bc
        push bc

        ld a, c
        or a
        jr z, .cen_skip_left
        dec a
        ld c, a
        call get_owner
        cp 1
        jr nz, .cen_skip_left
        ld a, (enemy_count)
        inc a
        ld (enemy_count), a
.cen_skip_left:
        pop bc
        push bc

        ld a, c
        cp 7
        jr z, .cen_skip_right
        inc a
        ld c, a
        call get_owner
        cp 1
        jr nz, .cen_skip_right
        ld a, (enemy_count)
        inc a
        ld (enemy_count), a
.cen_skip_right:
        pop bc

        ld a, (enemy_count)
        ret

;───────────────────────────────────────
; AI: Execute move
;───────────────────────────────────────
ai_make_move:
        ld a, (best_score)
        or a
        ret z

        ld a, 2
        ld (current_player), a

        ld a, (best_y)
        ld b, a
        ld a, (best_x)
        ld c, a
        call get_board_addr
        ld a, 2
        ld (hl), a

        ld a, (best_y)
        ld b, a
        ld a, (best_x)
        ld c, a
        call get_cell_addr
        call set_cell_colour

        ; Decrement moves and check for game over
        ld a, (moves_remaining)
        dec a
        ld (moves_remaining), a
        or a
        jp z, check_game_over

        ld a, 1
        ld (current_player), a
        call update_ui_colours

        ret

;───────────────────────────────────────
; Count territories for each player
;───────────────────────────────────────
count_territories:
        xor a
        ld (p1_count), a
        ld (p2_count), a

        ld hl, board_state
        ld b, 64

.ct_count_loop:
        ld a, (hl)
        cp 1
        jr nz, .ct_not_p1
        ld a, (p1_count)
        inc a
        ld (p1_count), a
        jr .ct_next

.ct_not_p1:
        cp 2
        jr nz, .ct_next
        ld a, (p2_count)
        inc a
        ld (p2_count), a

.ct_next:
        inc hl
        djnz .ct_count_loop
        ret

;───────────────────────────────────────
; Check game over and declare winner
;───────────────────────────────────────
check_game_over:
        call count_territories

        ld a, (p1_count)
        ld b, a
        ld a, (p2_count)
        cp b
        jr z, .cgo_draw
        jr c, .cgo_p1_wins

        ; P2 wins
        ld a, 2
        jr .cgo_store_winner

.cgo_p1_wins:
        ld a, 1
        jr .cgo_store_winner

.cgo_draw:
        xor a

.cgo_store_winner:
        ld (winner), a
        call show_results
        call set_winner_border
        call play_result_sound
        call wait_for_restart
        jp restart_game

;───────────────────────────────────────
; Show results screen
;───────────────────────────────────────
show_results:
        ; Clear screen
        call clear_screen

        ; Set white on black for text
        ld a, %00000111
        ld (23693), a           ; ATTR_P

        ; Open channel 2
        ld a, 2
        call OPEN_CHANNEL

        ; Print "GAME OVER" at row 6
        ld a, 22
        rst $10
        ld a, 6
        rst $10
        ld a, 11
        rst $10
        ld hl, msg_gameover
        call print_string

        ; Print "PLAYER: " and score at row 10
        ld a, 22
        rst $10
        ld a, 10
        rst $10
        ld a, 10
        rst $10
        ld hl, msg_player
        call print_string
        ld a, (p1_count)
        call print_number

        ; Print "CPU: " and score at row 12
        ld a, 22
        rst $10
        ld a, 12
        rst $10
        ld a, 10
        rst $10
        ld hl, msg_cpu
        call print_string
        ld a, (p2_count)
        call print_number

        ; Print winner message at row 16
        ld a, 22
        rst $10
        ld a, 16
        rst $10
        ld a, 9
        rst $10

        ld a, (winner)
        or a
        jr z, .sr_draw
        cp 1
        jr z, .sr_p1_wins

        ; P2/CPU wins
        ld hl, msg_cpu_wins
        jr .sr_print_winner

.sr_p1_wins:
        ld hl, msg_player_wins
        jr .sr_print_winner

.sr_draw:
        ld hl, msg_draw

.sr_print_winner:
        call print_string

        ; Print "PRESS SPACE" at row 20
        ld a, 22
        rst $10
        ld a, 20
        rst $10
        ld a, 10
        rst $10
        ld hl, msg_space
        call print_string

        ret

;───────────────────────────────────────
; Set border to winner colour
;───────────────────────────────────────
set_winner_border:
        ld a, (winner)
        cp 1
        jr nz, .swb_not_p1
        ld a, 2                 ; Red
        jr .swb_set
.swb_not_p1:
        cp 2
        jr nz, .swb_is_draw
        ld a, 5                 ; Cyan
        jr .swb_set
.swb_is_draw:
        ld a, 6                 ; Yellow
.swb_set:
        ld (border_colour), a
        out (254), a
        ret

;───────────────────────────────────────
; Print null-terminated string
;───────────────────────────────────────
print_string:
        ld a, (hl)
        or a
        ret z
        rst $10
        inc hl
        jr print_string

;───────────────────────────────────────
; Print a number (0-99)
;───────────────────────────────────────
print_number:
        ld c, a
        ld b, 0

.count_tens:
        cp 10
        jr c, .print_digits
        sub 10
        inc b
        jr .count_tens

.print_digits:
        ld c, a

        ld a, b
        or a
        jr z, .print_units
        add a, '0'
        rst $10

.print_units:
        ld a, c
        add a, '0'
        rst $10
        ret

;───────────────────────────────────────
; Play a beep
; Input: DE = pitch (higher = lower tone)
;        BC = duration (cycles)
;───────────────────────────────────────
play_beep:
        ld a, (border_colour)
        ld h, a

.beep_loop:
        ; Speaker ON
        ld a, h
        or %00010000
        out ($FE), a

        ; Pitch delay
        push de
.delay1:
        dec de
        ld a, d
        or e
        jr nz, .delay1
        pop de

        ; Speaker OFF
        ld a, h
        out ($FE), a

        ; Pitch delay
        push de
.delay2:
        dec de
        ld a, d
        or e
        jr nz, .delay2
        pop de

        ; Duration loop
        dec bc
        ld a, b
        or c
        jr nz, .beep_loop

        ret

;───────────────────────────────────────
; Beep for cursor movement
;───────────────────────────────────────
beep_move:
        ld de, 50
        ld bc, 20
        call play_beep
        ret

;───────────────────────────────────────
; Beep for claiming a cell
;───────────────────────────────────────
beep_claim:
        ld de, 150
        ld bc, 80
        call play_beep
        ret

;───────────────────────────────────────
; Victory jingle (ascending)
;───────────────────────────────────────
beep_victory:
        ld de, 200
        ld bc, 100
        call play_beep

        ld de, 150
        ld bc, 100
        call play_beep

        ld de, 100
        ld bc, 150
        call play_beep

        ld de, 75
        ld bc, 200
        call play_beep

        ret

;───────────────────────────────────────
; Defeat sound (descending)
;───────────────────────────────────────
beep_defeat:
        ld de, 100
        ld bc, 100
        call play_beep

        ld de, 150
        ld bc, 100
        call play_beep

        ld de, 200
        ld bc, 150
        call play_beep

        ld de, 300
        ld bc, 200
        call play_beep

        ret

;───────────────────────────────────────
; Draw sound (neutral)
;───────────────────────────────────────
beep_draw:
        ld de, 120
        ld bc, 100
        call play_beep

        ld de, 120
        ld bc, 100
        call play_beep

        ret

;───────────────────────────────────────
; Play appropriate end-game sound
;───────────────────────────────────────
play_result_sound:
        ld a, (winner)
        or a
        jr z, .prs_draw
        cp 1
        jr z, .prs_p1_wins

        ; CPU wins
        call beep_defeat
        ret

.prs_p1_wins:
        call beep_victory
        ret

.prs_draw:
        call beep_draw
        ret

;───────────────────────────────────────
; Wait for SPACE to restart
;───────────────────────────────────────
wait_for_restart:
.wait_release:
        ld a, $7F
        in a, ($FE)
        bit 0, a
        jr z, .wait_release

.wait_press:
        halt
        ld a, $7F
        in a, ($FE)
        bit 0, a
        jr nz, .wait_press

        ret

;───────────────────────────────────────
; Reset and restart the game
;───────────────────────────────────────
restart_game:
        ; Clear board state
        ld hl, board_state
        ld b, 64
.clear_board:
        ld (hl), 0
        inc hl
        djnz .clear_board

        ; Reset move counter
        ld a, 62
        ld (moves_remaining), a

        ; Reset cursor
        ld a, 1
        ld (cursor_x), a
        xor a
        ld (cursor_y), a

        ; Reset player
        ld a, 1
        ld (current_player), a

        ; Redraw
        call clear_screen
        call draw_board
        call init_starting_cells

        ld b, 0
        ld c, 1
        call get_cell_addr
        call highlight_cursor

        call update_ui_colours

        jp main_loop

;───────────────────────────────────────
; Variables
;───────────────────────────────────────
cursor_x:        defb 0
cursor_y:        defb 0
move_delay:      defb 0
space_held:      defb 0
current_player:  defb 1
frame_counter:   defb 0
moves_remaining: defb 62
border_colour:   defb 2

;───────────────────────────────────────
; AI variables
;───────────────────────────────────────
best_score:      defb 0
best_x:          defb 0
best_y:          defb 0
tmp_score:       defb 0
enemy_count:     defb 0

;───────────────────────────────────────
; Win detection variables
;───────────────────────────────────────
p1_count:        defb 0
p2_count:        defb 0
winner:          defb 0

;───────────────────────────────────────
; Message strings
;───────────────────────────────────────
msg_gameover:    defb "GAME OVER", 0
msg_player:      defb "PLAYER:  ", 0
msg_cpu:         defb "CPU:     ", 0
msg_player_wins: defb "PLAYER WINS!", 0
msg_cpu_wins:    defb "CPU WINS!", 0
msg_draw:        defb "IT'S A DRAW!", 0
msg_space:       defb "PRESS SPACE", 0

;───────────────────────────────────────
; Board state
;───────────────────────────────────────
board_state:     defs 64, 0

        end start
