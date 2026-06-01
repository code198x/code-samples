; ============================================================================
; GLOAMING — Unit 5: One Step
; ============================================================================
; The machine can feel the keys (Unit 4) — now it acts on them. Hold O and the
; lamplighter steps left; hold P and he steps right. This is the first half of
; Gloaming's second big technique, the *cell sprite*: a figure that has a
; position, and moves by being rubbed out where he was and drawn where he's
; going.
;
; Two new ideas:
;
;   1. His position is no longer fixed in the source — it's a byte in memory,
;      `lamp_col`, that we change as he walks. State the program keeps and
;      edits is what makes a thing a *game* and not a picture.
;
;   2. Moving = ERASE then DRAW. Blank the eight bitmap bytes of his old cell,
;      change the column, draw his shape in the new one. Do it every frame a
;      key is held and he glides cell by cell along his row.
;
; He moves only left and right for now, so he never leaves one character row —
; and that keeps the address arithmetic gentle. Every cell in a row shares the
; same screen "third" and the same row-within-third, so the address of his
; cell is simply ROW_SCR + col. No thirds to decode; just add the column.
;
; >>> THE ASSUMPTION, NAMED OUT LOUD <<<
; Erasing means writing zeros over his cell. That only looks right because the
; floor is BLANK — cobbles are pure attribute colour, no pixels to destroy. The
; moment he steps over something with pixels (a lamp, in Unit 9) this naive
; erase would rub it out too. Unit 6 fixes it by saving what's underneath
; before drawing. For now: blank floor, blank erase, and it works.
; ============================================================================

            org     32768

; --- the cell vocabulary (from Unit 1) ---
COBBLE      equ     %00000001       ; PAPER black, INK blue — dark ground
WALL        equ     %00001111       ; PAPER blue, INK white — pale stone
LAMP_ATTR   equ     %01000111       ; BRIGHT, PAPER black, INK white — the figure

; --- his row is fixed; only his column changes ---
ROW         equ     11
ROW_THIRD   equ     ROW / 8                 ; which screen third (0,1,2)
ROW_CHARROW equ     ROW - ROW_THIRD * 8     ; row within that third (0-7)
ROW_SCR     equ     $4000 + ROW_THIRD * $0800 + ROW_CHARROW * 32   ; col-0 of the row
ROW_ATTR    equ     $5800 + ROW * 32                               ; col-0 attribute
START_COL   equ     15

KEYS_OP     equ     $DFFE           ; half-row with P(bit0) and O(bit1)

; ============================================================================
; SETUP — runs once.
; ============================================================================
start:
            ld      a, 0            ; border black
            out     ($FE), a

            ld      hl, $5800       ; wash the grid in cobbles
            ld      de, $5801
            ld      (hl), COBBLE
            ld      bc, 767
            ldir

            ld      hl, $5800       ; wall frame — top row
            ld      b, 32
.top:
            ld      (hl), WALL
            inc     hl
            djnz    .top

            ld      hl, $5AE0       ; bottom row
            ld      b, 32
.bottom:
            ld      (hl), WALL
            inc     hl
            djnz    .bottom

            ld      hl, $5800       ; left and right columns
            ld      b, 24
.sides:
            ld      (hl), WALL
            push    hl
            ld      de, 31
            add     hl, de
            ld      (hl), WALL
            pop     hl
            ld      de, 32
            add     hl, de
            djnz    .sides

            call    draw_lamp       ; draw him once, at his starting column

; ============================================================================
; THE HEARTBEAT — read a direction, and if held, step that way.
; ============================================================================
            im      1
            ei

game_loop:
            halt

            ; --- INPUT: which way is held? ---
            ld      bc, KEYS_OP
            in      a, (c)          ; bottom bits, 0 = held
            bit     1, a            ; O (left)?
            jr      z, .step_left
            bit     0, a            ; P (right)?
            jr      z, .step_right
            jr      game_loop       ; nothing held — hold position

.step_left:
            call    erase_lamp      ; rub him out where he is
            ld      a, (lamp_col)
            dec     a               ; one cell left
            ld      (lamp_col), a
            call    draw_lamp       ; draw him where he's going
            jr      game_loop

.step_right:
            call    erase_lamp
            ld      a, (lamp_col)
            inc     a               ; one cell right
            ld      (lamp_col), a
            call    draw_lamp
            jr      game_loop

; ----------------------------------------------------------------------------
; draw_lamp — colour his cell and stamp his shape into it.
;   reads lamp_col; cell address = ROW_SCR + col, attribute = ROW_ATTR + col.
; ----------------------------------------------------------------------------
draw_lamp:
            ld      a, (lamp_col)
            ld      e, a
            ld      d, 0            ; DE = column offset
            ld      hl, ROW_ATTR
            add     hl, de
            ld      (hl), LAMP_ATTR ; his cell takes the figure's colour

            ld      hl, ROW_SCR
            add     hl, de          ; HL = top row of his cell
            ld      de, lamplighter ; DE now walks the shape
            ld      b, 8
.draw_row:
            ld      a, (de)
            ld      (hl), a
            inc     de
            inc     h               ; down one screen row (+256)
            djnz    .draw_row
            ret

; ----------------------------------------------------------------------------
; erase_lamp — blank his cell back to bare cobbles.
;   (Safe ONLY because the floor has no pixels — see the note up top.)
; ----------------------------------------------------------------------------
erase_lamp:
            ld      a, (lamp_col)
            ld      e, a
            ld      d, 0
            ld      hl, ROW_ATTR
            add     hl, de
            ld      (hl), COBBLE    ; the vacated cell is cobbles again

            ld      hl, ROW_SCR
            add     hl, de
            ld      b, 8
            xor     a               ; A = 0 — a blank pixel row
.erase_row:
            ld      (hl), a
            inc     h
            djnz    .erase_row
            ret

; ----------------------------------------------------------------------------
; State and shape.
; ----------------------------------------------------------------------------
lamp_col:
            defb    START_COL       ; his column — changes as he walks

lamplighter:
            defb    %00111100       ; ..XXXX..   head
            defb    %00111100       ; ..XXXX..   head
            defb    %00011000       ; ...XX...   neck
            defb    %01111110       ; .XXXXXX.   arms
            defb    %00011000       ; ...XX...   body
            defb    %00011000       ; ...XX...   body
            defb    %00100100       ; ..X..X..   legs
            defb    %01000010       ; .X....X.   feet

            end     start
