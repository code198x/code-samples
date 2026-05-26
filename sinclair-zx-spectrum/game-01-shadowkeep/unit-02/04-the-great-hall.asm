; ============================================================================
; SHADOWKEEP — Unit 2, Stage 4: The Great Hall
; ============================================================================
; The drawing code is IDENTICAL to Stage 3. Not a line different. What
; changes is the data: the room is now a hand-designed great hall with a
; stepped altar at the top centre and gold cascading down each side.
;
; That's the lesson, restated: the room is data, the data is a room. Same
; engine, any room — three rooms by the end of Phase 1, dozens by the end
; of the game, and not one of them will require touching the drawing code.
;
; The altar is a stepped feature descending from the top wall — a wide top
; tier of three wall cells, narrowing shoulders, then two parallel columns
; that frame an aisle. Gold cascades down each side: three across the top,
; two on the shoulders, one at the steps. The eye lands on the altar; the
; gold reads as sacred offerings; the aisle invites the player forward.
; ============================================================================

WALL    equ $49       ; INK 1 (blue) on PAPER 1 + BRIGHT — vivid blue stone
FLOOR   equ $38       ; INK 0 (black) on PAPER 7 (white) — clean walking surface
GOLD    equ $70       ; INK 0 on PAPER 6 (yellow) + BRIGHT — glittering treasure

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

            ; --- draw the room from the data table ---
            ld      hl, room_data
            ld      de, $5845
            ld      b, 16

.row_loop:
            push    bc
            ld      b, 22

.col_loop:
            ld      a, (hl)
            ld      (de), a
            inc     hl
            inc     de
            djnz    .col_loop

            ld      a, e
            add     a, 32 - 22
            ld      e, a
            jr      nc, .no_carry
            inc     d
.no_carry:

            pop     bc
            djnz    .row_loop

.idle:
            halt
            jr      .idle

; ----------------------------------------------------------------------------
; Room data: the great hall
; ----------------------------------------------------------------------------

room_data:

            ; Row 0 — top wall (unbroken)
            defb    WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL
            defb    WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL

            ; Row 1 — broad altar (3 cells wide) flanked by gold arcs (3 each side)
            defb    WALL
            defb    FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR
            defb    GOLD, GOLD, GOLD
            defb    WALL, WALL, WALL
            defb    GOLD, GOLD, GOLD
            defb    FLOOR, FLOOR, FLOOR, FLOOR
            defb    WALL

            ; Row 2 — altar shoulders narrow, gold continues
            defb    WALL
            defb    FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR
            defb    GOLD, GOLD
            defb    WALL, WALL, WALL
            defb    GOLD, GOLD
            defb    FLOOR, FLOOR, FLOOR, FLOOR, FLOOR
            defb    WALL

            ; Row 3 — altar steps: columns separated by aisle, single gold each side
            defb    WALL
            defb    FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR
            defb    GOLD
            defb    WALL
            defb    GOLD
            defb    WALL
            defb    GOLD
            defb    FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR
            defb    WALL

            ; Row 4 — altar columns frame the aisle (no gold)
            defb    WALL
            defb    FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR
            defb    WALL
            defb    FLOOR
            defb    WALL
            defb    FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR
            defb    WALL

            ; Rows 5-14 — ten uniform wall + 20 floors + wall rows
            rept 10
                defb    WALL
                defb    FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR
                defb    FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR
                defb    WALL
            endm

            ; Row 15 — bottom wall (unbroken)
            defb    WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL
            defb    WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL

            end     start
