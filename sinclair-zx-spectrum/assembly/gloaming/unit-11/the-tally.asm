; ============================================================================
; GLOAMING — Unit 11: The Tally
; ============================================================================
; Lamps light (Unit 10) but nothing keeps score. A game tells you how you're
; doing — so we add a TALLY: a row of pips along the top, one per lamp, cold at
; first and warming as you light them. A progress bar you read at a glance.
;
; Deliberately simple: each pip is just a COLOURED CELL — no glyph, no digits.
; Pure attribute, like the very first thing we drew in Unit 1. Cyan for a lamp
; not yet lit, bright yellow for one that is, echoing the lamps themselves.
; (Drawing actual *numbers* is a real technique — a later, bigger game builds a
; digit HUD. This coloured-pip readout is the honest, smaller "before".)
;
; Two changes:
;
;   1. The square gets a HUD strip. The top wall moves down to row 1, leaving
;      row 0 as a black band above the playfield where the pips live — out of
;      the lamplighter's reach (the row-1 wall stops him at row 2).
;
;   2. We keep a count, lit_count. Each time a lamp is freshly lit, we bump the
;      count and warm the next pip. Because lighting is idempotent (Unit 10),
;      re-crossing a lit lamp never double-counts.
; ============================================================================

            org     32768

COBBLE      equ     %00000001       ; PAPER black, INK blue — floor
WALL        equ     %00001111       ; PAPER blue, INK white — solid
LAMP_ATTR   equ     %01000111       ; BRIGHT, PAPER black, INK white — the figure
LAMP_UNLIT  equ     %00000101       ; PAPER black, INK cyan — a cold lamp
LAMP_LIT    equ     %01000110       ; BRIGHT, PAPER black, INK yellow — a lit lamp
WALL_BIT    equ     3

PIP_UNLIT   equ     %00101000       ; PAPER cyan — a cold pip
PIP_LIT     equ     %01110000       ; BRIGHT, PAPER yellow — a warm pip
PIP_BASE    equ     $5800 + 12      ; row 0, column 12 — first pip
NUM_LAMPS   equ     8

START_COL   equ     15
START_ROW   equ     11

KEYS_OP     equ     $DFFE
KEYS_Q      equ     $FBFE
KEYS_A      equ     $FDFE

; ============================================================================
; SETUP — runs once.  The frame now starts at row 1, leaving row 0 for the HUD.
; ============================================================================
start:
            ld      a, 0            ; border black
            out     ($FE), a

            ld      hl, $5800       ; wash the whole grid in cobbles
            ld      de, $5801
            ld      (hl), COBBLE
            ld      bc, 767
            ldir

            ld      hl, $5820       ; top wall — ROW 1 now (row 0 is the HUD)
            ld      b, 32
.top:
            ld      (hl), WALL
            inc     hl
            djnz    .top

            ld      hl, $5AE0       ; bottom wall — row 23
            ld      b, 32
.bottom:
            ld      (hl), WALL
            inc     hl
            djnz    .bottom

            ld      hl, $5820       ; left and right columns, rows 1..23
            ld      b, 23
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

            call    draw_pips       ; the cold tally
            call    draw_lamps
            call    save_under
            call    draw_lamp

; ============================================================================
; THE HEARTBEAT — move, light lamps, and warm a pip for each new one.
; ============================================================================
            im      1
            ei

game_loop:
            halt

            ld      a, (lamp_col)
            ld      (tcol), a
            ld      a, (lamp_row)
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
            jr      game_loop

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
            ld      a, (trow)
            ld      b, a
            ld      a, (tcol)
            ld      c, a
            call    wall_at
            jr      nz, game_loop

            call    restore_under
            ld      a, (tcol)
            ld      (lamp_col), a
            ld      a, (trow)
            ld      (lamp_row), a
            call    save_under

            ; --- light it, and warm a pip if this lamp was cold ---
            ld      a, (under_lamp + 8)
            cp      LAMP_UNLIT
            jr      nz, .not_lamp
            ld      a, LAMP_LIT
            ld      (under_lamp + 8), a   ; lamp will restore lit
            call    light_pip             ; warm the next pip on the tally
.not_lamp:
            call    draw_lamp
            jr      game_loop

; ----------------------------------------------------------------------------
; light_pip — warm the pip at index lit_count, then bump lit_count.
; ----------------------------------------------------------------------------
light_pip:
            ld      a, (lit_count)
            ld      e, a
            ld      d, 0
            inc     a
            ld      (lit_count), a
            ld      hl, PIP_BASE
            add     hl, de
            ld      (hl), PIP_LIT
            ret

; ----------------------------------------------------------------------------
; draw_pips — lay down NUM_LAMPS cold pips in a row at the start of row 0.
; ----------------------------------------------------------------------------
draw_pips:
            ld      hl, PIP_BASE
            ld      b, NUM_LAMPS
            ld      a, PIP_UNLIT
.dp:
            ld      (hl), a
            inc     hl
            djnz    .dp
            ret

; ----------------------------------------------------------------------------
; draw_lamps / draw_lantern  (Unit 9).
; ----------------------------------------------------------------------------
draw_lamps:
            ld      hl, lamp_data
.next:
            ld      a, (hl)
            cp      $FF
            ret     z
            ld      c, a
            inc     hl
            ld      b, (hl)
            inc     hl
            push    hl
            call    draw_lantern
            pop     hl
            jr      .next

draw_lantern:
            call    attr_addr_cr
            ld      (hl), LAMP_UNLIT
            call    scr_addr_cr
            ld      de, lantern
            ld      b, 8
.dlt:
            ld      a, (de)
            ld      (hl), a
            inc     de
            inc     h
            djnz    .dlt
            ret

; ----------------------------------------------------------------------------
; scr_addr_cr / attr_addr_cr / wall_at / pos_bc  (Unit 8).
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

wall_at:
            call    attr_addr_cr
            bit     WALL_BIT, (hl)
            ret

pos_bc:
            ld      a, (lamp_row)
            ld      b, a
            ld      a, (lamp_col)
            ld      c, a
            ret

; ----------------------------------------------------------------------------
; save_under / restore_under / draw_lamp  (Unit 8).
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
; Level data, state, buffer, and shapes.
; ----------------------------------------------------------------------------
lamp_data:
            defb    4, 3
            defb    27, 3
            defb    9, 7
            defb    22, 7
            defb    6, 15
            defb    25, 15
            defb    13, 20
            defb    18, 20
            defb    $FF

lamp_col:
            defb    START_COL
lamp_row:
            defb    START_ROW
tcol:
            defb    0
trow:
            defb    0
lit_count:
            defb    0

under_lamp:
            defb    0, 0, 0, 0, 0, 0, 0, 0, 0

lamplighter:
            defb    %00111100
            defb    %00111100
            defb    %00011000
            defb    %01111110
            defb    %00011000
            defb    %00011000
            defb    %00100100
            defb    %01000010

lantern:
            defb    %00011000
            defb    %00100100
            defb    %01111110
            defb    %01111110
            defb    %01011010
            defb    %01111110
            defb    %01111110
            defb    %00111100

            end     start
