;──────────────────────────────────────────────────────────────
; INK WAR - Unit 10 sample (Scoring and results)
; Builds on Unit 9: board, cursor, movement, claiming, AI, win detection.
; Adds a score tally (counts claimed cells) and displays results; waits for SPACE to restart.
;──────────────────────────────────────────────────────────────

            org 32768

BOARD_ATTR   equ 22528 + (4 * 32) + 8

start:
            ld a,0
            out (254),a
            call 3435
            ld a,7
            ld (23693),a

            call init_owner_map
            call draw_board
            call highlight_cursor
            ld a,0
            ld (turn_flag),a

main_loop:
            halt
            ld a,(turn_flag)
            or a
            jr nz, ai_turn
            call read_input
            call maybe_claim
            jr main_loop

ai_turn:
            call ai_pick_move
            call ai_claim
            jr main_loop

;------------------------------------------------------------
; Owner/board
;------------------------------------------------------------
init_owner_map:
            ld hl, owner_map
            ld b,64
            ld a,0
.clr:
            ld (hl),a
            inc hl
            djnz .clr
            ; seed corners
            ld hl, owner_map
            ld (hl),1
            ld hl, owner_map+63
            ld (hl),2
            ret

draw_board:
            ld hl, BOARD_ATTR
            ld b,0
.row:
            push bc
            ld c,0
.col:
            push bc
            push hl
            call owner_addr
            ld a,(hl)
            pop hl
            call owner_to_attr
            ld (hl),a
            inc hl
            ld (hl),a
            ld de,31
            add hl,de
            ld (hl),a
            inc hl
            ld (hl),a
            ld de,-63
            add hl,de
            pop bc
            inc c
            ld a,c
            cp 8
            jr nz,.col
            ld de,64
            add hl,de
            pop bc
            inc b
            ld a,b
            cp 8
            jr nz,.row
            ret

owner_addr:
            ld hl, owner_map
            ld d,0
            ld a,b
            rlca
            rlca
            rlca
            ld d,a
            ld a,c
            add a,d
            ld e,a
            add hl,de
            ret

owner_to_attr:
            cp 1
            jr z,.own_p1
            cp 2
            jr z,.own_ai
            ld a,7*8+0
            ret
.own_p1:
            ld a,2*8+7
            ret
.own_ai:
            ld a,5*8+7
            ret

;------------------------------------------------------------
; Cursor/input/claim (simplified, no adjacency)
;------------------------------------------------------------
cursor_x: defb 0
cursor_y: defb 0
move_dir: defb 0
space_pressed: defb 0
turn_flag: defb 0

read_input:
            ld a,0
            ld (move_dir),a
            ld (space_pressed),a

            ld bc,$dffe
            in a,(c)
            bit 0,a
            jr nz,.check_left
            ld a,1
            ld (move_dir),a
.check_left:
            ld bc,$dffe
            in a,(c)
            bit 1,a
            jr nz,.check_up
            ld a,2
            ld (move_dir),a
.check_up:
            ld bc,$fbfe
            in a,(c)
            bit 0,a
            jr nz,.check_down
            ld a,3
            ld (move_dir),a
.check_down:
            ld bc,$fdfe
            in a,(c)
            bit 0,a
            jr nz,.check_space
            ld a,4
            ld (move_dir),a
.check_space:
            ld bc,$f7fe
            in a,(c)
            bit 0,a
            jr nz,.done
            ld a,1
            ld (space_pressed),a
.done:      call move_cursor
            ret

move_cursor:
            ld a,(move_dir)
            or a
            ret z
            call clear_cursor
            cp 1
            jr nz,.nr
            ld a,(cursor_x)
            cp 7
            jr z,.nr
            inc a
            ld (cursor_x),a
.nr:
            ld a,(move_dir)
            cp 2
            jr nz,.nl
            ld a,(cursor_x)
            or a
            jr z,.nl
            dec a
            ld (cursor_x),a
.nl:
            ld a,(move_dir)
            cp 3
            jr nz,.nu
            ld a,(cursor_y)
            or a
            jr z,.nu
            dec a
            ld (cursor_y),a
.nu:
            ld a,(move_dir)
            cp 4
            jr nz,.done_move
            ld a,(cursor_y)
            cp 7
            jr z,.done_move
            inc a
            ld (cursor_y),a
.done_move:
            call highlight_cursor
            ret

maybe_claim:
            ld a,(space_pressed)
            or a
            ret z
            ld a,(cursor_y)
            ld b,a
            ld a,(cursor_x)
            ld c,a
            call owner_addr
            ld a,(hl)
            or a
            ret nz
            ld a,1
            ld (hl),a
            call draw_board
            call highlight_cursor
            ld a,1
            ld (turn_flag),a
            call dec_moves
            call maybe_win
            ret

dec_moves:
            ld a,(moves_remaining)
            dec a
            ld (moves_remaining),a
            ret

;------------------------------------------------------------
; AI pick/claim (reuse unit7 heuristic)
;------------------------------------------------------------
best_score: defb 0
best_x:     defb 0
best_y:     defb 0
moves_remaining: defb 64

ai_pick_move:
            ld a,0
            ld (best_score),a
            ld (best_x),a
            ld (best_y),a

            ld b,0
.ai_row:
            ld c,0
.ai_col:
            push bc
            call owner_addr
            ld a,(hl)
            or a
            jr nz,.skip
            ; score: +2 per AI, +1 neutral, -2 player
            ; B,C already hold loop y,x
            call score_cell_ai
            ld e,a
            ld a,(best_score)
            cp e
            jr nc,.skip_pop
            ld a,e
            ld (best_score),a
            ld a,c
            ld (best_x),a
            ld a,b
            ld (best_y),a
.skip_pop:  pop bc
            jr .after
.skip:      pop bc
.after:
            inc c
            ld a,c
            cp 8
            jr nz,.ai_col
            inc b
            ld a,b
            cp 8
            jr nz,.ai_row
            ret

score_cell_ai:
            ld a,0
            ld (tmp_score),a
            call sc_up
            call sc_down
            call sc_left
            call sc_right
            ld a,(tmp_score)
            ret

sc_up:
            ld a,b
            or a
            ret z
            dec b
            call owner_addr
            ld a,(hl)
            call apply_neighbor
            inc b
            ret
sc_down:
            ld a,b
            cp 7
            ret z
            inc b
            call owner_addr
            ld a,(hl)
            call apply_neighbor
            dec b
            ret
sc_left:
            ld a,c
            or a
            ret z
            dec c
            call owner_addr
            ld a,(hl)
            call apply_neighbor
            inc c
            ret
sc_right:
            ld a,c
            cp 7
            ret z
            inc c
            call owner_addr
            ld a,(hl)
            call apply_neighbor
            dec c
            ret

apply_neighbor:
            cp 1
            jr z,.an_player
            cp 2
            jr z,.an_ai
            ld a,(tmp_score)
            inc a
            ld (tmp_score),a
            ret
.an_player:
            ld a,(tmp_score)
            sub 2
            ld (tmp_score),a
            ret
.an_ai:
            ld a,(tmp_score)
            add a,2
            ld (tmp_score),a
            ret

tmp_score:  defb 0

ai_claim:
            ld a,(best_y)
            ld b,a
            ld a,(best_x)
            ld c,a
            call owner_addr
            ld a,2
            ld (hl),a
            call draw_board
            call highlight_cursor
            ld a,0
            ld (turn_flag),a
            call dec_moves
            call maybe_win
            ret

maybe_win:
            ld a,(moves_remaining)
            or a
            ret nz
            call check_winner
            call show_results
wait_restart:
            halt
            ld bc,$f7fe
            in a,(c)
            bit 0,a
            jr nz,wait_restart
            jp start

check_winner:
            ld hl,0
            ld (p1_count),hl
            ld (ai_count),hl
            ld b,0
.cw_row:
            ld c,0
.cw_col:
            push bc
            call owner_addr
            ld a,(hl)
            cp 1
            jr nz,.not_p1
            ld hl,(p1_count)
            inc hl
            ld (p1_count),hl
            jr .next_cell
.not_p1:
            cp 2
            jr nz,.next_cell
            ld hl,(ai_count)
            inc hl
            ld (ai_count),hl
.next_cell:
            pop bc
            inc c
            ld a,c
            cp 8
            jr nz,.cw_col
            inc b
            ld a,b
            cp 8
            jr nz,.cw_row
            ret

show_results:
            ld hl,(p1_count)
            ld de,(ai_count)
            or a
            sbc hl,de
            jr z,.draw
            jr c,.ai_wins
            jr .p1_wins
.draw:
            ld hl, draw_text
            jr .announce
.ai_wins:
            ld hl, ai_text
            jr .announce
.p1_wins:
            ld hl, p1_text
.announce:
            ld a,22
            rst 16
            ld a,12
            rst 16
            ld a,10
            rst 16
            call print_string
            ld hl, restart_text
            ld a,22
            rst 16
            ld a,14
            rst 16
            ld a,8
            rst 16
            call print_string
            ret

print_string:
            ld a,(hl)
            or a
            ret z
            rst 16
            inc hl
            jr print_string

get_attr_addr:
            ld hl, BOARD_ATTR
            ld a,(cursor_y)
            rlca
            rlca
            rlca
            rlca
            rlca
            rlca
            ld e,a
            ld d,0
            add hl,de
            ld a,(cursor_x)
            add a,a
            ld e,a
            add hl,de
            ret

highlight_cursor:
            call get_attr_addr
            call set_flash_block
            ret

clear_cursor:
            call get_attr_addr
            call clear_flash_block
            ret

set_flash_block:
            ld a,(hl)
            set 7,a
            ld (hl),a
            inc hl
            ld a,(hl)
            set 7,a
            ld (hl),a
            ld de,31
            add hl,de
            ld a,(hl)
            set 7,a
            ld (hl),a
            inc hl
            ld a,(hl)
            set 7,a
            ld (hl),a
            ret

clear_flash_block:
            ld a,(hl)
            res 7,a
            ld (hl),a
            inc hl
            ld a,(hl)
            res 7,a
            ld (hl),a
            ld de,31
            add hl,de
            ld a,(hl)
            res 7,a
            ld (hl),a
            inc hl
            ld a,(hl)
            res 7,a
            ld (hl),a
            ret

owner_map:   defs 64
p1_count:    defw 0
ai_count:    defw 0

p1_text:     defb "PLAYER WINS!",0
ai_text:     defb "AI WINS!",0
draw_text:   defb "DRAW!",0
restart_text:defb "PRESS SPACE TO RESTART",0
