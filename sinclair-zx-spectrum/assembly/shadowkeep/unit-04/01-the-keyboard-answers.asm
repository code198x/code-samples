; ============================================================================
; SHADOWKEEP — Unit 4, Stage 1: The Keyboard Answers
; ============================================================================
; In Unit 1 we wrote to port $FE to set the BORDER. The Spectrum's main I/O
; port is bidirectional, and this stage uses the other side: reading $FE
; tells us which keys are currently held down.
;
; The keyboard is wired as eight half-rows of five keys each. To read one
; half-row you place its mask in the high byte of the port (e.g. $FBFE for
; the Q row), `IN A, (C)`, and the low five bits of A come back with one
; bit per key — bit clear = key pressed, bit set = key released.
;
; Four indicator cells in a "+" arrangement below the great hall report
; which of Q/A/O/P is held. Press a direction key and watch its indicator
; flash bright yellow on dark stone. Release it and the indicator returns
; to dark. The thief still stands silently at the centre of the hall; the
; keyboard talks, but no one walks yet.
; ============================================================================

WALL       equ $48
FLOOR      equ $38
GOLD       equ $70
HERO_ATTR  equ $3A

STONE      equ $08       ; dark stone — keep's background fill
IND_OFF    equ $28       ; dark cyan — indicator at rest
IND_ON     equ $68       ; bright cyan — indicator while key held

; Indicator cell attribute addresses (centred below the room)
IND_NORTH  equ $5A6F     ; col 15, row 19  (Q)
IND_SOUTH  equ $5AAF     ; col 15, row 21  (A)
IND_WEST   equ $5A8E     ; col 14, row 20  (O)
IND_EAST   equ $5A90     ; col 16, row 20  (P)

; Keyboard ports
KBD_Q      equ $FBFE     ; Q row (Q, W, E, R, T)
KBD_A      equ $FDFE     ; A row (A, S, D, F, G)
KBD_P      equ $DFFE     ; P row (P, O, I, U, Y) — bits 0..4 in that order

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

            ; --- dark stone everywhere ---
            ld      hl, $5800
            ld      de, $5801
            ld      (hl), STONE
            ld      bc, 767
            ldir

            ; --- draw the great hall (room attributes) ---
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

            ; --- stone bitmaps for every WALL cell ---
            ld      hl, room_data
            ld      iy, bitmap_rows
            ld      b, 16
.row_loop2:
            push    bc
            ld      e, (iy+0)
            ld      d, (iy+1)
            inc     iy
            inc     iy
            ld      b, 22
.col_loop2:
            ld      a, (hl)
            cp      WALL
            jr      nz, .not_wall
            push    hl
            push    de
            push    bc
            ex      de, hl
            call    draw_stone
            pop     bc
            pop     de
            pop     hl
.not_wall:
            inc     hl
            inc     de
            djnz    .col_loop2
            pop     bc
            djnz    .row_loop2

            ; --- place the hero at the centre cell ---
            ld      a, HERO_ATTR
            ld      ($5950), a
            ld      hl, $4850
            ld      de, hero
            ld      b, 8
.hero_loop:
            ld      a, (de)
            ld      (hl), a
            inc     de
            inc     h
            djnz    .hero_loop

; ----------------------------------------------------------------------------
; Main loop: poll the keyboard once per frame, light each indicator while
; its direction key is held.
; ----------------------------------------------------------------------------

main_loop:
            halt                              ; wait for the next 50Hz IRQ

            ; --- read Q (north) ---
            ld      bc, KBD_Q
            in      a, (c)
            bit     0, a                       ; Z if Q pressed
            ld      a, IND_OFF
            jr      nz, .q_off
            ld      a, IND_ON
.q_off:
            ld      (IND_NORTH), a

            ; --- read A (south) ---
            ld      bc, KBD_A
            in      a, (c)
            bit     0, a                       ; Z if A pressed
            ld      a, IND_OFF
            jr      nz, .a_off
            ld      a, IND_ON
.a_off:
            ld      (IND_SOUTH), a

            ; --- read O and P together (shared row) ---
            ld      bc, KBD_P
            in      a, (c)
            ld      d, a                       ; save reading in D for the P check

            bit     1, a                       ; O = bit 1
            ld      a, IND_OFF
            jr      nz, .o_off
            ld      a, IND_ON
.o_off:
            ld      (IND_WEST), a

            bit     0, d                       ; P = bit 0 (from saved reading)
            ld      a, IND_OFF
            jr      nz, .p_off
            ld      a, IND_ON
.p_off:
            ld      (IND_EAST), a

            jr      main_loop

; ----------------------------------------------------------------------------
; draw_stone: write 8 bytes of stone_block to bitmap address in HL.
; ----------------------------------------------------------------------------

draw_stone:
            ld      de, stone_block
            ld      b, 8
.ds_loop:
            ld      a, (de)
            ld      (hl), a
            inc     de
            inc     h
            djnz    .ds_loop
            ret

stone_block:
            defb    %11111111, %10000001, %10000001, %10000001
            defb    %10000001, %10000001, %10000001, %11111111

hero:
            defb    %00011000, %00111100, %01111110, %01111110
            defb    %11111111, %01111110, %00111100, %00100100

bitmap_rows:
            defw    $4045, $4065, $4085, $40A5, $40C5, $40E5, $4805, $4825
            defw    $4845, $4865, $4885, $48A5, $48C5, $48E5, $5005, $5025

room_data:
            ; Row 0 — top wall
            defb    WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL
            defb    WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL
            ; Row 1 — broad altar
            defb    WALL, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR
            defb    GOLD, GOLD, GOLD, WALL, WALL, WALL, GOLD, GOLD, GOLD
            defb    FLOOR, FLOOR, FLOOR, FLOOR, WALL
            ; Row 2 — altar shoulders
            defb    WALL, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR
            defb    GOLD, GOLD, WALL, WALL, WALL, GOLD, GOLD
            defb    FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, WALL
            ; Row 3 — altar steps
            defb    WALL, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR
            defb    GOLD, WALL, GOLD, WALL, GOLD, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, WALL
            ; Row 4 — altar columns
            defb    WALL, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR
            defb    WALL, FLOOR, WALL, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, WALL
            ; Rows 5-14 — ten uniform rows
            rept 10
                defb    WALL, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR
                defb    FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR
                defb    FLOOR, WALL
            endm
            ; Row 15 — bottom wall
            defb    WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL
            defb    WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL

            end     start
