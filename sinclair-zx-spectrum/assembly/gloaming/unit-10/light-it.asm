; ============================================================================
; GLOAMING — Unit 10: Light It
; ============================================================================
; The lamps are placed and cold (Unit 9). Now the lamplighter lights them — and
; the trick is so neat it's almost a cheat. We already save the nine bytes
; beneath him every time he moves (Unit 6). Lighting a lamp is just *editing
; the saved copy*: change the stored attribute from cold cyan to bright yellow,
; and when he steps off, restore paints the lamp back — lit.
;
; The whole mechanic, in the move we already have:
;
;   restore  put back the cell he's leaving (lit, if we changed it)
;   step     move to the target
;   save     copy the new cell's nine bytes into the buffer
;   >>> if the cell we just saved is an UNLIT lamp, change the saved
;       attribute to LIT. He's standing on it now, so nothing shows yet —
;       but the moment he leaves, restore writes the lit lamp back. <<<
;   draw     draw him over the top
;
; This is two ideas at once. COLLISION-AS-RULE: stepping onto a particular kind
; of cell *does something*, not just "can I go there". And PERSISTENT CELL
; STATE: the floor under the sprite isn't scenery, it's data we change and that
; stays changed. Light a lamp, walk away, and it's still glowing — because the
; change lives in the cell, not in the sprite.
; ============================================================================

            org     32768

COBBLE      equ     %00000001       ; PAPER black, INK blue — floor
WALL        equ     %00001111       ; PAPER blue, INK white — solid
LAMP_ATTR   equ     %01000111       ; BRIGHT, PAPER black, INK white — the figure
LAMP_UNLIT  equ     %00000101       ; PAPER black, INK cyan — a cold, unlit lamp
LAMP_LIT    equ     %01000110       ; BRIGHT, PAPER black, INK yellow — a lit lamp
WALL_BIT    equ     3

START_COL   equ     15
START_ROW   equ     11

KEYS_OP     equ     $DFFE
KEYS_Q      equ     $FBFE
KEYS_A      equ     $FDFE

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

            call    draw_lamps
            call    save_under
            call    draw_lamp

; ============================================================================
; THE HEARTBEAT — move, and light any unlit lamp stepped onto.
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

            ; --- light it: if the saved cell is an unlit lamp, mark it lit ---
            ld      a, (under_lamp + 8)
            cp      LAMP_UNLIT
            jr      nz, .not_lamp
            ld      a, LAMP_LIT
            ld      (under_lamp + 8), a   ; restore will paint it lit when he leaves
.not_lamp:
            call    draw_lamp
            jr      game_loop

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
