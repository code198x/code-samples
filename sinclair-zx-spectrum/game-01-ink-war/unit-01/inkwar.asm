;──────────────────────────────────────────────────────────────
; INK WAR
; A territory control game for the ZX Spectrum
; Unit 1: The Board
;──────────────────────────────────────────────────────────────

            org 32768

start:
            ; Set border to black
            ld a, 0
            out (254), a

            ; Clear screen using ROM routine
            call 3435           ; CLS

            ; Set permanent colours: white ink on black paper
            ld a, 7             ; White ink (7), black paper (0)
            ld (23693), a       ; ATTR_P system variable

            ; Print title at top of screen
            ld a, 22            ; AT control code
            rst 16
            ld a, 0             ; row 0
            rst 16
            ld a, 10            ; column 10
            rst 16

            ld hl, title_text
            call print_string

            ; Print instructions at bottom (before drawing board)
            ld a, 22            ; AT control code
            rst 16
            ld a, 21            ; row 21
            rst 16
            ld a, 0             ; column 0
            rst 16

            ld hl, instructions
            call print_string

            ; Draw the game board LAST (direct to attribute memory)
            call draw_board

            ; Infinite loop - we're done
.hang:
            halt
            jr .hang

;──────────────────────────────────────────────────────────────
; Print null-terminated string at HL
;──────────────────────────────────────────────────────────────
print_string:
            ld a, (hl)
            or a
            ret z
            rst 16
            inc hl
            jr print_string

;──────────────────────────────────────────────────────────────
; Draw the 8x8 game board with coloured cells
; Each cell is 2x2 character cells
; Board starts at screen row 4, column 8
;──────────────────────────────────────────────────────────────
draw_board:
            ld hl, 22528 + (4 * 32) + 8

            ld a, 0
            ld (cell_y), a

.row_loop:
            call draw_cell_row

            ld de, 32
            add hl, de

            call draw_cell_row

            add hl, de

            ld a, (cell_y)
            inc a
            ld (cell_y), a
            cp 8
            jr nz, .row_loop

            ret

;──────────────────────────────────────────────────────────────
; Draw one attribute row of cells (8 cells, each 2 chars wide)
; HL = attribute address for start of row
;──────────────────────────────────────────────────────────────
draw_cell_row:
            push hl

            ld a, 0
            ld (cell_x), a

.cell_loop:
            call get_cell_colour

            ld (hl), a
            inc hl
            ld (hl), a
            inc hl

            ld a, (cell_x)
            inc a
            ld (cell_x), a
            cp 8
            jr nz, .cell_loop

            pop hl
            ret

;──────────────────────────────────────────────────────────────
; Get colour for cell at (cell_x, cell_y)
; Returns attribute byte in A
;──────────────────────────────────────────────────────────────
get_cell_colour:
            ld a, (cell_x)
            cp 3
            jr nc, .not_red
            ld a, (cell_y)
            cp 3
            jr nc, .not_red

            ld a, 2 * 8 + 7
            ret

.not_red:
            ld a, (cell_x)
            cp 5
            jr c, .neutral
            ld a, (cell_y)
            cp 5
            jr c, .neutral

            ld a, 5 * 8 + 7
            ret

.neutral:
            ld a, 7 * 8 + 0
            ret

;──────────────────────────────────────────────────────────────
; Variables
;──────────────────────────────────────────────────────────────
cell_x:     defb 0
cell_y:     defb 0

;──────────────────────────────────────────────────────────────
; Data
;──────────────────────────────────────────────────────────────
title_text:
            defb "INK WAR", 0

instructions:
            defb "Claim the board. Control wins.", 0

            end start
