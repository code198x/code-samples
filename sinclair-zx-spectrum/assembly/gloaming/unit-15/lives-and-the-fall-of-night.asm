; ============================================================================
; GLOAMING — Unit 15: Lives, and the Fall of Night
; ============================================================================
; The draught can undo your work, but it can't touch *you*. This unit closes
; Phase D: the draught and the lamplighter can collide, each collision costs a
; life, and when the lives run out, night falls — the lose state. Now Gloaming
; is a game you can lose as well as win.
;
; Three new pieces:
;
;   1. ENTITY-VS-ENTITY collision. We check whether the lamplighter and the
;      draught are trying to share a cell. Rather than let two sprites overlap
;      (which would tangle their save/restore buffers — each assumes it's the
;      only thing on its cell), we treat "same cell" as a blocked move: the move
;      is refused and a life is lost. They never actually overlap.
;
;   2. LIVES, shown as pips. Three red pips in the HUD; each hit removes one —
;      the mirror, again, of the lamp tally.
;
;   3. THE LOSE STATE. Out of lives, the screen washes to black — night taking
;      the square — and a closing line holds, just as the win does.
; ============================================================================

            org     32768

COBBLE      equ     %00000001
WALL        equ     %00001111
LAMP_ATTR   equ     %01000111
LAMP_UNLIT  equ     %00000101
LAMP_LIT    equ     %01000110
WALL_BIT    equ     3

DRAUGHT_ATTR  equ   %01000101
DRAUGHT_SPEED equ   8

PIP_UNLIT   equ     %00101000
PIP_LIT     equ     %01110000
PIP_BASE    equ     $5800 + 12
NUM_LAMPS   equ     8

LIVES       equ     3
LIFE_PIP    equ     %01010000       ; BRIGHT, PAPER red — a life
LIFE_BASE   equ     $5800 + 28      ; row 0, columns 28-30

MSG_ATTR    equ     %01000111
MSG_ROW     equ     11
WIN_COL     equ     7
LOSE_COL    equ     10
FONT        equ     $3C00

START_COL   equ     15
START_ROW   equ     11
DRAUGHT_COL0 equ    18
DRAUGHT_ROW0 equ    3

KEYS_OP     equ     $DFFE
KEYS_Q      equ     $FBFE
KEYS_A      equ     $FDFE

; ============================================================================
; SETUP — runs once.
; ============================================================================
start:
            ld      a, 0
            out     ($FE), a

            ld      hl, $5800
            ld      de, $5801
            ld      (hl), COBBLE
            ld      bc, 767
            ldir

            ld      hl, $5820
            ld      b, 32
.top:
            ld      (hl), WALL
            inc     hl
            djnz    .top

            ld      hl, $5AE0
            ld      b, 32
.bottom:
            ld      (hl), WALL
            inc     hl
            djnz    .bottom

            ld      hl, $5820
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

            call    draw_pips
            call    draw_lives
            call    draw_lamps
            call    save_under
            call    draw_lamp
            call    save_draught
            call    draw_draught

; ============================================================================
; THE HEARTBEAT.
; ============================================================================
            im      1
            ei

game_loop:
            halt
            call    player_step
            call    draught_step
            ld      a, (lit_count)
            cp      NUM_LAMPS
            jp      z, win
            jr      game_loop

; ----------------------------------------------------------------------------
; player_step — move the lamplighter; a step onto the draught costs a life.
; ----------------------------------------------------------------------------
player_step:
            ld      a, (lamp_col)
            ld      (tcol), a
            ld      a, (lamp_row)
            ld      (trow), a

            ld      bc, KEYS_OP
            in      a, (c)
            bit     1, a
            jr      z, .pleft
            bit     0, a
            jr      z, .pright
            ld      bc, KEYS_Q
            in      a, (c)
            bit     0, a
            jr      z, .pup
            ld      bc, KEYS_A
            in      a, (c)
            bit     0, a
            jr      z, .pdown
            ret

.pleft:
            ld      hl, tcol
            dec     (hl)
            jr      .pmove
.pright:
            ld      hl, tcol
            inc     (hl)
            jr      .pmove
.pup:
            ld      hl, trow
            dec     (hl)
            jr      .pmove
.pdown:
            ld      hl, trow
            inc     (hl)
.pmove:
            ld      a, (trow)
            ld      b, a
            ld      a, (tcol)
            ld      c, a
            call    wall_at
            ret     nz              ; wall blocks

            ; would the step land on the draught? then it's a collision
            ld      a, (tcol)
            ld      hl, draught_col
            cp      (hl)
            jr      nz, .pcommit
            ld      a, (trow)
            ld      hl, draught_row
            cp      (hl)
            jr      nz, .pcommit
            call    lose_life
            ret

.pcommit:
            call    restore_under
            ld      a, (tcol)
            ld      (lamp_col), a
            ld      a, (trow)
            ld      (lamp_row), a
            call    save_under
            ld      a, (under_lamp + 8)
            cp      LAMP_UNLIT
            jr      nz, .pdrawn
            ld      a, LAMP_LIT
            ld      (under_lamp + 8), a
            call    light_pip
.pdrawn:
            call    draw_lamp
            ret

; ----------------------------------------------------------------------------
; draught_step — drift, bounce, snuff; a step onto the lamplighter costs a life.
; ----------------------------------------------------------------------------
draught_step:
            ld      a, (draught_timer)
            dec     a
            ld      (draught_timer), a
            ret     nz
            ld      a, DRAUGHT_SPEED
            ld      (draught_timer), a

            ld      a, (draught_col)
            ld      b, a
            ld      a, (draught_dx)
            add     a, b
            ld      c, a
            ld      a, (draught_row)
            ld      b, a
            call    wall_at
            jr      z, .hok
            ld      a, (draught_dx)
            neg
            ld      (draught_dx), a
.hok:
            ld      a, (draught_row)
            ld      b, a
            ld      a, (draught_dy)
            add     a, b
            ld      b, a
            ld      a, (draught_col)
            ld      c, a
            call    wall_at
            jr      z, .vok
            ld      a, (draught_dy)
            neg
            ld      (draught_dy), a
.vok:
            ; work out the target cell
            ld      a, (draught_col)
            ld      b, a
            ld      a, (draught_dx)
            add     a, b
            ld      (dtcol), a
            ld      a, (draught_row)
            ld      b, a
            ld      a, (draught_dy)
            add     a, b
            ld      (dtrow), a

            ; would it land on the lamplighter? then it's a collision
            ld      a, (dtcol)
            ld      hl, lamp_col
            cp      (hl)
            jr      nz, .dmove
            ld      a, (dtrow)
            ld      hl, lamp_row
            cp      (hl)
            jr      nz, .dmove
            call    lose_life
            ret                     ; don't move onto him

.dmove:
            call    restore_draught
            ld      a, (dtcol)
            ld      (draught_col), a
            ld      a, (dtrow)
            ld      (draught_row), a
            call    save_draught
            ld      a, (under_draught + 8)
            cp      LAMP_LIT
            jr      nz, .nosnuff
            ld      a, LAMP_UNLIT
            ld      (under_draught + 8), a
            call    unlight_pip
.nosnuff:
            call    draw_draught
            ret

; ----------------------------------------------------------------------------
; lose_life — drop a life pip; reset the lamplighter, or fall to night.
; ----------------------------------------------------------------------------
lose_life:
            ld      a, (lives)
            dec     a
            ld      (lives), a
            ld      e, a            ; index of the life pip to remove
            ld      d, 0
            ld      hl, LIFE_BASE
            add     hl, de
            ld      (hl), COBBLE    ; the pip goes dark
            ld      a, (lives)
            or      a
            jp      z, lose         ; out of lives — night falls

            ; otherwise send the lamplighter back to the start, clear of danger
            call    restore_under
            ld      a, START_COL
            ld      (lamp_col), a
            ld      a, START_ROW
            ld      (lamp_row), a
            call    save_under
            call    draw_lamp
            ret

; ----------------------------------------------------------------------------
; win / lose — each prints a line and holds.
; ----------------------------------------------------------------------------
win:
            call    restore_under
            ld      hl, win_text
            ld      b, MSG_ROW
            ld      c, WIN_COL
            call    print_string
.whold:
            halt
            jr      .whold

lose:
            ld      hl, $5800       ; night falls — wash the square to black
            ld      de, $5801
            ld      (hl), %00000000
            ld      bc, 767
            ldir
            ld      hl, lose_text
            ld      b, MSG_ROW
            ld      c, LOSE_COL
            call    print_string
.lhold:
            halt
            jr      .lhold

; ----------------------------------------------------------------------------
; print_string — HL=string ($FF-terminated), B=row, C=col.
; ----------------------------------------------------------------------------
print_string:
.ps:
            ld      a, (hl)
            cp      $FF
            ret     z
            push    hl
            push    bc
            call    print_char
            pop     bc
            pop     hl
            inc     hl
            inc     c
            jr      .ps

print_char:
            ld      l, a
            ld      h, 0
            add     hl, hl
            add     hl, hl
            add     hl, hl
            ld      de, FONT
            add     hl, de
            ex      de, hl
            push    de
            call    attr_addr_cr
            ld      (hl), MSG_ATTR
            call    scr_addr_cr
            pop     de
            ld      b, 8
.pc:
            ld      a, (de)
            ld      (hl), a
            inc     de
            inc     h
            djnz    .pc
            ret

; ----------------------------------------------------------------------------
; light_pip / unlight_pip / draw_pips / draw_lives.
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

unlight_pip:
            ld      a, (lit_count)
            dec     a
            ld      (lit_count), a
            ld      e, a
            ld      d, 0
            ld      hl, PIP_BASE
            add     hl, de
            ld      (hl), PIP_UNLIT
            ret

draw_pips:
            ld      hl, PIP_BASE
            ld      b, NUM_LAMPS
            ld      a, PIP_UNLIT
.dp:
            ld      (hl), a
            inc     hl
            djnz    .dp
            ret

draw_lives:
            ld      hl, LIFE_BASE
            ld      b, LIVES
            ld      a, LIFE_PIP
.dlv:
            ld      (hl), a
            inc     hl
            djnz    .dlv
            ret

; ----------------------------------------------------------------------------
; draw_lamps / draw_lantern.
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
; scr_addr_cr / attr_addr_cr / wall_at.
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

; ----------------------------------------------------------------------------
; The lamplighter's save / restore / draw.
; ----------------------------------------------------------------------------
pos_bc:
            ld      a, (lamp_row)
            ld      b, a
            ld      a, (lamp_col)
            ld      c, a
            ret

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
; The draught's save / restore / draw.
; ----------------------------------------------------------------------------
dpos_bc:
            ld      a, (draught_row)
            ld      b, a
            ld      a, (draught_col)
            ld      c, a
            ret

save_draught:
            call    dpos_bc
            call    scr_addr_cr
            ld      de, under_draught
            ld      b, 8
.sd:
            ld      a, (hl)
            ld      (de), a
            inc     de
            inc     h
            djnz    .sd
            call    dpos_bc
            call    attr_addr_cr
            ld      a, (hl)
            ld      (under_draught + 8), a
            ret

restore_draught:
            call    dpos_bc
            call    scr_addr_cr
            ld      de, under_draught
            ld      b, 8
.rd:
            ld      a, (de)
            ld      (hl), a
            inc     de
            inc     h
            djnz    .rd
            call    dpos_bc
            call    attr_addr_cr
            ld      a, (under_draught + 8)
            ld      (hl), a
            ret

draw_draught:
            call    dpos_bc
            call    attr_addr_cr
            ld      (hl), DRAUGHT_ATTR
            call    dpos_bc
            call    scr_addr_cr
            ld      de, draught_glyph
            ld      b, 8
.dd:
            ld      a, (de)
            ld      (hl), a
            inc     de
            inc     h
            djnz    .dd
            ret

; ----------------------------------------------------------------------------
; Level data, state, buffers, and shapes.
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
lives:
            defb    LIVES

draught_col:
            defb    DRAUGHT_COL0
draught_row:
            defb    DRAUGHT_ROW0
draught_dx:
            defb    1
draught_dy:
            defb    1
draught_timer:
            defb    DRAUGHT_SPEED
dtcol:
            defb    0
dtrow:
            defb    0

under_lamp:
            defb    0, 0, 0, 0, 0, 0, 0, 0, 0
under_draught:
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

draught_glyph:
            defb    %00000000
            defb    %00111100
            defb    %01111110
            defb    %11111111
            defb    %11111111
            defb    %01111110
            defb    %00111100
            defb    %00000000

win_text:
            defb    "THE NIGHT IS HELD"
            defb    $FF
lose_text:
            defb    "NIGHT FALLS"
            defb    $FF

            end     start
