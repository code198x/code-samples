;──────────────────────────────────────────────────────────────
; INK WAR - Unit 16 sample (Final game)
; Locks in the title→game→results loop, keeps the blink/palette polish,
; and adds a version tag so you can ship a clean TAP.
;──────────────────────────────────────────────────────────────

            org 32768

BEEP        equ 949
BOARD_ATTR  equ 22528 + (4 * 32) + 8

; player constants
OWNER_P1    equ 1
OWNER_P2    equ 2
AI_EASY     equ 0
AI_NORMAL   equ 1
AI_HARD     equ 2

ai_delay_table:
            defb 50,28,10
ai_bonus_table:
            defb 0,2,4

start:
            call show_title
            jp game_start

show_title:
            ld a,0
            out (254),a
            call 3435
            ld a,7
            ld (23693),a

            ld a,(init_done)
            or a
            jr nz,.keep_cfg
            ld a,AI_NORMAL
            ld (ai_level),a
            ld a,0
            ld (mode_hotseat),a
            ld a,1
            ld (init_done),a
.keep_cfg:

            ld a,22
            rst 16
            ld a,10
            rst 16
            ld a,6
            rst 16
            ld hl, title_text
            call print_string

            ld a,22
            rst 16
            ld a,12
            rst 16
            ld a,0
            rst 16
            ld hl, start_text
            call print_string

            ld a,22
            rst 16
            ld a,13
            rst 16
            ld a,0
            rst 16
            ld hl, hotseat_text
            call print_string

            ld a,22
            rst 16
            ld a,14
            rst 16
            ld a,0
            rst 16
            ld hl, diff_text
            call print_string

            ld a,22
            rst 16
            ld a,18
            rst 16
            ld a,0
            rst 16
            ld hl, version_text
            call print_string

            call draw_mode_line
            call draw_diff_line

.wait:
            halt
            call poll_title_input
            or a
            jr z,.wait
            ret

;------------------------------------------------------------
; Main game
;------------------------------------------------------------

BEEP_MOVE   equ 20
BEEP_CLAIM  equ 40
BEEP_WIN    equ 80

owner_map:   defs 64
cursor_x:    defb 0
cursor_y:    defb 0
move_dir:    defb 0
space_pressed:defb 0
turn_flag:   defb 0          ; 0=P1, 1=P2
mode_hotseat:defb 0          ; 0 = vs AI, 1 = 2P
ai_level:    defb 1          ; default normal
ai_timer:    defb 0
blink_timer: defb 0
blink_phase: defb 0
moves_remaining: defb 64
p1_count:    defw 0
p2_count:    defw 0
tmp_score:   defb 0
best_score:  defb 0
best_x:      defb 0
best_y:      defb 0
init_done:   defb 0

p1_text:     defb "PLAYER 1 WINS!",0
p2_text:     defb "PLAYER 2 WINS!",0
draw_text:   defb "DRAW!",0
restart_text:defb "PRESS SPACE TO RESTART",0
title_text:  defb "INK WAR",0
start_text:  defb "SPACE: START (AI)",0
hotseat_text:defb "H: HOTSEAT 2P  A: VS AI",0
diff_text:   defb "1 EASY  2 NORMAL  3 HARD",0
mode_line:   defb "MODE: ",0
ai_label:    defb "AI",0
hot_label:   defb "HOTSEAT",0
diff_label:  defb "DIFFICULTY: ",0
diff_easy:   defb "EASY",0
diff_norm:   defb "NORMAL",0
diff_hard:   defb "HARD",0
version_text:defb "UNIT 16 - FINAL BUILD",0

print_string:
            ld a,(hl)
            or a
            ret z
            rst 16
            inc hl
            jr print_string

poll_title_input:
            xor a
            ld (space_pressed),a

            ; SPACE to start
            ld bc,$f7fe
            in d,(c)
            bit 0,d
            jr nz,.check_hot
            ld bc,40
            call BEEP
            ld a,1
            ret
.check_hot:
            ; H for hotseat (row with H J K L ENTER)
            ld bc,$bffe
            in d,(c)
            bit 4,d
            jr nz,.check_ai
            ld a,1
            ld (mode_hotseat),a
            call draw_mode_line
            ld bc,25
            call BEEP
.check_ai:
            ; A for AI mode
            ld bc,$fbfe
            in d,(c)
            bit 0,d
            jr nz,.check_diff
            ld a,0
            ld (mode_hotseat),a
            call draw_mode_line
            ld bc,25
            call BEEP
.check_diff:
            ld bc,$fefe          ; number row 1-5
            in d,(c)
            bit 0,d              ; key 1
            jr nz,.check2
            ld a,AI_EASY
            ld (ai_level),a
            call draw_diff_line
            ld bc,15
            call BEEP
.check2:
            bit 1,d              ; key 2
            jr nz,.check3
            ld a,AI_NORMAL
            ld (ai_level),a
            call draw_diff_line
            ld bc,20
            call BEEP
.check3:
            bit 2,d              ; key 3
            jr nz,.no_start
            ld a,AI_HARD
            ld (ai_level),a
            call draw_diff_line
            ld bc,25
            call BEEP
.no_start:
            xor a
            ret

draw_mode_line:
            ld a,22
            rst 16
            ld a,16
            rst 16
            ld a,0
            rst 16
            ld hl, mode_line
            call print_string
            ld a,(mode_hotseat)
            or a
            jr z,.ai
            ld hl, hot_label
            jr .out
.ai:
            ld hl, ai_label
.out:
            call print_string
            ret

draw_diff_line:
            ld a,22
            rst 16
            ld a,17
            rst 16
            ld a,0
            rst 16
            ld hl, diff_label
            call print_string
            ld a,(ai_level)
            cp AI_EASY
            jr nz,.not_easy
            ld hl, diff_easy
            jr .diff_done
.not_easy:
            cp AI_NORMAL
            jr nz,.hard
            ld hl, diff_norm
            jr .diff_done
.hard:
            ld hl, diff_hard
.diff_done:
            call print_string
            ret

;------------------------------------------------------------
; Game entry
;------------------------------------------------------------
game_start:
            ld a,0
            out (254),a
            call 3435
            ld a,7
            ld (23693),a

            call init_owner_map
            call draw_board
            ld a,1
            ld (blink_phase),a
            ld a,0
            ld (blink_timer),a
            call highlight_cursor
            ld a,0
            ld (turn_flag),a
            call set_ai_delay

main_loop:
            halt
            call update_cursor_blink
            ld a,(turn_flag)
            or a
            jr nz, p2_turn
            call read_input_p1
            call maybe_claim_p1
            jr main_loop

p2_turn:
            ld a,(mode_hotseat)
            or a
            jr nz, hotseat_turn
            call ai_turn
            jr main_loop

hotseat_turn:
            call read_input_p2
            call maybe_claim_p2
            jr main_loop

;------------------------------------------------------------
; Board/owners
;------------------------------------------------------------
init_owner_map:
            ld hl, owner_map
            ld b,64
            ld a,0
.clr:
            ld (hl),a
            inc hl
            djnz .clr
            ld hl, owner_map
            ld (hl),OWNER_P1
            ld hl, owner_map+63
            ld (hl),OWNER_P2
            ld a,64
            ld (moves_remaining),a
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
            cp OWNER_P1
            jr z,.own_p1
            cp OWNER_P2
            jr z,.own_p2
            ld a,0*8+7
            ret
.own_p1:
            ld a,1*8+6
            ret
.own_p2:
            ld a,4*8+7
            ret

;------------------------------------------------------------
; Input P1: QAOP + SPACE
;------------------------------------------------------------
read_input_p1:
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

;------------------------------------------------------------
; Input P2: numeric row 6789 (right/left/up/down), 0 to claim
;------------------------------------------------------------
read_input_p2:
            ld a,0
            ld (move_dir),a
            ld (space_pressed),a

            ld bc,$effe          ; row with 0 9 8 7 6
            in a,(c)
            bit 1,a              ; 9 (left)
            jr nz,p2_check_right
            ld a,2
            ld (move_dir),a
p2_check_right:
            bit 4,a              ; 6 (right)
            jr nz,p2_check_up
            ld a,1
            ld (move_dir),a
p2_check_up:
            bit 2,a              ; 8 (up)
            jr nz,p2_check_down
            ld a,3
            ld (move_dir),a
p2_check_down:
            bit 3,a              ; 7 (down)
            jr nz,p2_check_claim
            ld a,4
            ld (move_dir),a
p2_check_claim:
            bit 0,a              ; 0 (claim)
            jr nz,p2_done
            ld a,1
            ld (space_pressed),a
p2_done:
            call move_cursor
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
            ld bc,BEEP_MOVE
            call BEEP
            ret

maybe_claim_p1:
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
            ld a,OWNER_P1
            ld (hl),a
            call draw_board
            call highlight_cursor
            call flash_capture
            ld bc,BEEP_CLAIM
            call BEEP
            ld a,1
            ld (turn_flag),a
            ld a,(mode_hotseat)
            or a
            jr nz,.skip_delay
            call set_ai_delay
.skip_delay:
            call dec_moves
            call maybe_win
            ret

maybe_claim_p2:
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
            ld a,OWNER_P2
            ld (hl),a
            call draw_board
            call highlight_cursor
            call flash_capture
            ld bc,BEEP_CLAIM
            call BEEP
            ld a,0
            ld (turn_flag),a
            call dec_moves
            call maybe_win
            ret

;------------------------------------------------------------
; AI turn + heuristics
;------------------------------------------------------------
set_ai_delay:
            ld a,(ai_level)
            ld hl, ai_delay_table
            ld e,a
            ld d,0
            add hl,de
            ld a,(hl)
            ld (ai_timer),a
            ret

ai_turn:
            ld a,(ai_timer)
            or a
            jr z,.think
            dec a
            ld (ai_timer),a
            ret
.think:
            call ai_pick_move
            call ai_claim
            call set_ai_delay
            ret

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
            ; center bias by difficulty
            ld a,c
            cp 2
            jr c,.no_bias
            cp 6
            jr nc,.no_bias
            ld a,b
            cp 2
            jr c,.no_bias
            cp 6
            jr nc,.no_bias
            ld a,(ai_level)
            ld hl, ai_bonus_table
            ld e,a
            ld d,0
            add hl,de
            ld a,(tmp_score)
            add a,(hl)
            ld (tmp_score),a
.no_bias:
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
            cp OWNER_P2
            jr nz,.maybe_block
            ld a,(tmp_score)
            inc a
            ld (tmp_score),a
            ret
.maybe_block:
            cp OWNER_P1
            ret nz
            ld a,(tmp_score)
            inc a
            ld (tmp_score),a
            ret

ai_claim:
            ; place AI claim at best_x/best_y
            ld a,(best_y)
            ld b,a
            ld a,(best_x)
            ld c,a
            call owner_addr
            ld a,(hl)
            or a
            ret nz
            ld a,(best_y)
            ld (cursor_y),a
            ld a,(best_x)
            ld (cursor_x),a
            ld a,OWNER_P2
            ld (hl),a
            call draw_board
            call highlight_cursor
            call flash_capture
            ld bc,BEEP_CLAIM
            call BEEP
            ld a,0
            ld (turn_flag),a
            call dec_moves
            call maybe_win
            ret

flash_capture:
            push bc
            push de
            push hl
            ld b,3
.flash_loop:
            call get_attr_addr
            ld a,(hl)
            xor 64               ; toggle BRIGHT
            call write_attr_block
            ld de,1200
.delay:
            dec de
            ld a,d
            or e
            jr nz,.delay
            djnz .flash_loop
            call highlight_cursor
            pop hl
            pop de
            pop bc
            ret

dec_moves:
            ld a,(moves_remaining)
            dec a
            ld (moves_remaining),a
            ret

;------------------------------------------------------------
; Win detection (2P)
;------------------------------------------------------------
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
            ld (p2_count),hl
            ld b,0
.cw_row:
            ld c,0
.cw_col:
            push bc
            call owner_addr
            ld a,(hl)
            cp OWNER_P1
            jr nz,.not_p1
            ld hl,(p1_count)
            inc hl
            ld (p1_count),hl
            jr .next_cell
.not_p1:
            cp OWNER_P2
            jr nz,.next_cell
            ld hl,(p2_count)
            inc hl
            ld (p2_count),hl
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
            ld de,(p2_count)
            or a
            sbc hl,de
            jr z,.draw
            jr c,.p2_wins
            jr .p1_wins
.draw:
            ld hl, draw_text
            jr .announce
.p2_wins:
            ld hl, p2_text
            jr .announce
.p1_wins:
            ld hl, p1_text
.announce:
            ld a,22
            rst 16
            ld a,12
            rst 16
            ld a,8
            rst 16
            call print_string
            ld bc,BEEP_WIN
            call BEEP
            ld hl, restart_text
            ld a,22
            rst 16
            ld a,14
            rst 16
            ld a,6
            rst 16
            call print_string
            ld hl, version_text
            ld a,22
            rst 16
            ld a,16
            rst 16
            ld a,4
            rst 16
            call print_string
            ret

;------------------------------------------------------------
; Attr helpers
;------------------------------------------------------------
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
            call apply_cursor_attr
            ret

clear_cursor:
            ; restore owner attribute without flash/bright
            ld a,(cursor_y)
            ld b,a
            ld a,(cursor_x)
            ld c,a
            call owner_addr
            ld a,(hl)
            call owner_to_attr
            ld b,a
            call get_attr_addr
            ld a,b
            call write_attr_block
            ret

apply_cursor_attr:
            ld a,(blink_phase)
            or a
            jr z,.dim
            ld a,(hl)
            set 6,a
            jr .write
.dim:
            ld a,(hl)
            res 6,a
.write:
            call write_attr_block
            ret

write_attr_block:
            ld b,a
            ld (hl),b
            inc hl
            ld (hl),b
            ld de,31
            add hl,de
            ld (hl),b
            inc hl
            ld (hl),b
            ret

update_cursor_blink:
            ld a,(blink_timer)
            inc a
            cp 8
            jr nz,.store
            ld a,0
            ld (blink_timer),a
            ld a,(blink_phase)
            xor 1
            ld (blink_phase),a
            call highlight_cursor
            ret
.store:
            ld (blink_timer),a
            ret

            end start
