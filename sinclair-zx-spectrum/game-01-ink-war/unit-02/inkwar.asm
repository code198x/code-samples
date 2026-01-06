;══════════════════════════════════════════════════════════════
; INK WAR
; A territory control game for the ZX Spectrum
; Unit 2: The Cursor
;══════════════════════════════════════════════════════════════

        org $8000

;───────────────────────────────────────
; Constants
;───────────────────────────────────────
ATTR_BASE       equ 22528       ; Start of attribute memory
BOARD_ATTR      equ 22664       ; Board starts at row 4, col 8
BOARD_SIZE      equ 8           ; 8x8 game cells

; Colours (paper * 8 + ink)
WHITE_ON_WHITE  equ %00111111   ; Paper 7, Ink 7
RED_ON_RED      equ %00010010   ; Paper 2, Ink 2
CYAN_ON_CYAN    equ %00101101   ; Paper 5, Ink 5

;───────────────────────────────────────
; Entry point
;───────────────────────────────────────
start:
        ; Black border
        ld a, 0
        out (254), a

        ; Clear screen
        call clear_screen

        ; Draw the game board
        call draw_board

        ; Highlight cursor at starting position
        ld a, (cursor_y)
        ld b, a
        ld a, (cursor_x)
        ld c, a
        call get_cell_addr
        call highlight_cursor

        ; Main loop
.hang:
        halt
        jr .hang

;───────────────────────────────────────
; Clear screen to black
;───────────────────────────────────────
clear_screen:
        ; Clear pixel memory
        ld hl, 16384
        ld de, 16385
        ld bc, 6143
        ld (hl), 0
        ldir

        ; Clear attributes to black on black
        ld hl, ATTR_BASE
        ld de, ATTR_BASE + 1
        ld bc, 767
        ld (hl), 0
        ldir
        ret

;───────────────────────────────────────
; Draw the 8x8 game board
; All cells start as white (neutral)
;───────────────────────────────────────
draw_board:
        ld hl, BOARD_ATTR
        ld b, BOARD_SIZE        ; 8 rows of game cells

.row_loop:
        push bc
        ld b, BOARD_SIZE        ; 8 columns of game cells

.cell_loop:
        push bc
        push hl

        ; Fill 2x2 character block with white
        ld a, WHITE_ON_WHITE

        ; Top-left
        ld (hl), a
        ; Top-right
        inc hl
        ld (hl), a
        ; Bottom-left (next row, back one column)
        ld de, 31
        add hl, de
        ld (hl), a
        ; Bottom-right
        inc hl
        ld (hl), a

        pop hl
        ; Move to next cell (2 columns right)
        inc hl
        inc hl

        pop bc
        djnz .cell_loop

        ; Move to next row of cells
        ; We're at column 16 (8 cells × 2), need to go to column 8 of next row
        ; That's: 32 - 16 + 32 = 48 bytes forward... but we drew 2 rows
        ; Actually: move down 2 rows (64 bytes) minus the 16 we moved right
        ; = 64 - 16 = 48? No wait...
        ; After 8 cells we're at column 8 + 16 = 24
        ; Need column 8 of row +2
        ; Easier: just reset to start of next game row
        pop bc
        push bc
        ld a, BOARD_SIZE
        sub b                   ; A = rows completed (1-8)
        inc a                   ; A = next row number (2-9 or 1 if done)

        ; If B=0 we're done, but djnz handles that
        ; Calculate: BOARD_ATTR + (row * 64)
        ld h, 0
        ld l, a
        add hl, hl              ; × 2
        add hl, hl              ; × 4
        add hl, hl              ; × 8
        add hl, hl              ; × 16
        add hl, hl              ; × 32
        add hl, hl              ; × 64
        ld de, BOARD_ATTR
        add hl, de

        pop bc
        djnz .row_loop

        ret

;───────────────────────────────────────
; Get attribute address for a game cell
; Input: B = row (0-7), C = column (0-7)
; Output: HL = address of top-left attribute
;───────────────────────────────────────
get_cell_addr:
        ld hl, BOARD_ATTR

        ; Add row offset: y × 64
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

        ; Add column offset: x × 2
        ld a, c
        add a, a
        ld e, a
        ld d, 0
        add hl, de

        ret

;───────────────────────────────────────
; Highlight a cell by setting FLASH bit
; Input: HL = address of top-left attribute
;───────────────────────────────────────
highlight_cursor:
        ; Top-left
        ld a, (hl)
        set 7, a
        ld (hl), a

        ; Top-right
        inc hl
        ld a, (hl)
        set 7, a
        ld (hl), a

        ; Move to bottom-left (31 bytes forward)
        ld de, 31
        add hl, de

        ; Bottom-left
        ld a, (hl)
        set 7, a
        ld (hl), a

        ; Bottom-right
        inc hl
        ld a, (hl)
        set 7, a
        ld (hl), a

        ret

;───────────────────────────────────────
; Variables
;───────────────────────────────────────
cursor_x:       defb 0
cursor_y:       defb 0

        end start
