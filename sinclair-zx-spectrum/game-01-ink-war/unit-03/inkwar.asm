;──────────────────────────────────────────────────────────────
; INK WAR - Unit 3 sample (Movement)
; Adds QAOP movement for the flashing cursor.
;──────────────────────────────────────────────────────────────

            org 32768

BOARD_ATTR   equ 22528 + (4 * 32) + 8

start:
            ld a,0
            out (254),a
            call 3435
            ld a,7
            ld (23693),a

            call draw_board
            call highlight_cursor

main_loop:
            halt
            call read_input
            call move_cursor
            jr main_loop

; Draw blank board
draw_board:
            ld hl, BOARD_ATTR
            ld b,0
.row:
            push bc
            ld c,0
.col:
            ld a,7*8+0
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

cursor_x: defb 0
cursor_y: defb 0
move_dir: defb 0

read_input:
            ld a,0
            ld (move_dir),a

            ld bc,$dffe       ; P row (P,O,I,U,Y)
            in a,(c)
            bit 0,a
            jr nz,.check_left
            ld a,1            ; right
            ld (move_dir),a
.check_left:
            ld bc,$dffe
            in a,(c)
            bit 1,a
            jr nz,.check_up
            ld a,2            ; left
            ld (move_dir),a
.check_up:
            ld bc,$fbfe       ; Q row (Q,W,E,R,T)
            in a,(c)
            bit 0,a
            jr nz,.check_down
            ld a,3            ; up
            ld (move_dir),a
.check_down:
            ld bc,$fdfe       ; A row (A,S,D,F,G)
            in a,(c)
            bit 0,a
            jr nz,.done
            ld a,4            ; down
            ld (move_dir),a
.done:
            ret

move_cursor:
            ld a,(move_dir)
            or a
            ret z
            call clear_cursor
            cp 1
            jr nz,.not_right
            ld a,(cursor_x)
            cp 7
            jr z,.not_right
            inc a
            ld (cursor_x),a
.not_right:
            ld a,(move_dir)
            cp 2
            jr nz,.not_left
            ld a,(cursor_x)
            or a
            jr z,.not_left
            dec a
            ld (cursor_x),a
.not_left:
            ld a,(move_dir)
            cp 3
            jr nz,.not_up
            ld a,(cursor_y)
            or a
            jr z,.not_up
            dec a
            ld (cursor_y),a
.not_up:
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
