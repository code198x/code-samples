;──────────────────────────────────────────────────────────────
; INK WAR - Unit 4 sample (Claiming Cells)
; Adds SPACE to claim a cell for the player; no AI yet.
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

main_loop:
            halt
            call read_input
            call maybe_claim
            jr main_loop

;------------------------------------------------------------
; Board and owner map
;------------------------------------------------------------
init_owner_map:
            ld hl, owner_map
            ld b,64
            ld a,0
.clr:
            ld (hl),a
            inc hl
            djnz .clr
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
            jr z,.player
            ; empty
            ld a,7*8+0
            ret
.player:
            ld a,2*8+7
            ret

;------------------------------------------------------------
; Cursor and input
;------------------------------------------------------------
cursor_x: defb 0
cursor_y: defb 0
move_dir: defb 0
space_pressed: defb 0

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
            ret nz                  ; already claimed
            ld a,1
            ld (hl),a
            call draw_board
            call highlight_cursor
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

owner_map: defs 64

            end start
