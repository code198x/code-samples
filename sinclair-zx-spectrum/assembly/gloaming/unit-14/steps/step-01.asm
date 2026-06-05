; Gloaming — Unit 14: It Snuffs the Light
; Cumulative build; every step runs on its own. Narrative: the unit page.
; step-01 lets the draught snuff a lit lamp — Unit 10's lighting, mirrored.

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

MSG_ATTR    equ     %01000111
MSG_ROW     equ     11
MSG_COL     equ     7
FONT        equ     $3C00

START_COL   equ     15
START_ROW   equ     11
DRAUGHT_COL0 equ    18              ; its diagonal now crosses the lamp at (22,7)
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
; player_step — move the lamplighter, light lamps  (Unit 13).
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
            ret     nz

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
; draught_step — drift, bounce, and SNUFF any lit lamp stepped onto.
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
            call    restore_draught
            ld      a, (draught_col)
            ld      b, a
            ld      a, (draught_dx)
            add     a, b
            ld      (draught_col), a
            ld      a, (draught_row)
            ld      b, a
            ld      a, (draught_dy)
            add     a, b
            ld      (draught_row), a
            call    save_draught

            ; --- snuff it: if the saved cell is a lit lamp, cool it ---
            ld      a, (under_draught + 8)
            cp      LAMP_LIT
            jr      nz, .nosnuff
            ld      a, LAMP_UNLIT
            ld      (under_draught + 8), a   ; restored cold when the draught leaves
            call    unlight_pip
.nosnuff:
            call    draw_draught
            ret

; ----------------------------------------------------------------------------
; unlight_pip — drop the tally by one and cool the top pip (mirror of light_pip).
; ----------------------------------------------------------------------------
unlight_pip:
            ld      a, (lit_count)
            dec     a
            ld      (lit_count), a   ; new, lower count
            ld      e, a             ; index of the pip that was on top
            ld      d, 0
            ld      hl, PIP_BASE
            add     hl, de
            ld      (hl), PIP_UNLIT
            ret

; ----------------------------------------------------------------------------
; win / draw_message / print_char  (Unit 12).
; ----------------------------------------------------------------------------
win:
            call    restore_under
            call    draw_message
.hold:
            halt
            jr      .hold

draw_message:
            ld      hl, msg_text
            ld      c, MSG_COL
.dm:
            ld      a, (hl)
            cp      $FF
            ret     z
            push    hl
            ld      b, MSG_ROW
            call    print_char
            pop     hl
            inc     hl
            inc     c
            jr      .dm

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
; light_pip / draw_pips  (Unit 11).
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
; scr_addr_cr / attr_addr_cr / wall_at  (Unit 8).
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
; The lamplighter's save / restore / draw  (Unit 8).
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
; The draught's save / restore / draw  (Unit 13).
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

msg_text:
            defb    "THE NIGHT IS HELD"
            defb    $FF

            end     start
