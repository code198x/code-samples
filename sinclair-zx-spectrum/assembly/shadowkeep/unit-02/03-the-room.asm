; ============================================================================
; SHADOWKEEP — Unit 2, Stage 3: The Room
; ============================================================================
; The same nested DJNZ. Same outer 16, same inner 22. The drawing code
; doesn't change. What changes is the inner loop's body: instead of writing
; a constant value to every cell, we now READ each byte from a data table
; and write it to the screen.
;
; The data table for this stage describes a uniform room — walls around the
; perimeter, white floor inside. 22 × 16 = 352 bytes total. The drawing
; code copies all 352 of them onto the screen.
;
; New ideas this stage:
;
;   1. HL as a source pointer alongside DE as a destination pointer. We
;      read from (HL), write to (DE), and advance both. This is the
;      canonical Z80 "copy a region" pattern.
;
;   2. Data-driven rendering. The drawing code knows nothing about the
;      room — it doesn't know where the walls are, doesn't know about
;      treasure, doesn't know about altars. It just copies bytes. The
;      room's identity lives entirely in the data table.
; ============================================================================

WALL    equ $49
FLOOR   equ $38

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
            ld      hl, room_data          ; source: room data
            ld      de, $5845              ; destination: attribute memory
            ld      b, 16                   ; outer: 16 rows

.row_loop:
            push    bc                      ; save outer counter
            ld      b, 22                   ; inner: 22 columns

.col_loop:
            ld      a, (hl)                 ; read attribute byte from room data
            ld      (de), a                 ; write it to attribute memory
            inc     hl                      ; next source byte
            inc     de                      ; next destination cell
            djnz    .col_loop               ; loop columns

            ; --- advance DE to next row's leftmost cell ---
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
; Room data: 22 columns × 16 rows = 352 bytes
; ----------------------------------------------------------------------------
; A uniform room: walls all around the perimeter, white floor inside.

room_data:

            ; Row 0 — top wall (22 wall cells)
            defb    WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL
            defb    WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL

            ; Rows 1-14 — 14 identical rows of wall + 20 floors + wall
            rept 14
                defb    WALL
                defb    FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR
                defb    FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR
                defb    WALL
            endm

            ; Row 15 — bottom wall (22 wall cells)
            defb    WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL
            defb    WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL

            end     start
