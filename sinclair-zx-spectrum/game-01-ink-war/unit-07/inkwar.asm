;──────────────────────────────────────────────────────────────
; INK WAR - Unit 7+: Simple AI, Movement, Claiming, Win Check
; Builds on Units 1-6 content in a single file so you can run it directly.
;──────────────────────────────────────────────────────────────

            org 32768

;----------------------------------------------------------------
; Entry
;----------------------------------------------------------------
start:
            ; Black border
            ld a, 0
            out (254), a

            ; Clear screen
            call 3435               ; ROM CLS

            ; Permanent colours: white ink on black paper
            ld a, 7
            ld (23693), a           ; ATTR_P

            call init_owner_map
            call draw_ui
            call draw_board
            call highlight_cursor

main_loop:
            call read_input
            call maybe_claim

            ; If moves remaining = 0, check win
            ld a, (moves_remaining)
            or a
            jr nz, .ai_turn
            call check_winner
            jr main_loop

.ai_turn:
            call ai_pick_move
            call ai_claim

            ; Win check again
            ld a, (moves_remaining)
            or a
            jr nz, main_loop
            call check_winner
            jr main_loop

;----------------------------------------------------------------
; UI
;----------------------------------------------------------------
draw_ui:
            ; Title
            ld hl, title_text
            call print_at_0_10

            ; Instructions
            ld hl, instr_text
            call print_at_21_0
            ret

print_at_0_10:
            ld a, 22                ; AT
            rst 16
            ld a, 0                 ; row
            rst 16
            ld a, 10                ; col
            rst 16
            jp print_string

print_at_21_0:
            ld a, 22
            rst 16
            ld a, 21
            rst 16
            ld a, 0
            rst 16
            jp print_string

print_string:
            ld a, (hl)
            or a
            ret z
            rst 16
            inc hl
            jr print_string

;----------------------------------------------------------------
; Board drawing
;----------------------------------------------------------------
; Attribute memory starts at 22528
; Board top-left attribute = 22664 (row 4, col 8)
BOARD_ATTR   equ 22528 + (4 * 32) + 8

draw_board:
            ld hl, BOARD_ATTR
            ld b, 0                 ; y
.row:
            push bc
            ld c, 0                 ; x
.col:
            push bc
            push hl
            call draw_cell          ; uses B=y, C=x, HL attr addr
            pop hl
            pop bc

            inc c
            ld a, c
            cp 8
            jr nz, .col

            ; next logical row: +64 bytes (2 attr rows)
            ld de, 64
            add hl, de
            pop bc
            inc b
            ld a, b
            cp 8
            jr nz, .row
            ret

draw_cell:
            push hl
            call owner_addr
            ld a, (hl)              ; owner: 0 empty,1 player,2 ai
            pop hl

            call owner_to_attr      ; returns A = attr byte
            ; write 2x2 attribute bytes
            ld (hl), a
            inc hl
            ld (hl), a
            ld de, 31               ; down one row (32-1)
            add hl, de
            ld (hl), a
            inc hl
            ld (hl), a
            ret

owner_to_attr:
            cp 1
            jr z, .player
            cp 2
            jr z, .ai
            ; empty: white paper, black ink
            ld a, 7 * 8 + 0
            ret
.player:
            ; player: red paper, white ink
            ld a, 2 * 8 + 7
            ret
.ai:
            ; ai: cyan paper, white ink
            ld a, 5 * 8 + 7
            ret

;----------------------------------------------------------------
; Owner map helpers
;----------------------------------------------------------------
; owner_map is 8x8 bytes: row-major
owner_addr:
            ld hl, owner_map
            ld d, 0
            ld a, b                 ; y
            rlca                    ; y*2
            rlca                    ; y*4
            rlca                    ; y*8
            ld d, a
            ld a, c                 ; x
            add a, d
            ld e, a
            add hl, de
            ret

init_owner_map:
            ld hl, owner_map
            ld b, 64
            ld a, 0
.clr:
            ld (hl), a
            inc hl
            djnz .clr

            ; Seed starting territories: top-left 3x3 player, bottom-right 3x3 ai
            ld b, 3
            ld c, 3
            call fill_block_player
            ld b, 5                 ; y start
            ld c, 5                 ; x start
            call fill_block_ai

            ld a, 64-18             ; moves remaining (64 minus claimed 18)
            ld (moves_remaining), a
            ret

fill_block_player:
            ld d, b
            ld e, c
            ld h, 3
.fbp_row:
            ld l, 3
.fbp_col:
            push bc
            push de
            ld b, d
            ld c, e
            call owner_addr
            ld (hl), 1
            pop de
            pop bc
            inc e
            dec l
            jr nz, .fbp_col
            inc d
            dec h
            jr nz, .fbp_row
            ret

fill_block_ai:
            ld d, b
            ld e, c
            ld h, 3
.fba_row:
            ld l, 3
.fba_col:
            push bc
            push de
            ld b, d
            ld c, e
            call owner_addr
            ld (hl), 2
            pop de
            pop bc
            inc e
            dec l
            jr nz, .fba_col
            inc d
            dec h
            jr nz, .fba_row
            ret

;----------------------------------------------------------------
; Cursor drawing
;----------------------------------------------------------------
highlight_cursor:
            call get_attr_addr
            call set_flash_block
            ret

clear_cursor:
            call get_attr_addr
            call clear_flash_block
            ret

get_attr_addr:
            ; HL = address of top-left attr of cursor cell
            ld hl, BOARD_ATTR
            ld a, (cursor_y)
            rlca                    ; *2
            rlca                    ; *4
            rlca                    ; *8
            rlca                    ; *16
            rlca                    ; *32
            rlca                    ; *64
            ld de, 0
            ld e, a
            add hl, de
            ld a, (cursor_x)
            add a, a                ; *2
            ld e, a
            add hl, de
            ret

set_flash_block:
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

clear_flash_block:
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

;----------------------------------------------------------------
; Input (Q,A,O,P for movement; SPACE to claim)
;----------------------------------------------------------------
read_input:
            ; simple debounce via small halt
            halt

            ld a, 0
            ld (space_pressed), a
            ld (move_dir), a

            ; Right (P) - row $DF, bit0 active low
            ld bc, $dffe
            in a, (c)
            bit 0, a
            jr nz, .check_left
            ld a, 1
            ld (move_dir), a
.check_left:
            ld bc, $dffe
            in a, (c)
            bit 1, a
            jr nz, .check_up
            ld a, 2
            ld (move_dir), a
.check_up:
            ld bc, $fbfe
            in a, (c)
            bit 0, a
            jr nz, .check_down
            ld a, 3
            ld (move_dir), a
.check_down:
            ld bc, $fdfe
            in a, (c)
            bit 0, a
            jr nz, .check_space
            ld a, 4
            ld (move_dir), a
.check_space:
            ld bc, $f7fe              ; row with SPACE (bit 0)
            in a, (c)
            bit 0, a
            jr nz, .move
            ld a, 1
            ld (space_pressed), a

.move:
            ld a, (move_dir)
            or a
            ret z

            call clear_cursor
            cp 1
            jr nz, .not_right
            ld a, (cursor_x)
            cp 7
            jr z, .not_right
            inc a
            ld (cursor_x), a
.not_right:
            ld a, (move_dir)
            cp 2
            jr nz, .not_left
            ld a, (cursor_x)
            or a
            jr z, .not_left
            dec a
            ld (cursor_x), a
.not_left:
            ld a, (move_dir)
            cp 3
            jr nz, .not_up
            ld a, (cursor_y)
            or a
            jr z, .not_up
            dec a
            ld (cursor_y), a
.not_up:
            ld a, (move_dir)
            cp 4
            jr nz, .done_move
            ld a, (cursor_y)
            cp 7
            jr z, .done_move
            inc a
            ld (cursor_y), a
.done_move:
            call highlight_cursor
            ret

;----------------------------------------------------------------
; Claiming cells
;----------------------------------------------------------------
maybe_claim:
            ld a, (space_pressed)
            or a
            ret z

            ; check if empty
            ld b, (cursor_y)
            ld c, (cursor_x)
            call owner_addr
            ld a, (hl)
            or a
            ret nz                    ; not empty

            ld (hl), 1                ; player claims
            call draw_cell
            call dec_moves
            ret

dec_moves:
            ld a, (moves_remaining)
            dec a
            ld (moves_remaining), a
            ret

;----------------------------------------------------------------
; AI pick and claim
;----------------------------------------------------------------
ai_pick_move:
            ld a, 0
            ld (best_score), a
            ld (best_x), a
            ld (best_y), a

            ld b, 0
.ai_row:
            ld c, 0
.ai_col:
            push bc
            call owner_addr
            ld a, (hl)
            or a
            jr nz, .skip_cell        ; skip non-empty

            ; score this cell
            ld b, (cursor_y)         ; save cursor temporarily
            ld c, (cursor_x)
            push bc

            pop bc                   ; restore B=y, C=x from loop
            call score_cell_ai       ; A=score

            ld e, a
            ld a, (best_score)
            cp e
            jr nc, .skip_cell_pop
            ld a, e
            ld (best_score), a
            ld a, c
            ld (best_x), a
            ld a, b
            ld (best_y), a
.skip_cell_pop:
            pop bc
            jr .after_cell

.skip_cell:
            pop bc
.after_cell:
            inc c
            ld a, c
            cp 8
            jr nz, .ai_col
            inc b
            ld a, b
            cp 8
            jr nz, .ai_row
            ret

; Heuristic: +2 per adjacent AI, +1 per neutral, -2 per player
; +1 random tiebreak from frame_counter bit0
score_cell_ai:
            ld a, 0
            ld (tmp_score), a
            call sc_up
            call sc_down
            call sc_left
            call sc_right
            ld a, (frame_counter)
            and %00000001
            ld b, a
            ld a, (tmp_score)
            add a, b
            ld (tmp_score), a
            ld a, (tmp_score)
            ret

sc_up:
            ld a, b
            or a
            ret z
            dec b
            call owner_addr
            ld a, (hl)
            call apply_neighbor
            inc b
            ret
sc_down:
            ld a, b
            cp 7
            ret z
            inc b
            call owner_addr
            ld a, (hl)
            call apply_neighbor
            dec b
            ret
sc_left:
            ld a, c
            or a
            ret z
            dec c
            call owner_addr
            ld a, (hl)
            call apply_neighbor
            inc c
            ret
sc_right:
            ld a, c
            cp 7
            ret z
            inc c
            call owner_addr
            ld a, (hl)
            call apply_neighbor
            dec c
            ret

apply_neighbor:
            cp 1
            jr z, .player
            cp 2
            jr z, .ai
            ; empty
            ld a, (tmp_score)
            inc a
            ld (tmp_score), a
            ret
.player:
            ld a, (tmp_score)
            sub 2
            ld (tmp_score), a
            ret
.ai:
            ld a, (tmp_score)
            add a, 2
            ld (tmp_score), a
            ret

ai_claim:
            ld b, (best_y)
            ld c, (best_x)
            call owner_addr
            ld a, 2
            ld (hl), a
            call draw_cell
            call dec_moves
            ret

;----------------------------------------------------------------
; Win detection
;----------------------------------------------------------------
check_winner:
            ld hl, 0
            ld (p1_count), hl
            ld (ai_count), hl

            ld b, 0
.cw_row:
            ld c, 0
.cw_col:
            push bc
            call owner_addr
            ld a, (hl)
            cp 1
            jr nz, .not_p1
            ld hl, (p1_count)
            inc hl
            ld (p1_count), hl
            jr .next_cell
.not_p1:
            cp 2
            jr nz, .next_cell
            ld hl, (ai_count)
            inc hl
            ld (ai_count), hl
.next_cell:
            pop bc
            inc c
            ld a, c
            cp 8
            jr nz, .cw_col
            inc b
            ld a, b
            cp 8
            jr nz, .cw_row

            ; compare
            ld hl, (p1_count)
            ld de, (ai_count)
            or a
            sbc hl, de
            jr z, .draw
            jr c, .ai_wins
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
            call print_at_12_8
            ret

print_at_12_8:
            ld a, 22
            rst 16
            ld a, 12
            rst 16
            ld a, 8
            rst 16
            jp print_string

;----------------------------------------------------------------
; Data
;----------------------------------------------------------------
title_text:      defb "INK WAR", 0
instr_text:      defb "QAOP MOVE, SPACE CLAIM", 0
p1_text:         defb "PLAYER WINS!", 0
ai_text:         defb "AI WINS!", 0
draw_text:       defb "DRAW!", 0

cursor_x:        defb 0
cursor_y:        defb 0
move_dir:        defb 0
space_pressed:   defb 0
moves_remaining: defb 0
best_score:      defb 0
best_x:          defb 0
best_y:          defb 0
tmp_score:       defb 0
frame_counter:   defb 0
p1_count:        defw 0
ai_count:        defw 0

owner_map:       defs 64

            end start
