; Gloaming — Unit 18: The Square Warms
; Cumulative build; every step runs on its own. Narrative: the unit page.
; step-01 warms the walls: a colour ramp keyed to lamps lit, repainted on change.

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
LIFE_PIP    equ     %01010000
LIFE_BASE   equ     $5800 + 28

MSG_ATTR    equ     %01000111
MSG_ROW     equ     11
WIN_COL     equ     7
LOSE_COL    equ     10
TITLE_COL   equ     12
PROMPT_COL  equ     10
TITLE_ROW   equ     8
PROMPT_ROW  equ     14
FONT        equ     $3C00

SPEAKER     equ     %00010000

STATE_TITLE equ     0
STATE_PLAY  equ     1
STATE_WIN   equ     2
STATE_LOSE  equ     3

START_COL   equ     15
START_ROW   equ     11
DRAUGHT_COL0 equ    18
DRAUGHT_ROW0 equ    3

KEYS_OP     equ     $DFFE
KEYS_Q      equ     $FBFE
KEYS_A      equ     $FDFE
KEYS_SPACE  equ     $7FFE

; ============================================================================
; SETUP.
; ============================================================================
start:
            ld      a, 0
            out     ($FE), a
            ld      a, STATE_TITLE
            ld      (game_state), a
            call    draw_title_screen
            im      1
            ei

main_loop:
            halt
            ld      a, (game_state)
            cp      STATE_TITLE
            jr      z, .do_title
            cp      STATE_PLAY
            jr      z, .do_play
            jr      main_loop
.do_title:
            call    title_step
            jr      main_loop
.do_play:
            call    play_step
            jr      main_loop

title_step:
            ld      bc, KEYS_SPACE
            in      a, (c)
            bit     0, a
            ret     nz
            call    init_game
            ld      a, STATE_PLAY
            ld      (game_state), a
            ret

play_step:
            call    player_step
            ld      a, (game_state)
            cp      STATE_PLAY
            ret     nz
            call    draught_step
            ld      a, (game_state)
            cp      STATE_PLAY
            ret     nz
            ld      a, (lit_count)
            cp      NUM_LAMPS
            ret     nz
            call    draw_win_screen
            ld      a, STATE_WIN
            ld      (game_state), a
            ret

init_game:
            xor     a
            ld      (lit_count), a
            ld      a, LIVES
            ld      (lives), a
            ld      a, START_COL
            ld      (lamp_col), a
            ld      a, START_ROW
            ld      (lamp_row), a
            ld      a, DRAUGHT_COL0
            ld      (draught_col), a
            ld      a, DRAUGHT_ROW0
            ld      (draught_row), a
            ld      a, 1
            ld      (draught_dx), a
            ld      (draught_dy), a
            ld      a, DRAUGHT_SPEED
            ld      (draught_timer), a

            call    clear_bitmap

            ld      hl, $5800
            ld      de, $5801
            ld      (hl), COBBLE
            ld      bc, 767
            ldir

            call    warm_walls          ; draw the frame at the current (cold) warmth

            call    draw_pips
            call    draw_lives
            call    draw_lamps
            call    save_under
            call    draw_lamp
            call    save_draught
            call    draw_draught
            ret

; ----------------------------------------------------------------------------
; warm_walls — repaint the frame in the colour for the current lamp count.
;   wall_ramp[lit_count] -> the wall attribute. Every entry keeps PAPER bit 0
;   set, so the walls stay solid to collision.
; ----------------------------------------------------------------------------
warm_walls:
            ld      a, (lit_count)
            ld      e, a
            ld      d, 0
            ld      hl, wall_ramp
            add     hl, de
            ld      c, (hl)             ; C = wall colour for this progress

            ld      hl, $5820           ; top wall (row 1)
            ld      b, 32
.wt:
            ld      (hl), c
            inc     hl
            djnz    .wt
            ld      hl, $5AE0           ; bottom wall (row 23)
            ld      b, 32
.wb:
            ld      (hl), c
            inc     hl
            djnz    .wb
            ld      hl, $5820           ; sides, rows 1..23
            ld      b, 23
.ws:
            ld      (hl), c
            push    hl
            ld      de, 31
            add     hl, de
            ld      (hl), c
            pop     hl
            ld      de, 32
            add     hl, de
            djnz    .ws
            ret

beep:
            di
.bcyc:
            ld      a, SPEAKER
            out     ($FE), a
            ld      a, c
.bd1:
            dec     a
            jr      nz, .bd1
            xor     a
            out     ($FE), a
            ld      a, c
.bd2:
            dec     a
            jr      nz, .bd2
            djnz    .bcyc
            ei
            ret

blip_lit:
            ld      b, $20
            ld      c, $18
            jp      beep

blip_snuff:
            ld      b, $1A
            ld      c, $40
            jp      beep

; ----------------------------------------------------------------------------
; Screens.
; ----------------------------------------------------------------------------
draw_title_screen:
            call    clear_bitmap
            ld      hl, $5800
            ld      de, $5801
            ld      (hl), %00000000
            ld      bc, 767
            ldir
            ld      hl, title_text
            ld      b, TITLE_ROW
            ld      c, TITLE_COL
            call    print_string
            ld      hl, prompt_text
            ld      b, PROMPT_ROW
            ld      c, PROMPT_COL
            call    print_string
            ret

draw_win_screen:
            call    restore_under
            ld      hl, win_text
            ld      b, MSG_ROW
            ld      c, WIN_COL
            call    print_string
            ret

draw_lose_screen:
            ld      hl, $5800
            ld      de, $5801
            ld      (hl), %00000000
            ld      bc, 767
            ldir
            ld      hl, lose_text
            ld      b, MSG_ROW
            ld      c, LOSE_COL
            call    print_string
            ret

clear_bitmap:
            ld      hl, $4000
            ld      de, $4001
            ld      (hl), 0
            ld      bc, 6143
            ldir
            ret

; ----------------------------------------------------------------------------
; player_step — light a lamp: blip and warm the walls.
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
            call    blip_lit
            call    warm_walls          ; the stone catches the new light
.pdrawn:
            call    draw_lamp
            ret

; ----------------------------------------------------------------------------
; draught_step — snuff a lamp: blip and cool the walls.
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

            ld      a, (dtcol)
            ld      hl, lamp_col
            cp      (hl)
            jr      nz, .dmove
            ld      a, (dtrow)
            ld      hl, lamp_row
            cp      (hl)
            jr      nz, .dmove
            call    lose_life
            ret

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
            call    blip_snuff
            call    warm_walls          ; the stone cools as the dark returns
.nosnuff:
            call    draw_draught
            ret

lose_life:
            ld      a, (lives)
            dec     a
            ld      (lives), a
            ld      e, a
            ld      d, 0
            ld      hl, LIFE_BASE
            add     hl, de
            ld      (hl), COBBLE
            ld      a, (lives)
            or      a
            jr      z, .gone
            call    restore_under
            ld      a, START_COL
            ld      (lamp_col), a
            ld      a, START_ROW
            ld      (lamp_row), a
            call    save_under
            call    draw_lamp
            ret
.gone:
            call    draw_lose_screen
            ld      a, STATE_LOSE
            ld      (game_state), a
            ret

; ----------------------------------------------------------------------------
; print_string / print_char.
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
; Data.
; ----------------------------------------------------------------------------
game_state:
            defb    STATE_TITLE

; wall colour by lamps lit (0..8). Cold blue -> bright blue -> magenta ->
; bright magenta. Every PAPER here has bit 0 set, so walls stay solid.
wall_ramp:
            defb    %00001111       ; 0 — blue, cold
            defb    %00001111       ; 1
            defb    %01001111       ; 2 — BRIGHT blue
            defb    %01001111       ; 3
            defb    %00011111       ; 4 — magenta
            defb    %00011111       ; 5
            defb    %01011111       ; 6 — BRIGHT magenta
            defb    %01011111       ; 7
            defb    %01011111       ; 8 — fully warmed

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

title_text:
            defb    "GLOAMING"
            defb    $FF
prompt_text:
            defb    "PRESS SPACE"
            defb    $FF
win_text:
            defb    "THE NIGHT IS HELD"
            defb    $FF
lose_text:
            defb    "NIGHT FALLS"
            defb    $FF

            end     start
