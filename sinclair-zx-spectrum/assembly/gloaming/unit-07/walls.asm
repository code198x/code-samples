; ============================================================================
; GLOAMING — Unit 7: Walls
; ============================================================================
; The lamplighter can walk anywhere and harm nothing (Unit 6). Now we decide
; where he's *allowed* to go. The blue frame round the square has been pure
; decoration; this unit turns it into a boundary he cannot cross.
;
; Collision, the cheap and beautiful way: the map is already colour, and colour
; is already in memory (the whole point of Unit 1). So we don't need a separate
; table of "what's solid" — we read it straight from the attribute of the cell
; he's trying to enter.
;
; Look at the two cell types:
;
;   COBBLE = %0000 0 001   PAPER black (0)  — floor, walkable
;   WALL   = %0000 1 111   PAPER blue  (1)  — solid
;                     ^
;                     bit 3 = the bottom bit of PAPER
;
; A wall is the only thing with a non-black PAPER, so PAPER's bottom bit —
; bit 3 — is SET on walls and CLEAR on floor. One `BIT 3,(HL)` on the target
; cell's attribute answers "can I go there?". Set = wall = no.
;
; So each step now: work out the target cell, BIT-test its attribute, and only
; commit the move (restore / step / save / draw) if it's clear. Walk into the
; side walls and he simply stops — no bounds-checking code, just the map
; refusing him.
; ============================================================================

            org     32768

COBBLE      equ     %00000001       ; PAPER black, INK blue — floor
WALL        equ     %00001111       ; PAPER blue, INK white — solid
LAMP_ATTR   equ     %01000111       ; BRIGHT, PAPER black, INK white — the figure
WALL_BIT    equ     3               ; PAPER bit 0: set on walls, clear on floor

ROW         equ     11
ROW_THIRD   equ     ROW / 8
ROW_CHARROW equ     ROW - ROW_THIRD * 8
ROW_SCR     equ     $4000 + ROW_THIRD * $0800 + ROW_CHARROW * 32
ROW_ATTR    equ     $5800 + ROW * 32
START_COL   equ     15

KEYS_OP     equ     $DFFE

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

            call    save_under
            call    draw_lamp

; ============================================================================
; THE HEARTBEAT — test the target cell, move only if it isn't a wall.
; ============================================================================
            im      1
            ei

game_loop:
            halt

            ld      bc, KEYS_OP
            in      a, (c)
            bit     1, a            ; O (left)?
            jr      z, .step_left
            bit     0, a            ; P (right)?
            jr      z, .step_right
            jr      game_loop

.step_left:
            ld      a, (lamp_col)
            dec     a               ; A = the cell he wants to enter
            call    wall_at         ; NZ = wall, Z = clear  (A preserved)
            jr      nz, game_loop   ; wall — refuse the step
            ld      (target_col), a
            call    commit_move
            jr      game_loop

.step_right:
            ld      a, (lamp_col)
            inc     a
            call    wall_at
            jr      nz, game_loop
            ld      (target_col), a
            call    commit_move
            jr      game_loop

; ----------------------------------------------------------------------------
; wall_at — A = column to test. Reads that cell's attribute and BIT-tests it.
;   Returns NZ if it's a wall, Z if walkable. Leaves A unchanged.
; ----------------------------------------------------------------------------
wall_at:
            ld      e, a
            ld      d, 0
            ld      hl, ROW_ATTR
            add     hl, de
            bit     WALL_BIT, (hl)  ; set = wall, clear = floor
            ret

; ----------------------------------------------------------------------------
; commit_move — the move is clear: restore old cell, adopt target_col, save and
;   draw the new one.
; ----------------------------------------------------------------------------
commit_move:
            call    restore_under
            ld      a, (target_col)
            ld      (lamp_col), a
            call    save_under
            call    draw_lamp
            ret

; ----------------------------------------------------------------------------
; Address helpers (Unit 6).
; ----------------------------------------------------------------------------
scr_addr:
            ld      a, (lamp_col)
            ld      e, a
            ld      d, 0
            ld      hl, ROW_SCR
            add     hl, de
            ret

attr_addr:
            ld      a, (lamp_col)
            ld      e, a
            ld      d, 0
            ld      hl, ROW_ATTR
            add     hl, de
            ret

; ----------------------------------------------------------------------------
; save_under / restore_under / draw_lamp (Unit 6).
; ----------------------------------------------------------------------------
save_under:
            call    scr_addr
            ld      de, under_lamp
            ld      b, 8
.su:
            ld      a, (hl)
            ld      (de), a
            inc     de
            inc     h
            djnz    .su
            call    attr_addr
            ld      a, (hl)
            ld      (under_lamp + 8), a
            ret

restore_under:
            call    scr_addr
            ld      de, under_lamp
            ld      b, 8
.ru:
            ld      a, (de)
            ld      (hl), a
            inc     de
            inc     h
            djnz    .ru
            call    attr_addr
            ld      a, (under_lamp + 8)
            ld      (hl), a
            ret

draw_lamp:
            call    attr_addr
            ld      (hl), LAMP_ATTR
            call    scr_addr
            ld      de, lamplighter
            ld      b, 8
.dl:
            ld      a, (de)
            ld      (hl), a
            inc     de
            inc     h
            djnz    .dl
            ret

; ----------------------------------------------------------------------------
; State, buffer, and shape.
; ----------------------------------------------------------------------------
lamp_col:
            defb    START_COL
target_col:
            defb    0

under_lamp:
            defb    0, 0, 0, 0, 0, 0, 0, 0, 0

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
