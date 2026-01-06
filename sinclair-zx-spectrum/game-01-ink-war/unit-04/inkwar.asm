;══════════════════════════════════════════════════════════════
; INK WAR
; A territory control game for the ZX Spectrum
; Unit 4: Claiming Cells
;══════════════════════════════════════════════════════════════

        org $8000

;───────────────────────────────────────
; Constants
;───────────────────────────────────────
ATTR_BASE       equ 22528
BOARD_ATTR      equ 22664
BOARD_SIZE      equ 8

WHITE_ON_WHITE  equ %00111111
RED_ON_RED      equ %00010010
CYAN_ON_CYAN    equ %00101101

;───────────────────────────────────────
; Entry point
;───────────────────────────────────────
start:
        im 1
        ei

        ld a, 0
        out (254), a

        call clear_screen
        call draw_board
        call get_cursor_addr
        call highlight_cursor

;───────────────────────────────────────
; Main game loop
;───────────────────────────────────────
main_loop:
        halt

        ld a, (move_delay)
        dec a
        ld (move_delay), a
        jr nz, main_loop

        ld a, 8
        ld (move_delay), a

        call check_keyboard

        jr main_loop

;───────────────────────────────────────
; Check keyboard
;───────────────────────────────────────
check_keyboard:
        ; SPACE = claim
        call check_space_edge
        jr nz, .not_space
        call claim_cell
        ret
.not_space:
        ; Q = up
        ld bc, $fbfe
        in a, (c)
        bit 0, a
        jr nz, .not_up
        call move_up
        ret
.not_up:
        ; A = down
        ld bc, $fdfe
        in a, (c)
        bit 0, a
        jr nz, .not_down
        call move_down
        ret
.not_down:
        ; O = left
        ld bc, $dffe
        in a, (c)
        bit 1, a
        jr nz, .not_left
        call move_left
        ret
.not_left:
        ; P = right
        ld bc, $dffe
        in a, (c)
        bit 0, a
        jr nz, .not_right
        call move_right
        ret
.not_right:
        ret

;───────────────────────────────────────
; Check SPACE with edge detection
;───────────────────────────────────────
check_space_edge:
        ld bc, $7ffe
        in a, (c)
        bit 0, a
        jr nz, .released

        ld a, (space_held)
        or a
        jr nz, .already_held

        ld a, 1
        ld (space_held), a
        xor a
        ret

.already_held:
        or 1
        ret

.released:
        xor a
        ld (space_held), a
        or 1
        ret

;───────────────────────────────────────
; Claim the current cell
;───────────────────────────────────────
claim_cell:
        ld a, (cursor_y)
        ld b, a
        ld a, (cursor_x)
        ld c, a
        call get_board_addr

        ; Check if neutral
        ld a, (hl)
        or a
        ret nz

        ; Claim it
        ld a, (current_player)
        ld (hl), a

        ; Update display
        call set_cell_colour

        ret

;───────────────────────────────────────
; Set cell to current player's colour
;───────────────────────────────────────
set_cell_colour:
        ld a, (current_player)
        cp 1
        jr z, .red
        ld a, CYAN_ON_CYAN
        jr .got_colour
.red:
        ld a, RED_ON_RED
.got_colour:
        ld b, a

        push bc
        ld a, (cursor_y)
        ld b, a
        ld a, (cursor_x)
        ld c, a
        call get_cell_addr
        pop bc

        ld (hl), b
        inc hl
        ld (hl), b
        ld de, 31
        add hl, de
        ld (hl), b
        inc hl
        ld (hl), b

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
        ld e, a
        ld d, 0
        add hl, de

        ld a, c
        ld e, a
        ld d, 0
        add hl, de

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
        ret

get_cursor_addr:
        ld a, (cursor_y)
        ld b, a
        ld a, (cursor_x)
        ld c, a
        call get_cell_addr
        ret

;───────────────────────────────────────
; Screen routines
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
; Variables
;───────────────────────────────────────
cursor_x:       defb 0
cursor_y:       defb 0
move_delay:     defb 1
space_held:     defb 0
current_player: defb 1
board_state:    defs 64

        end start
