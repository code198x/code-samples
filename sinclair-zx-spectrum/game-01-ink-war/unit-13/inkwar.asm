;──────────────────────────────────────────────────────────────
; INK WAR - Unit 13 sample (Two Player Mode)
; Adds hotseat two-player play: players alternate turns with their own keys
; (P1: QAOP + SPACE, P2: 6789 + 0 for claim). Win detection counts territories.
; Builds on Unit 12 (title flow) and Unit 11 SFX.
;──────────────────────────────────────────────────────────────

            org 32768

BEEP        equ 949
BOARD_ATTR  equ 22528 + (4 * 32) + 8

; player constants
OWNER_P1    equ 1
OWNER_P2    equ 2

start:
            call show_title
            jp game_start

show_title:
            ld a,0
            out (254),a
            call 3435
            ld a,7
            ld (23693),a

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

.wait:
            halt
            ld bc,$f7fe
            in a,(c)
            bit 0,a
            jr nz,.wait
            ld bc,40
            call BEEP
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
moves_remaining: defb 64
p1_count:    defw 0
p2_count:    defw 0
tmp_score:   defb 0

p1_text:     defb "PLAYER 1 WINS!",0
p2_text:     defb "PLAYER 2 WINS!",0
draw_text:   defb "DRAW!",0
restart_text:defb "PRESS SPACE TO RESTART",0
title_text:  defb "INK WAR",0
start_text:  defb "SPACE TO START (2P HOTSEAT)",0

print_string:
            ld a,(hl)
            or a
            ret z
            rst 16
            inc hl
            jr print_string

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
            call highlight_cursor
            ld a,0
            ld (turn_flag),a

main_loop:
            halt
            ld a,(turn_flag)
            or a
            jr nz, p2_turn
            call read_input_p1
            call maybe_claim_p1
            jr main_loop

p2_turn:
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
            ld a,7*8+0
            ret
.own_p1:
            ld a,2*8+7
            ret
.own_p2:
            ld a,5*8+7
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
            ld bc,BEEP_CLAIM
            call BEEP
            ld a,1
            ld (turn_flag),a
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
            ld bc,BEEP_CLAIM
            call BEEP
            ld a,0
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

            end start
