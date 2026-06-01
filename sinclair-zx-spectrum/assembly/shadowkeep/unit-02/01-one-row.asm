; ============================================================================
; SHADOWKEEP — Unit 2, Stage 1: One Row of Stone
; ============================================================================
; The keep wakes (BORDER + dark stone, repeated from Unit 1's final stage).
; Then a single horizontal line of bright-blue wall is laid down at row 2 —
; the keep starts to remember where the great hall's top wall used to be.
;
; This stage's new idea: DJNZ. The Z80's tightest two-instruction loop.
;
;   DJNZ target  →  decrement B; if B is not zero, jump to target.
;
; One register, one branch, one byte of opcode plus one of offset. We set
; B = 22 (the width of the room), write a wall cell, advance the pointer,
; loop. Twenty-two wall cells laid in a straight line.
; ============================================================================

WALL    equ $49       ; INK 1 (blue) on PAPER 1 + BRIGHT — vivid blue stone

            org     32768

start:
            ; --- BORDER black (from Unit 1) ---
            ld      a, 0
            out     ($FE), a

            ; --- dark stone fill (from Unit 1) ---
            ld      hl, $5800
            ld      de, $5801
            ld      (hl), $08
            ld      bc, 767
            ldir

            ; --- one row of wall ---
            ; The room will sit at row 2, col 5 in the attribute grid:
            ;   $5800 + (2 * 32) + 5 = $5845
            ; This stage draws only the top row — 22 cells of WALL.
            ld      a, WALL
            ld      de, $5845             ; row 2, col 5 — the room's top-left
            ld      b, 22                  ; 22 columns of wall

.row_loop:
            ld      (de), a                ; write a wall cell
            inc     de                     ; next column
            djnz    .row_loop              ; loop until B reaches 0

; ----------------------------------------------------------------------------
; Idle loop — wait for frames, never exit.
; ----------------------------------------------------------------------------

.idle:
            halt
            jr      .idle

            end     start
