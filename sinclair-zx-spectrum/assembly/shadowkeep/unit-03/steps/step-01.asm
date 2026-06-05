; Shadowkeep — Unit 3: A Place to Move
; Cumulative build; every step runs on its own. Narrative: the unit page.
; step-01 sets him walking — QAOP, wall-by-light, and save/restore the stone.

            org     32768

WALL_ATTR   equ     %01001000       ; BRIGHT — lit stone (solid)
FLOOR_ATTR  equ     %00001000       ; dim — dark slate (walkable)
THIEF       equ     %01001010       ; BRIGHT, PAPER 1 (blue), INK 2 (red)
WALL_BIT    equ     6               ; BRIGHT marks solid stone

START_COL   equ     15
START_ROW   equ     11
LAST_ROW    equ     23
LAST_COL    equ     31

KEYS_OP     equ     $DFFE           ; O = bit 1 (left), P = bit 0 (right)
KEYS_Q      equ     $FBFE           ; Q = bit 0 (up)
KEYS_A      equ     $FDFE           ; A = bit 0 (down)

; ----------------------------------------------------------------------------
; SETUP — build the hall, save the floor under the start cell, draw the thief,
; then run the frame-locked loop, stepping him once per frame.
; ----------------------------------------------------------------------------
start:
            ld      a, 0
            out     ($FE), a

            ld      a, START_COL
            ld      (thief_col), a
            ld      a, START_ROW
            ld      (thief_row), a

            call    draw_hall
            call    save_under
            call    draw_thief

            im      1
            ei
.loop:
            halt
            call    player_step
            jr      .loop

; ----------------------------------------------------------------------------
; player_step — read a direction, test the target cell, and move only if it's
; not a wall. Pure Gloaming, pointed at the thief.
; ----------------------------------------------------------------------------
player_step:
            ld      a, (thief_col)
            ld      (tcol), a
            ld      a, (thief_row)
            ld      (trow), a

            ld      bc, KEYS_OP
            in      a, (c)
            bit     1, a
            jr      z, .left
            bit     0, a
            jr      z, .right
            ld      bc, KEYS_Q
            in      a, (c)
            bit     0, a
            jr      z, .up
            ld      bc, KEYS_A
            in      a, (c)
            bit     0, a
            jr      z, .down
            ret

.left:
            ld      hl, tcol
            dec     (hl)
            jr      .move
.right:
            ld      hl, tcol
            inc     (hl)
            jr      .move
.up:
            ld      hl, trow
            dec     (hl)
            jr      .move
.down:
            ld      hl, trow
            inc     (hl)
.move:
            ld      a, (trow)
            ld      b, a
            ld      a, (tcol)
            ld      c, a
            call    wall_at
            ret     nz              ; a wall — stay put

            call    restore_under   ; put the floor back where he was
            ld      a, (tcol)
            ld      (thief_col), a
            ld      a, (trow)
            ld      (thief_row), a
            call    save_under      ; remember the floor he's stepping onto
            call    draw_thief
            ret

; wall_at — row in B, column in C. Z set (walkable) if the cell isn't BRIGHT.
wall_at:
            call    attr_addr_cr
            bit     WALL_BIT, (hl)
            ret

; ----------------------------------------------------------------------------
; The thief's save / restore / draw — Gloaming's, renamed. The nine-byte buffer
; holds the eight bitmap rows of dithered stone plus the floor's attribute.
; ----------------------------------------------------------------------------
pos_bc:
            ld      a, (thief_row)
            ld      b, a
            ld      a, (thief_col)
            ld      c, a
            ret

save_under:
            call    pos_bc
            call    scr_addr_cr
            ld      de, under_thief
            ld      b, 8
.save_row:
            ld      a, (hl)
            ld      (de), a
            inc     de
            inc     h
            djnz    .save_row
            call    pos_bc
            call    attr_addr_cr
            ld      a, (hl)
            ld      (under_thief + 8), a
            ret

restore_under:
            call    pos_bc
            call    scr_addr_cr
            ld      de, under_thief
            ld      b, 8
.restore_row:
            ld      a, (de)
            ld      (hl), a
            inc     de
            inc     h
            djnz    .restore_row
            call    pos_bc
            call    attr_addr_cr
            ld      a, (under_thief + 8)
            ld      (hl), a
            ret

draw_thief:
            call    pos_bc
            call    attr_addr_cr
            ld      (hl), THIEF
            call    pos_bc
            call    scr_addr_cr
            ld      de, thief
            ld      b, 8
.thief_row:
            ld      a, (de)
            ld      (hl), a
            inc     de
            inc     h
            djnz    .thief_row
            ret

; ----------------------------------------------------------------------------
; draw_hall / pick_tile / draw_tile — unchanged from Unit 2.
; ----------------------------------------------------------------------------
draw_hall:
            ld      b, 0
.hall_row:
            ld      c, 0
.hall_col:
            call    pick_tile
            call    draw_tile
            inc     c
            ld      a, c
            cp      LAST_COL + 1
            jr      nz, .hall_col
            inc     b
            ld      a, b
            cp      LAST_ROW + 1
            jr      nz, .hall_row
            ret

pick_tile:
            ld      a, b
            or      a
            jr      z, .wall
            cp      LAST_ROW
            jr      z, .wall
            ld      a, c
            or      a
            jr      z, .wall
            cp      LAST_COL
            jr      z, .wall
.floor:
            ld      hl, floor_tile
            ld      (tile_ptr), hl
            ld      a, FLOOR_ATTR
            ld      (tile_attr), a
            ret
.wall:
            ld      hl, wall_tile
            ld      (tile_ptr), hl
            ld      a, WALL_ATTR
            ld      (tile_attr), a
            ret

draw_tile:
            push    bc
            call    attr_addr_cr
            ld      a, (tile_attr)
            ld      (hl), a
            call    scr_addr_cr
            ld      de, (tile_ptr)
            ld      b, 8
.tile_row:
            ld      a, (de)
            ld      (hl), a
            inc     de
            inc     h
            djnz    .tile_row
            pop     bc
            ret

; ----------------------------------------------------------------------------
; scr_addr_cr / attr_addr_cr — carried from Gloaming.
; ----------------------------------------------------------------------------
scr_addr_cr:
            ld      a, b
            and     %00011000
            or      %01000000
            ld      h, a
            ld      a, b
            and     %00000111
            rrca
            rrca
            rrca
            or      c
            ld      l, a
            ret

attr_addr_cr:
            ld      a, b
            ld      l, a
            ld      h, 0
            add     hl, hl
            add     hl, hl
            add     hl, hl
            add     hl, hl
            add     hl, hl
            ld      de, $5800
            add     hl, de
            ld      a, c
            ld      e, a
            ld      d, 0
            add     hl, de
            ret

; ----------------------------------------------------------------------------
; Data.
; ----------------------------------------------------------------------------
floor_tile:
            defb    %10101010
            defb    %01010101
            defb    %10101010
            defb    %01010101
            defb    %10101010
            defb    %01010101
            defb    %10101010
            defb    %01010101

wall_tile:
            defb    %00010001
            defb    %00000000
            defb    %01000100
            defb    %00000000
            defb    %00010001
            defb    %00000000
            defb    %01000100
            defb    %00000000

thief:
            defb    %00011000
            defb    %00111100
            defb    %01111110
            defb    %01111110
            defb    %01111110
            defb    %01111110
            defb    %00111100
            defb    %00100100

thief_col:
            defb    START_COL
thief_row:
            defb    START_ROW
tcol:
            defb    0
trow:
            defb    0
tile_ptr:
            defw    0
tile_attr:
            defb    0
under_thief:
            defb    0, 0, 0, 0, 0, 0, 0, 0, 0

            end     start
