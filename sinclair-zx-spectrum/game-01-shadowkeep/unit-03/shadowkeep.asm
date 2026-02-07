; ============================================================================
; SHADOWKEEP — Unit 3: Room from Loops
; ============================================================================
; Draws a 9x5 room using DJNZ loops instead of individual writes.
;
; DJNZ = Decrement B and Jump if Not Zero.
; One loop fills an entire row. The room that took 25 writes in Unit 1
; now takes far fewer instructions.
; ============================================================================

            org     32768

; Attribute values
WALL        equ     $09             ; PAPER 1 (blue) + INK 1
FLOOR       equ     $38             ; PAPER 7 (white) + INK 0
TREASURE    equ     $70             ; BRIGHT + PAPER 6 (yellow)
HAZARD      equ     $90             ; FLASH + PAPER 2 (red)

; Room dimensions
ROOM_TOP    equ     10              ; Top wall row
ROOM_LEFT   equ     12              ; Left wall column
ROOM_WIDTH  equ     9               ; Total width including walls
ROOM_INNER  equ     7               ; Floor width (width - 2 walls)

; ----------------------------------------------------------------------------
; Entry point
; ----------------------------------------------------------------------------

start:
            ; Black border
            ld      a, 0
            out     ($fe), a

            ; Clear screen
            ld      hl, $4000
            ld      de, $4001
            ld      bc, 6911
            ld      (hl), 0
            ldir

            ; ==================================================================
            ; Draw the room
            ; ==================================================================

            ; --- Top wall (row 10, cols 12-20) ---
            ld      hl, $594c       ; $5800 + (10 x 32) + 12
            ld      b, ROOM_WIDTH
            ld      a, WALL
.top:       ld      (hl), a
            inc     hl
            djnz    .top

            ; --- Row 11: wall, floor, wall ---
            ld      hl, $596c       ; Row 11, col 12
            ld      a, WALL
            ld      (hl), a         ; Left wall
            inc     hl
            ld      a, FLOOR
            ld      b, ROOM_INNER
.r11:       ld      (hl), a
            inc     hl
            djnz    .r11
            ld      a, WALL
            ld      (hl), a         ; Right wall

            ; --- Row 12: wall, floor, wall ---
            ld      hl, $598c       ; Row 12, col 12
            ld      a, WALL
            ld      (hl), a
            inc     hl
            ld      a, FLOOR
            ld      b, ROOM_INNER
.r12:       ld      (hl), a
            inc     hl
            djnz    .r12
            ld      a, WALL
            ld      (hl), a

            ; --- Row 13: wall, floor, wall ---
            ld      hl, $59ac       ; Row 13, col 12
            ld      a, WALL
            ld      (hl), a
            inc     hl
            ld      a, FLOOR
            ld      b, ROOM_INNER
.r13:       ld      (hl), a
            inc     hl
            djnz    .r13
            ld      a, WALL
            ld      (hl), a

            ; --- Bottom wall (row 14, cols 12-20) ---
            ld      hl, $59cc       ; Row 14, col 12
            ld      b, ROOM_WIDTH
            ld      a, WALL
.bot:       ld      (hl), a
            inc     hl
            djnz    .bot

            ; --- Place treasure and hazard ---
            ld      a, TREASURE
            ld      ($5990), a      ; Row 12, col 16 (centre of room)

            ld      a, HAZARD
            ld      ($59af), a      ; Row 13, col 15

            ; --- Done ---

.loop:      halt
            jr      .loop

            end     start
