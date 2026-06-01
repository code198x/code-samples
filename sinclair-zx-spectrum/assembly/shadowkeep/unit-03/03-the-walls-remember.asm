; ============================================================================
; SHADOWKEEP — Unit 3, Stage 3: The Walls Remember
; ============================================================================
; One stone in one cell was the lesson. Now we lay stones across every wall.
;
; This requires two new ideas. First: every cell in the room needs to know
; its bitmap address, and the Spectrum's bitmap addressing is famously
; irregular — addresses don't simply advance by $20 from one screen row to
; the next. They skip through "thirds" of the screen in a way that's a joy
; once understood and a maze before. The clean answer is a lookup table:
; sixteen 16-bit addresses, one per room row, each giving the top-pixel-row
; bitmap address of that row's leftmost room cell.
;
; Second: a routine that walks the room data once already drawn as
; attributes, asks each cell "are you a wall?", and lays stone-block pixels
; wherever the answer is yes. The altar's wall cells get the same texture;
; the floor cells stay flat white (we wrote 0 to the bitmap during clear);
; the gold cells stay flat yellow.
;
; By the end of this stage every wall in the great hall — perimeter and
; altar both — reads as stone.
; ============================================================================

WALL    equ $48       ; INK 0 on PAPER 1 + BRIGHT — bright blue stone with black mortar
FLOOR   equ $38       ; INK 0 on PAPER 7 (white) — clean walking surface
GOLD    equ $70       ; INK 0 on PAPER 6 (yellow) + BRIGHT — glittering treasure

            org     32768

start:
            ; --- BORDER black ---
            ld      a, 0
            out     ($FE), a

            ; --- clear the bitmap ---
            ld      hl, $4000
            ld      de, $4001
            ld      (hl), 0
            ld      bc, 6143
            ldir

            ; --- dark stone everywhere outside the room ---
            ld      hl, $5800
            ld      de, $5801
            ld      (hl), $08
            ld      bc, 767
            ldir

            ; --- Pass 1: draw the great hall (room attributes) ---
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

            ; --- Pass 2: write stone bitmap for every WALL cell ---
            ld      hl, room_data           ; HL: source pointer through room_data
            ld      iy, bitmap_rows         ; IY: pointer into row-start lookup
            ld      b, 16                    ; outer counter: 16 rows

.row_loop2:
            push    bc                       ; save outer counter

            ; Load this row's bitmap start address into DE
            ld      e, (iy+0)
            ld      d, (iy+1)
            inc     iy
            inc     iy

            ld      b, 22                    ; inner counter: 22 columns

.col_loop2:
            ld      a, (hl)                  ; read room_data byte
            cp      WALL                     ; is it a wall?
            jr      nz, .not_wall

            ; Wall — draw stone block at current bitmap address
            push    hl                       ; save room_data pointer
            push    de                       ; save bitmap pointer
            push    bc                       ; save inner counter

            ex      de, hl                   ; HL <- bitmap destination
            call    draw_stone               ; writes 8 bytes at +$0100 stride

            pop     bc
            pop     de
            pop     hl

.not_wall:
            inc     hl                       ; next source byte
            inc     de                       ; next bitmap column

            djnz    .col_loop2

            pop     bc                       ; restore outer counter
            djnz    .row_loop2

.idle:
            halt
            jr      .idle

; ----------------------------------------------------------------------------
; draw_stone: write 8 bytes of stone_block to bitmap address in HL.
;   In:  HL = bitmap destination (top pixel row of one cell)
;   Out: HL = bitmap destination + $0800 (after eight $0100 strides)
;   Uses: A, B, DE, HL
; ----------------------------------------------------------------------------

draw_stone:
            ld      de, stone_block
            ld      b, 8
.ds_loop:
            ld      a, (de)
            ld      (hl), a
            inc     de
            inc     h                        ; +$0100: high byte +1
            djnz    .ds_loop
            ret

; ----------------------------------------------------------------------------
; Stone-block bitmap: bordered rectangle, 8 pixels square.
; ----------------------------------------------------------------------------

stone_block:
            defb    %11111111
            defb    %10000001
            defb    %10000001
            defb    %10000001
            defb    %10000001
            defb    %10000001
            defb    %10000001
            defb    %11111111

; ----------------------------------------------------------------------------
; bitmap_rows: top-pixel-row bitmap address (col 5) for each of the 16 room rows.
;
; The Spectrum bitmap is divided into three "thirds" of 64 rows each, and
; within a third, rows step by $0020. Crossing a third boundary, the address
; jumps. The lookup table absorbs all that irregularity into 32 fixed bytes.
; ----------------------------------------------------------------------------

bitmap_rows:
            defw    $4045       ; room row 0  = screen row 2  (third 0, row 2)
            defw    $4065       ; room row 1  = screen row 3  (third 0, row 3)
            defw    $4085       ; room row 2  = screen row 4
            defw    $40A5       ; room row 3  = screen row 5
            defw    $40C5       ; room row 4  = screen row 6
            defw    $40E5       ; room row 5  = screen row 7
            defw    $4805       ; room row 6  = screen row 8  (third 1, row 0)
            defw    $4825       ; room row 7  = screen row 9
            defw    $4845       ; room row 8  = screen row 10
            defw    $4865       ; room row 9  = screen row 11
            defw    $4885       ; room row 10 = screen row 12
            defw    $48A5       ; room row 11 = screen row 13
            defw    $48C5       ; room row 12 = screen row 14
            defw    $48E5       ; room row 13 = screen row 15
            defw    $5005       ; room row 14 = screen row 16 (third 2, row 0)
            defw    $5025       ; room row 15 = screen row 17

; ----------------------------------------------------------------------------
; Room data: the great hall (same as Unit 2 Stage 4)
; ----------------------------------------------------------------------------

room_data:

            ; Row 0 — top wall (unbroken)
            defb    WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL
            defb    WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL

            ; Row 1 — broad altar (3 cells wide) flanked by gold arcs
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

            ; Row 3 — altar steps
            defb    WALL
            defb    FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR
            defb    GOLD
            defb    WALL
            defb    GOLD
            defb    WALL
            defb    GOLD
            defb    FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR
            defb    WALL

            ; Row 4 — altar columns frame the aisle
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
