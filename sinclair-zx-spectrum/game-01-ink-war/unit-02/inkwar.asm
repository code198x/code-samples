;──────────────────────────────────────────────────────────────
; INK WAR - Unit 2 sample (Cursor)
; Adds a flashing cursor on the board (Unit 1 base assumed).
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

.hang:      halt
            jr .hang

; Draw blank board (white/black)
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

highlight_cursor:
            call get_attr_addr
            call set_flash_block
            ret

get_attr_addr:
            ld hl, BOARD_ATTR
            ld a,(cursor_y)
            rlca
            rlca
            rlca
            rlca
            rlca
            rlca   ; *64
            ld e,a
            ld d,0
            add hl,de
            ld a,(cursor_x)
            add a,a
            ld e,a
            add hl,de
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

            end start
