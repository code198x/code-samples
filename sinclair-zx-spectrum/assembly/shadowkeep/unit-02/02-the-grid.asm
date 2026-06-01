; ============================================================================
; SHADOWKEEP — Unit 2, Stage 2: The Grid
; ============================================================================
; The room's full 22×16 area, filled solid with wall. Not yet a room — just
; a block of stone the size and shape the great hall will occupy. The keep
; knows where the room WILL be, even if it doesn't yet know what's inside.
;
; This stage's new idea: nested DJNZ. The Z80's tightest 2D iteration.
;
; One DJNZ inside another. Outer counter = rows (16); inner counter = cols
; (22). But the inner loop CLOBBERS B — that's how DJNZ works. So we PUSH
; the outer counter onto the stack before the inner loop runs, and POP it
; back when the inner finishes. The stack is how we juggle registers when
; we don't have enough.
;
; Plus: between rows, we have to advance DE past the cells outside the
; room. The screen is 32 cells wide; the room is 22 cells wide; we skip
; (32 - 22) = 10 cells to reach the next row's leftmost cell. Because DE
; is a register pair (D high, E low), we add to E with regular 8-bit
; arithmetic and handle the carry into D manually.
; ============================================================================

WALL    equ $49       ; INK 1 (blue) on PAPER 1 + BRIGHT — vivid blue stone

            org     32768

start:
            ; --- BORDER + dark stone (from Unit 1) ---
            ld      a, 0
            out     ($FE), a
            ld      hl, $5800
            ld      de, $5801
            ld      (hl), $08
            ld      bc, 767
            ldir

            ; --- fill the 22×16 room area with wall ---
            ld      de, $5845             ; row 2, col 5
            ld      b, 16                  ; outer: 16 rows

.row_loop:
            push    bc                     ; save outer counter (B is reused below)
            ld      b, 22                  ; inner: 22 columns
            ld      a, WALL                ; reload A (clobbered by row-advance below)

.col_loop:
            ld      (de), a                ; write a wall cell
            inc     de                     ; next column
            djnz    .col_loop              ; loop columns

            ; --- advance DE to next row's leftmost cell ---
            ; DE points one past the right edge of the row we just drew.
            ; Add (32 - 22) = 10 to E to reach the start of the next row.
            ld      a, e
            add     a, 32 - 22
            ld      e, a
            jr      nc, .no_carry          ; carry into D if E wrapped
            inc     d
.no_carry:

            pop     bc                     ; restore outer counter
            djnz    .row_loop              ; loop rows

.idle:
            halt
            jr      .idle

            end     start
