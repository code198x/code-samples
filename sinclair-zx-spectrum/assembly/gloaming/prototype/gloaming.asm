; Gloaming — Unit 21: Three Phrases
; Cumulative build; every step runs on its own. Narrative: the unit page.
; step-01 gives the three big moments a voice: a dusk chime on the title,
; a rising fanfare on the win, a falling sting on the loss — each just a
; few beep calls in a row, with rests between.

            org     32768

COBBLE      equ     %00000001
WALL        equ     %00001111
LAMP_ATTR   equ     %01000111
LAMP_UNLIT  equ     %00000101
LAMP_LIT    equ     %01000110
WALL_BIT    equ     3

DRAUGHT_ATTR  equ   %01000101
NUM_DUSKS     equ   8               ; dusk_table entries; deeper dusks hold the last
PLAYER_REPEAT equ   6               ; frames between steps while a key is held

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
CONT_ROW    equ     16              ; "PRESS SPACE" under a win/lose line
FONT        equ     $3C00

SPEAKER     equ     %00010000

STATE_TITLE equ     0
STATE_PLAY  equ     1
STATE_WIN   equ     2
STATE_LOSE  equ     3
LOCK        equ     25              ; input-lock frames after entering a screen

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
            call    draw_title_screen   ; no startup lock — nothing to debounce yet
            im      1
            ei
            call    chime_dusk          ; after EI — the rests need the interrupt

main_loop:
            halt
            ld      a, (game_state)
            cp      STATE_TITLE
            jr      z, .do_title
            cp      STATE_PLAY
            jr      z, .do_play
            call    end_step            ; WIN or LOSE — wait for a key, then title
            jr      main_loop
.do_title:
            call    title_step
            jr      main_loop
.do_play:
            call    play_step
            jr      main_loop

; ----------------------------------------------------------------------------
; title_step — after the lock, SPACE starts a fresh game.
; ----------------------------------------------------------------------------
title_step:
            ld      a, (input_lock)
            or      a
            jr      z, .tready
            dec     a
            ld      (input_lock), a
            ret
.tready:
            ld      bc, KEYS_SPACE
            in      a, (c)
            bit     0, a
            ret     nz
            call    init_run
            ld      a, STATE_PLAY
            ld      (game_state), a
            ret

; ----------------------------------------------------------------------------
; end_step — after the lock, SPACE moves on. A held dusk continues the
; run — the night deepens; only NIGHT FALLS returns to the title.
; ----------------------------------------------------------------------------
end_step:
            ld      a, (input_lock)
            or      a
            jr      z, .eready
            dec     a
            ld      (input_lock), a
            ret
.eready:
            ld      bc, KEYS_SPACE
            in      a, (c)
            bit     0, a
            ret     nz
            ld      a, (game_state)
            cp      STATE_WIN
            jr      z, .deeper
            call    draw_title_screen
            call    chime_dusk
            ld      a, LOCK
            ld      (input_lock), a
            ld      a, STATE_TITLE
            ld      (game_state), a
            ret
.deeper:
            ld      hl, dusk
            inc     (hl)
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
            call    fanfare_held
            ld      a, LOCK
            ld      (input_lock), a
            ld      a, STATE_WIN
            ld      (game_state), a
            ret

; A run is a night: dusk 0, full lives. Each held dusk re-enters
; init_game with dusk bumped — the square relights, the lives carry.
init_run:
            xor     a
            ld      (dusk), a
            ld      a, LIVES
            ld      (lives), a
            ; fall through into the per-dusk setup

init_game:
            xor     a
            ld      (lit_count), a
            ld      a, START_COL
            ld      (lamp_col), a
            ld      a, START_ROW
            ld      (lamp_row), a
            ld      a, DRAUGHT_COL0
            ld      (draught_col), a
            ld      a, DRAUGHT_ROW0
            ld      (draught_row), a
            ; the night deepens: the wisp's pace comes from the dusk
            ; table, deeper dusks holding the last entry
            ld      a, (dusk)
            cp      NUM_DUSKS
            jr      c, .dpace
            ld      a, NUM_DUSKS - 1
.dpace:
            ld      e, a
            ld      d, 0
            ld      hl, dusk_table
            add     hl, de
            ld      a, (hl)
            ld      (dusk_speed), a
            ld      (draught_timer), a
            xor     a
            ld      (player_timer), a

            call    clear_bitmap
            ld      hl, $5800
            ld      de, $5801
            ld      (hl), COBBLE
            ld      bc, 767
            ldir
            call    warm_walls
            call    draw_pips
            call    draw_lives
            call    draw_lamps
            call    save_under
            call    draw_lamp
            call    save_draught
            call    draw_draught
            ret

warm_walls:
            ld      a, (lit_count)
            ld      e, a
            ld      d, 0
            ld      hl, wall_ramp
            add     hl, de
            ld      c, (hl)
            ld      hl, $5820
            ld      b, 32
.wt:
            ld      (hl), c
            inc     hl
            djnz    .wt
            ld      hl, $5AE0
            ld      b, 32
.wb:
            ld      (hl), c
            inc     hl
            djnz    .wb
            ld      hl, $5820
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
; Three phrases — beeps in a row, with rests. No tables, no driver: each
; phrase is straight-line code, and the shape carries the meaning. A rest
; is B frames of silence (HALT needs interrupts on, so phrases play after
; EI — which is why the title chime moved below `ei` in setup).
; ----------------------------------------------------------------------------
rest:
            halt
            djnz    rest
            ret

chime_dusk:                         ; the title — two bell notes, high then low
            ld      b, $C6          ; E5, a bright strike
            ld      c, $A4
            call    beep
            ld      b, 8
            call    rest
            ld      b, $D1          ; C5 answers, a shade longer
            ld      c, $CF
            jp      beep

fanfare_held:                       ; THE NIGHT IS HELD — a rising run
            ld      b, $83          ; C5
            ld      c, $CF
            call    beep
            ld      b, 3
            call    rest
            ld      b, $A5          ; E5
            ld      c, $A4
            call    beep
            ld      b, 3
            call    rest
            ld      b, $C4          ; G5
            ld      c, $8A
            call    beep
            ld      b, 3
            call    rest
            ld      b, $FF          ; C6, held — B only counts to 255,
            ld      c, $67
            call    beep
            ld      b, $FF          ; so hold it by sounding it twice
            ld      c, $67
            jp      beep

sting_nightfall:                    ; NIGHT FALLS — two steps down, then dark
            ld      b, $53          ; E5
            ld      c, $A4
            call    beep
            ld      b, 4
            call    rest
            ld      b, $49          ; D5
            ld      c, $B8
            call    beep
            ld      b, 4
            call    rest
            ld      b, $DC          ; A4, long — the night settles on it
            ld      c, $F7
            jp      beep

; ----------------------------------------------------------------------------
; Screens. Win and lose now invite another go.
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
            ld      hl, prompt_text
            ld      b, CONT_ROW
            ld      c, PROMPT_COL
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
            ld      hl, prompt_text
            ld      b, CONT_ROW
            ld      c, PROMPT_COL
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
; player_step.
; ----------------------------------------------------------------------------
player_step:
            ld      a, (lamp_col)
            ld      (tcol), a
            ld      a, (lamp_row)
            ld      (trow), a

            ; The held-key gate: the first press steps at once, then one
            ; step every PLAYER_REPEAT frames. Releasing every direction
            ; key re-arms the instant first step, so taps stay crisp.
            ld      bc, KEYS_OP
            in      a, (c)
            cpl
            and     %00000011
            ld      e, a
            ld      bc, KEYS_Q
            in      a, (c)
            cpl
            and     %00000001
            or      e
            ld      e, a
            ld      bc, KEYS_A
            in      a, (c)
            cpl
            and     %00000001
            or      e
            jr      nz, .held
            xor     a
            ld      (player_timer), a
            ret
.held:
            ld      a, (player_timer)
            or      a
            jr      z, .stepnow
            dec     a
            ld      (player_timer), a
            ret
.stepnow:
            ld      a, PLAYER_REPEAT
            ld      (player_timer), a

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
            call    warm_walls
.pdrawn:
            call    draw_lamp
            ret

; ----------------------------------------------------------------------------
; manhattan — distance from the draught to cell (C = col, B = row) -> A.
; ----------------------------------------------------------------------------
manhattan:
            ld      a, (draught_col)
            sub     c
            jp      p, .dc
            neg
.dc:
            ld      d, a
            ld      a, (draught_row)
            sub     b
            jp      p, .dr
            neg
.dr:
            add     a, d
            ret

; ----------------------------------------------------------------------------
; draught_step — the wisp is the dark, and the dark seeks the light.
; Every DRAUGHT_SPEED frames it steps one cell toward the nearest light
; source: a lit lamp, or the lamplighter's own flame. Walls don't stop
; the night — it drifts straight through the stone. One rule, read as
; intent: the lesson of Namco's ghost AI in Pac-Man.
; ----------------------------------------------------------------------------
draught_step:
            ld      a, (draught_timer)
            dec     a
            ld      (draught_timer), a
            ret     nz
            ld      a, (dusk_speed)
            ld      (draught_timer), a

            ; the lamplighter's flame is the first candidate...
            ld      a, (lamp_col)
            ld      c, a
            ld      (seek_col), a
            ld      a, (lamp_row)
            ld      b, a
            ld      (seek_row), a
            call    manhattan
            ld      (seek_best), a

            ; ...then every lit lamp, keeping the nearest
            ld      hl, lamp_data
.scan:
            ld      a, (hl)
            cp      $FF
            jr      z, .chase
            ld      c, a
            inc     hl
            ld      b, (hl)
            inc     hl
            push    hl
            push    bc
            call    attr_addr_cr
            ld      a, (hl)
            pop     bc
            cp      LAMP_LIT
            jr      nz, .dnext      ; unlit lamps cast no light
            call    manhattan
            ld      hl, seek_best
            cp      (hl)
            jr      nc, .dnext      ; not nearer — keep the current prey
            ld      (hl), a
            ld      a, c
            ld      (seek_col), a
            ld      a, b
            ld      (seek_row), a
.dnext:
            pop     hl
            jr      .scan

.chase:
            ; step one cell along the axis with the greater distance
            ; (ties go sideways) — the night is 4-connected, like the
            ; lamplighter
            ld      a, (draught_col)
            ld      (dtcol), a
            ld      a, (draught_row)
            ld      (dtrow), a

            ld      a, (seek_col)
            ld      hl, draught_col
            sub     (hl)
            jp      p, .absc
            neg
.absc:
            ld      d, a            ; D = |dc|
            ld      a, (seek_row)
            ld      hl, draught_row
            sub     (hl)
            jp      p, .absr
            neg
.absr:
            cp      d               ; |dr| vs |dc|
            jr      z, .tie
            jr      c, .horiz
            jr      .vert
.tie:
            ld      a, d
            or      a
            ret     z               ; already on the light
            jr      .horiz
.horiz:
            ld      a, (seek_col)
            ld      hl, draught_col
            cp      (hl)
            jr      c, .hleft
            ld      a, (hl)
            inc     a
            ld      (dtcol), a
            jr      .contact
.hleft:
            ld      a, (hl)
            dec     a
            ld      (dtcol), a
            jr      .contact
.vert:
            ld      a, (seek_row)
            ld      hl, draught_row
            cp      (hl)
            jr      c, .vup
            ld      a, (hl)
            inc     a
            ld      (dtrow), a
            jr      .contact
.vup:
            ld      a, (hl)
            dec     a
            ld      (dtrow), a
.contact:
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
            call    warm_walls
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
            ; the taking costs the night its reach — the wisp recoils to
            ; the far corner, so every life buys a whole fresh chase
            ; (leaving it beside the respawn made a catch strip every
            ; life in seconds once the draught learnt to hunt)
            call    restore_draught
            ld      a, DRAUGHT_COL0
            ld      (draught_col), a
            ld      a, DRAUGHT_ROW0
            ld      (draught_row), a
            ld      a, (dusk_speed)
            ld      (draught_timer), a
            call    save_draught
            call    draw_draught
            ret
.gone:
            call    draw_lose_screen
            call    sting_nightfall
            ld      a, LOCK
            ld      (input_lock), a
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
input_lock:
            defb    0

dusk_table:
            ; the wisp's pace per dusk (frames between steps) — the
            ; night deepens as data, not code. Dusk 1 is gentle on
            ; purpose: the hunt must be readable before it's a threat.
            defb    16, 13, 11, 9, 8, 7, 6, 5

wall_ramp:
            ; The square warms in the brief's vocabulary (§6): the stone
            ; stays dusk-blue; the lamplight catches the mortar first
            ; (ink white -> yellow), then the whole face glows BRIGHT.
            ; Never magenta — warmth is yellow here, not red-shifted blue.
            defb    %00001111       ; dusk stone, white mortar
            defb    %00001111
            defb    %00001111
            defb    %00001110       ; the mortar warms — yellow ink
            defb    %00001110
            defb    %00001110
            defb    %01001110       ; the stone catches the glow — BRIGHT
            defb    %01001110
            defb    %01110000       ; all eight lit: the square aglow —
                                    ; warm yellow stone, only at the win

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
draught_timer:
            defb    16
player_timer:
            defb    0
dusk:
            defb    0
dusk_speed:
            defb    16
seek_col:
            defb    0
seek_row:
            defb    0
seek_best:
            defb    0
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
