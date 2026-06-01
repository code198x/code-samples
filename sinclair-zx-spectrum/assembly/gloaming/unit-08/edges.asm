; ============================================================================
; GLOAMING — Unit 8: Edges
; ============================================================================
; The lamplighter walks left and right, blocked by the side walls (Unit 7).
; This unit completes the movement engine: up and down as well, bounded on all
; four sides. By the end he roams the whole square — and is properly shut inside
; it. The cell-sprite technique is finished here.
;
; Two things change. The controls become the classic QAOP: Q up, A down, O
; left, P right. And — the big one — his ROW can change now, not just his
; column. The moment he moves between rows, the gentle "address = ROW_SCR + col"
; from Units 5-7 stops working, because different rows live in different parts
; of the Spectrum's awkward screen layout. The full arithmetic from Unit 2
; comes back, now done at run time for any (col, row):
;
;   high byte = $40 + (row AND $18)          ; which third  (×8 in the high byte)
;   low  byte = ((row AND 7) << 5) OR col    ; row-within-third ×32, plus column
;
; That one routine, scr_addr_cr, turns any cell into a screen address. The
; attribute address is the easy linear one, $5800 + row*32 + col. Collision
; (Unit 7) doesn't change at all — it already tested an arbitrary target cell;
; now the target can be a row away, and the top and bottom walls catch him just
; as the sides do.
; ============================================================================

            org     32768

COBBLE      equ     %00000001       ; PAPER black, INK blue — floor
WALL        equ     %00001111       ; PAPER blue, INK white — solid
LAMP_ATTR   equ     %01000111       ; BRIGHT, PAPER black, INK white — the figure
WALL_BIT    equ     3               ; PAPER bit 0: set on walls, clear on floor

START_COL   equ     15
START_ROW   equ     11

KEYS_OP     equ     $DFFE           ; O (bit1) left, P (bit0) right
KEYS_Q      equ     $FBFE           ; Q (bit0) up
KEYS_A      equ     $FDFE           ; A (bit0) down

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
; THE HEARTBEAT — pick a direction (QAOP), test the target, move if clear.
; ============================================================================
            im      1
            ei

game_loop:
            halt

            ld      a, (lamp_col)   ; start the target at his current cell
            ld      (tcol), a
            ld      a, (lamp_row)
            ld      (trow), a

            ld      bc, KEYS_OP     ; O / P
            in      a, (c)
            bit     1, a            ; O — left
            jr      z, .left
            bit     0, a            ; P — right
            jr      z, .right
            ld      bc, KEYS_Q      ; Q — up
            in      a, (c)
            bit     0, a
            jr      z, .up
            ld      bc, KEYS_A      ; A — down
            in      a, (c)
            bit     0, a
            jr      z, .down
            jr      game_loop       ; nothing held

.left:
            ld      hl, tcol
            dec     (hl)
            jr      .try
.right:
            ld      hl, tcol
            inc     (hl)
            jr      .try
.up:
            ld      hl, trow
            dec     (hl)
            jr      .try
.down:
            ld      hl, trow
            inc     (hl)
.try:
            ld      a, (trow)       ; test the target cell
            ld      b, a
            ld      a, (tcol)
            ld      c, a
            call    wall_at         ; NZ = wall
            jr      nz, game_loop   ; blocked — stay put

            call    restore_under   ; clear — commit the move
            ld      a, (tcol)
            ld      (lamp_col), a
            ld      a, (trow)
            ld      (lamp_row), a
            call    save_under
            call    draw_lamp
            jr      game_loop

; ----------------------------------------------------------------------------
; scr_addr_cr — B=row(0-23), C=col(0-31) -> HL = top-scanline screen address.
;   high = $40 + (row AND $18)        (the third, ×8 in the high byte)
;   low  = ((row AND 7) << 5) OR col  (row-within-third ×32, plus column)
;   Preserves BC.
; ----------------------------------------------------------------------------
scr_addr_cr:
            ld      a, b
            and     %00011000        ; bits that select the third (= third*8)
            or      %01000000        ; + $40 screen base
            ld      h, a
            ld      a, b
            and     %00000111        ; row within third (0-7)
            rrca                     ; ×32: rotate the 3 bits up into 5-6-7
            rrca
            rrca
            or      c                ; | column
            ld      l, a
            ret

; ----------------------------------------------------------------------------
; attr_addr_cr — B=row, C=col -> HL = attribute address ($5800 + row*32 + col).
;   Preserves BC.
; ----------------------------------------------------------------------------
attr_addr_cr:
            ld      a, b
            ld      l, a
            ld      h, 0
            add     hl, hl          ; ×2
            add     hl, hl          ; ×4
            add     hl, hl          ; ×8
            add     hl, hl          ; ×16
            add     hl, hl          ; ×32  -> HL = row*32
            ld      de, $5800
            add     hl, de
            ld      a, c
            ld      e, a
            ld      d, 0
            add     hl, de          ; + col
            ret

; ----------------------------------------------------------------------------
; wall_at — B=row, C=col of the target. NZ if it's a wall, Z if walkable.
; ----------------------------------------------------------------------------
wall_at:
            call    attr_addr_cr
            bit     WALL_BIT, (hl)
            ret

; ----------------------------------------------------------------------------
; pos_bc — load BC with his current position (B=row, C=col).
; ----------------------------------------------------------------------------
pos_bc:
            ld      a, (lamp_row)
            ld      b, a
            ld      a, (lamp_col)
            ld      c, a
            ret

; ----------------------------------------------------------------------------
; save_under / restore_under / draw_lamp — now position-general (Unit 6 logic,
;   using the (col,row) address routines).
; ----------------------------------------------------------------------------
save_under:
            call    pos_bc
            call    scr_addr_cr
            ld      de, under_lamp
            ld      b, 8
.su:
            ld      a, (hl)
            ld      (de), a
            inc     de
            inc     h
            djnz    .su
            call    pos_bc
            call    attr_addr_cr
            ld      a, (hl)
            ld      (under_lamp + 8), a
            ret

restore_under:
            call    pos_bc
            call    scr_addr_cr
            ld      de, under_lamp
            ld      b, 8
.ru:
            ld      a, (de)
            ld      (hl), a
            inc     de
            inc     h
            djnz    .ru
            call    pos_bc
            call    attr_addr_cr
            ld      a, (under_lamp + 8)
            ld      (hl), a
            ret

draw_lamp:
            call    pos_bc
            call    attr_addr_cr
            ld      (hl), LAMP_ATTR
            call    pos_bc
            call    scr_addr_cr
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
lamp_row:
            defb    START_ROW
tcol:
            defb    0               ; target column being tested
trow:
            defb    0               ; target row being tested

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
