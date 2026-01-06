;══════════════════════════════════════════════════════════════
; INK WAR
; A territory control game for the ZX Spectrum
; Unit 3: Movement
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
        ; Enable interrupts for HALT
        im 1
        ei

        ; Black border
        ld a, 0
        out (254), a

        ; Clear screen
        call clear_screen

        ; Draw the game board
        call draw_board

        ; Highlight cursor at starting position
        call get_cursor_addr
        call highlight_cursor

        ; Fall through to main loop

;───────────────────────────────────────
; Main game loop
;───────────────────────────────────────
main_loop:
        halt                    ; Wait for next frame

        ; Debounce timer
        ld a, (move_delay)
        dec a
        ld (move_delay), a
        jr nz, main_loop

        ; Reset timer
        ld a, 8
        ld (move_delay), a

        ; Check keyboard
        call check_keyboard

        jr main_loop

;───────────────────────────────────────
; Check keyboard and move cursor
;───────────────────────────────────────
check_keyboard:
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

;───────────────────────────────────────
; Get cursor address helper
;───────────────────────────────────────
get_cursor_addr:
        ld a, (cursor_y)
        ld b, a
        ld a, (cursor_x)
        ld c, a
        call get_cell_addr
        ret

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
; Get attribute address for a game cell
; Input: B = row (0-7), C = column (0-7)
; Output: HL = address
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
; Highlight cursor (set FLASH)
; Input: HL = address
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
; Clear cursor (reset FLASH)
; Input: HL = address
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
; Variables
;───────────────────────────────────────
cursor_x:       defb 0
cursor_y:       defb 0
move_delay:     defb 1          ; Start ready to move

        end start
