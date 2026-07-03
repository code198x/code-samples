; The Long Night — Unit 7: Dawn Breaks
; Cumulative build; every step runs on its own. Narrative: the unit page.
; A run needs an ending you can reach: hold the fifth watch and morning comes.

            org     32768

COBBLE      equ     %00000001       ; PAPER black (0), INK blue (1) — dark ground
GLOW        equ     %00000110       ; pool-warmed cobble: yellow INK on black —
                                    ; ground the light holds
DARK        equ     %01000001       ; the night made solid: blue INK on black,
                                    ; BRIGHT — impassable, unmistakably there
WALL        equ     %00001111       ; PAPER blue (1), INK white (7) — pale stone
WALL_BIT    equ     3               ; the attribute bit that says "this is wall"
LAMP_ATTR   equ     %01000111       ; BRIGHT, PAPER black, INK white — his own light
LAMP_UNLIT  equ     %00000101       ; cold cyan INK on black PAPER — bit 3
                                    ; clear, so a lamp reads as floor
LAMP_LIT    equ     %01000110       ; BRIGHT yellow INK on black — a held flame

DRAUGHT_ATTR  equ   %01000101       ; the wisp: BRIGHT cyan on black — cold light

LIVES       equ     3
LIFE_PIP    equ     %01010000       ; a life: BRIGHT red PAPER — a small ember
LIFE_BASE   equ     $5800 + 28      ; row 0, right of the ledge — three cells
NUM_DUSKS     equ   5               ; five watches of night — the tables
                                    ; below give each watch its teeth

PIP_UNLIT   equ     %00101000       ; a cold pip: cyan PAPER, a solid block
PIP_LIT     equ     %01110000       ; a warm pip: BRIGHT yellow PAPER
PIP_BASE    equ     $5800 + 12      ; row 0, column 12 — the HUD ledge,
                                    ; eight cells, centred over the square
NUM_LAMPS   equ     8

MSG_ATTR    equ     %01000111       ; message text: bright white on black
MSG_ROW     equ     11
LOSE_COL    equ     10              ; centres the eleven characters
WIN_COL     equ     7               ; centres the seventeen characters
FONT        equ     $3C00           ; the ROM font, addressed so that
                                    ; ASCII x 8 lands on the right glyph

STATE_TITLE equ     0
STATE_PLAY  equ     1
STATE_WIN   equ     2               ; a dusk held — the night deepens
STATE_LOSE  equ     3               ; night falls — the game is lost
STATE_DAWN  equ     4               ; the fifth dusk held — morning,
                                    ; the TRUE win
DAWN_COL    equ     10              ; centres the eleven characters

LOCK        equ     25              ; input-lock frames after entering a screen

SPEAKER     equ     %00010000       ; port $FE bit 4 — the beeper's one bit

TITLE_COL   equ     12              ; GLOAMING, centred
PROMPT_COL  equ     10              ; PRESS SPACE, centred
TITLE_ROW   equ     8
PROMPT_ROW  equ     14
CONT_ROW    equ     16              ; "PRESS SPACE" under a win/lose line

START_COL   equ     15              ; where the lamplighter begins
START_ROW   equ     11
PLAYER_REPEAT equ   6               ; frames between steps while a key is held
GATHER      equ     120             ; frames the dark gathers before its first step
WREST       equ     48              ; frames it rests at home after a withdrawal —
                                    ; the snuff window holds even when home is close

KEYS_OP     equ     $DFFE           ; half-row P O I U Y — bits 1 and 0
KEYS_Q      equ     $FBFE           ; half-row Q W E R T — bit 0 is Q
KEYS_A      equ     $FDFE           ; half-row A S D F G — bit 0 is A
KEYS_SPACE  equ     $7FFE           ; half-row SPACE SYM M N B — bit 0

start:
            ; --- the border goes black — the night beyond the square ---
            ; Port $FE bits 0-2 set the BORDER colour. A = 0 = black.
            ld      a, 0
            out     ($FE), a
            ld      a, STATE_TITLE
            ld      (game_state), a
            call    draw_title_screen
            im      1
            ei
            call    chime_dusk          ; after EI — the rests need the interrupt

main_loop:
            halt
            ; the dispatch: each state names what a frame means — the
            ; title listens for a beginning, PLAY beats the game forward,
            ; WIN and LOSE hold the screen exactly as it stands
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
; title_step — SPACE starts a fresh game.
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
; end_step — after the lock, SPACE moves on. A held dusk continues
; the run — the night deepens; only NIGHT FALLS returns to the title.
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
            ; the dusk was held — the night is NOT over. Deepen and
            ; go again: the square relights, and the lives carry.
            ld      hl, dusk
            inc     (hl)
            call    init_game
            ld      a, STATE_PLAY
            ld      (game_state), a
            ret

; play_step — one beat of the game: ask the keyboard.
play_step:
            call    player_step
            ; contact can end the game mid-frame — if it did, stop here
            ld      a, (game_state)
            cp      STATE_PLAY
            ret     nz
            call    draught_step
            ld      a, (game_state)
            cp      STATE_PLAY
            ret     nz
            ; the win check, at the only beat the count can have changed
            ld      a, (lit_count)
            cp      NUM_LAMPS
            ret     nz
            ; the eighth lamp: is this the last watch of the night?
            ld      a, (dusk)
            cp      NUM_DUSKS - 1
            jr      z, .thedawn
            ; the night is held — the lives you kept are the score
            ld      a, (lives)
            ld      hl, best_lives
            cp      (hl)
            jr      c, .nobest
            ld      (hl), a
.nobest:
            call    draw_win_screen
            call    fanfare_held
            ld      a, LOCK
            ld      (input_lock), a
            ld      a, STATE_WIN
            ld      (game_state), a
            ret
.thedawn:
            call    draw_dawn_screen
            call    dawn_sweep
            call    fanfare_held
            ld      a, LOCK
            ld      (input_lock), a
            ld      a, STATE_DAWN
            ld      (game_state), a
            ret

; ----------------------------------------------------------------------------
; init_run / init_game — a run is a NIGHT now: dusk 0, full lives.
; Each held dusk re-enters init_game with dusk bumped — the square
; relights, the lives carry. What resets per RUN and what resets per
; WATCH is the whole design decision, drawn as two entry points.
; ----------------------------------------------------------------------------
init_run:
            xor     a
            ld      (dusk), a
            ld      a, LIVES
            ld      (lives), a
            ; fall through into the per-dusk setup

init_game:
            xor     a
            ld      (lit_count), a

            ; --- place the lamplighter ---
            ; His position is data. Everything that draws him reads it.
            ld      a, START_COL
            ld      (lamp_col), a
            ld      a, START_ROW
            ld      (lamp_row), a
            ; the dark probes from a new quarter each watch —
            ; a lesson the square teaches by ITSELF: watch 2 already
            ; feels different before anything else has changed
            ld      a, (dusk)
            and     3
            add     a, a
            ld      e, a
            ld      d, 0
            ld      hl, corner_tab
            add     hl, de
            ld      a, (hl)
            ld      (draught_col), a
            ld      (draught_home_col), a
            inc     hl
            ld      a, (hl)
            ld      (draught_row), a
            ld      (draught_home_row), a
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
            ; ...but it gathers before the first step — a beat to read
            ; the square before the hunt begins
            ld      a, GATHER
            ld      (draught_timer), a
            ; the tendril reaches further as the night deepens
            ld      hl, dusk_lentab
            add     hl, de
            ld      a, (hl)
            ld      (tendril_max), a
            xor     a
            ld      (player_timer), a
            ld      (tendril_len), a
            ld      (tendril_head), a
            ld      (draught_mode), a
            ld      (lit_qcount), a

            ; --- wipe the canvas ---
            ; The bitmap ($4000-$57FF) is the pixel layer; whatever was on
            ; screen before us still lives there. Zero it so only our
            ; attribute colours show.
            call    clear_bitmap

            ; --- texture the ground ---
            ; Blit the cobble stipple into every cell's bitmap, rows 1-23.
            ; The attributes will colour these pixels in a moment.
            call    fill_ground

            ; --- wash in the cobbles ---
            ; Seed the first attribute cell, point DE one cell ahead, and
            ; let LDIR cascade the byte through all 768 cells.
            ld      hl, $5800
            ld      de, $5801
            ld      (hl), COBBLE
            ld      bc, 767
            ldir

            call    warm_walls
            call    paint_buildings

            ; --- brick the walls ---
            ; Now that the wall cells are painted, fill_walls can read the
            ; map back and lay brick wherever the wall bit is set.
            call    fill_walls
            call    draw_pips
            call    draw_lives
            call    draw_lamps
            ; save what he is about to stand on, BEFORE the first draw
            call    save_under
            call    draw_lamp
            call    save_draught
            call    draw_draught
            ret

; ----------------------------------------------------------------------------
; warm_walls — the square's edge, one attribute write per cell; the
; colour is no longer a constant but the wall_ramp entry for how many
; lamps are lit. Same painting loop as ever — only where C comes from
; has changed.
; ----------------------------------------------------------------------------
warm_walls:
            ld      a, (lit_count)
            ld      e, a
            ld      d, 0
            ld      hl, wall_ramp
            add     hl, de
            ld      c, (hl)         ; the byte every wall cell gets

            ; the top wall: row 1 is 32 cells in a row from $5820
            ; (row 0 is kept back — it becomes the HUD later)
            ld      hl, $5820
            ld      b, 32
.wt:
            ld      (hl), c
            inc     hl
            djnz    .wt

            ; the bottom wall: row 23, 32 cells from $5AE0
            ld      hl, $5AE0
            ld      b, 32
.wb:
            ld      (hl), c
            inc     hl
            djnz    .wb

            ; the side walls: column 0 and column 31 of rows 1-23.
            ; Write the row's first cell, hop 31 cells to its last,
            ; then step a full row (32) down — 23 times.
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

; ----------------------------------------------------------------------------
; The beeper. One bit on port $FE: set it, wait, clear it, wait — a
; square wave by hand. C is the half-period (pitch: bigger is lower),
; B the number of cycles (duration). DI while it sounds: the 50 Hz
; interrupt would stretch random half-periods and buzz the tone.
; ----------------------------------------------------------------------------
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

blip_lit:                           ; a rising third — the lamp catches
            ld      b, $17          ; C6
            ld      c, $67
            call    beep
            ld      b, $28          ; E6
            ld      c, $51
            jp      beep

chime_dusk:                         ; two cold tolls, then the motif far off
            ld      b, $84          ; A4
            ld      c, $F7
            call    beep
            ld      b, 10
            call    rest
            ld      b, $84          ; A4
            ld      c, $F7
            call    beep
            ld      b, 13
            call    rest
            ld      b, $92          ; E5
            ld      c, $A4
            call    beep
            ld      b, 4
            call    rest
            ld      b, $9D          ; C5
            ld      c, $CF
            jp      beep

; rest — B frames of silence. Musical time rides the heartbeat: the
; gaps between notes are counted in HALTs, not busy-loops.
rest:
            halt
            djnz    rest
            ret

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
; Screens.
; ----------------------------------------------------------------------------

; draw_win_screen — lift the lamplighter off the board (restore his
; cell: the eighth lamp, lit, comes out of the buffer), then say it.
; draw_title_screen — sparse and suggestive: a black void, the name,
; the invitation. Everything else is left to the imagination, which
; is both the aesthetic and the budget.
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
            ; your best night — the lives you kept on your finest win,
            ; read in lamps (no digits). It survives the loop back to
            ; the title: the go-again hook.
            ld      hl, $5800 + 11 * 32 + 14
            ld      b, LIVES
            ld      a, (best_lives)
            ld      c, a
.tpip:
            ld      a, PIP_UNLIT
            inc     c
            dec     c
            jr      z, .tpcold
            ld      a, PIP_LIT
            dec     c
.tpcold:
            ld      (hl), a
            inc     hl
            djnz    .tpip
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

; draw_lose_screen — the whole attribute table goes black: every lamp,
; every wall, every warm cell, gone in one LDIR. Then the words.
; draw_dawn_screen — the same lift-and-say as the win screen, with
; the morning's own words. The square stands as the run left it.
draw_dawn_screen:
            call    restore_under
            ld      hl, dawn_text
            ld      b, MSG_ROW
            ld      c, DAWN_COL
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

; ----------------------------------------------------------------------------
; clear_bitmap — zero the pixel layer, $4000-$57FF, with the same
; seed-and-cascade LDIR idiom the cobble wash uses.
; ----------------------------------------------------------------------------
clear_bitmap:
            ld      hl, $4000
            ld      de, $4001
            ld      (hl), 0
            ld      bc, 6143
            ldir
            ret

; ----------------------------------------------------------------------------
; player_step — the keys become movement. Each direction key edits a
; TARGET position (tcol, trow) — a proposal, not yet a move — so it
; can be vetoed before it becomes real. Then the move commits: leave
; the old cell, take the new one, draw.
; ----------------------------------------------------------------------------
player_step:
            ; --- propose: the target starts where he stands ---
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
            bit     1, a            ; O — a zero bit is a pressed key
            jr      z, .pleft
            bit     0, a            ; P, same half-row
            jr      z, .pright
            ld      bc, KEYS_Q
            in      a, (c)
            bit     0, a            ; Q
            jr      z, .pup
            ld      bc, KEYS_A
            in      a, (c)
            bit     0, a            ; A
            jr      z, .pdown
            ret                     ; nothing held — nothing to do

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
            ; The veto: ask the target cell's attribute whether it's wall.
            ; NZ means brick — the proposal dies here and he stays put.
            ld      a, (trow)
            ld      b, a
            ld      a, (tcol)
            ld      c, a
            call    wall_at
            ret     nz
            ; the solid night blocks too — you cannot walk into the dark
            ld      a, (hl)
            cp      DARK
            ret     z

            ; and the mirror rule: he cannot step onto the wisp either
            ld      a, (tcol)
            ld      hl, draught_col
            cp      (hl)
            jr      nz, .pcommit
            ld      a, (trow)
            ld      hl, draught_row
            cp      (hl)
            jr      nz, .pcommit
            call    lose_life       ; walking into the cold costs the same
            ret

.pcommit:
            ; --- commit: restore, step, save, draw — in that order ---
            call    restore_under
            ld      a, (tcol)
            ld      (lamp_col), a
            ld      a, (trow)
            ld      (lamp_row), a
            call    save_under
            ; light it where it lives: while he covers the lamp, its truth
            ; is the buffer — rewrite the saved attribute, and restore will
            ; paint the lamp back lit when he leaves
            ld      a, (under_lamp + 8)
            cp      LAMP_UNLIT
            jr      nz, .pdrawn
            ld      a, LAMP_LIT
            ld      (under_lamp + 8), a
            ; record the lighting order — the night bears its grudges
            ; oldest-first (lamp_col/lamp_row are the lamplighter's
            ; position, and he is standing on the lamp)
            ld      a, (lamp_col)
            ld      c, a
            ld      a, (lamp_row)
            ld      b, a
            call    lamp_index_at
            call    lit_push
            call    light_pip
            call    blip_lit
            call    warm_walls
            call    recompute_pools
.pdrawn:
            call    draw_lamp
            ret

; ----------------------------------------------------------------------------
; fill_ground — the cobble stipple. Not decoration: the stipple is what
; makes ground-state changes visible later, when the game starts
; recolouring these pixels. Rows 1-23 (row 0 is the HUD).
; ----------------------------------------------------------------------------
fill_ground:
            ld      b, 1                ; rows 1-23 (row 0 is the HUD)
.fgr:
            ld      c, 0
.fgc:
            ld      de, cobble_tex
            call    blit_tex
            inc     c
            ld      a, c
            cp      32
            jr      c, .fgc
            inc     b
            ld      a, b
            cp      24
            jr      c, .fgr
            ret

; fill_walls — brickwork. Driven by the wall attribute bit, so anything
; painted as wall — now or later in the game — gets its brick for free:
; the map itself decides where the brick goes.
fill_walls:
            ld      b, 1
.fwr:
            ld      c, 0
.fwc:
            push    bc
            call    attr_addr_cr
            bit     WALL_BIT, (hl)
            pop     bc
            jr      z, .fwn
            ld      de, brick_tex
            call    blit_tex
.fwn:
            inc     c
            ld      a, c
            cp      32
            jr      c, .fwc
            inc     b
            ld      a, b
            cp      24
            jr      c, .fwr
            ret

; blit_tex — write the 8-byte texture at DE into cell (C, B)'s bitmap.
; scr_addr_cr finds the cell's first pixel row; INC H steps down the
; other seven, 256 bytes apart.
blit_tex:
            push    bc
            call    scr_addr_cr
            ld      b, 8
.bt:
            ld      a, (de)
            ld      (hl), a
            inc     de
            inc     h
            djnz    .bt
            pop     bc
            ret

cobble_tex:
            defb    %10000010
            defb    %00000000
            defb    %00001000
            defb    %00000000
            defb    %00100001
            defb    %00000000
            defb    %00010000
            defb    %00000000

mist_tex:
            ; the solid night — dense, swirling, unmistakably *there*
            defb    %01101100
            defb    %11011011
            defb    %00110110
            defb    %01101101
            defb    %11011010
            defb    %10110110
            defb    %01101011
            defb    %11010110

brick_tex:
            ; mortar courses with staggered verticals — dusk-lit stone
            defb    %00001000
            defb    %00001000
            defb    %00001000
            defb    %11111111
            defb    %10000000
            defb    %10000000
            defb    %10000000
            defb    %11111111

; ----------------------------------------------------------------------------
; recompute_pools — the lamps cast their light. Every glow cell dies
; back to bare cobble, then every LIT lamp warms its eight neighbours.
; Derived, not tracked: called after any light or snuff, it rebuilds
; the whole layer from lamp truth, so the pools can never drift.
; ----------------------------------------------------------------------------
recompute_pools:
            ; the discipline: both movers OFF the screen first, so the
            ; recolour reads and writes true ground — never a sprite,
            ; and never into a buffer that would restore stale colour
            call    restore_under
            call    restore_draught
            ld      hl, $5820           ; rows 1-23 (row 0 is the HUD)
            ld      bc, 736
.rp1:
            ld      a, (hl)
            cp      GLOW
            jr      nz, .rp1n
            ld      (hl), COBBLE
.rp1n:
            inc     hl
            dec     bc
            ld      a, b
            or      c
            jr      nz, .rp1
            ld      hl, lamp_data
.rp2:
            ld      a, (hl)
            cp      $FF
            jr      z, .rpdone
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
            jr      nz, .rp2n
            call    glow_ring
.rp2n:
            pop     hl
            jr      .rp2
.rpdone:
            ; ...and back on, their buffers re-photographing ground
            ; that now includes the glow
            call    save_under
            call    save_draught
            call    draw_lamp
            call    draw_draught
            ret

; glow_ring — warm the eight cells around lamp (C = col, B = row) where
; they are bare cobble. Pools never take walls, posts, or the dark.
glow_ring:
            ld      hl, ring_offsets
            ld      e, 8
.gr:
            push    hl
            push    de
            push    bc
            ld      a, (hl)
            add     a, c
            ld      c, a
            inc     hl
            ld      a, (hl)
            add     a, b
            ld      b, a
            call    attr_addr_cr
            ld      a, (hl)
            cp      COBBLE
            jr      nz, .grn
            ld      (hl), GLOW
.grn:
            pop     bc
            pop     de
            pop     hl
            inc     hl
            inc     hl
            dec     e
            jr      nz, .gr
            ret

ring_offsets:
            defb    -1, -1,  0, -1,  1, -1
            defb    -1,  0,          1,  0
            defb    -1,  1,  0,  1,  1,  1

; ----------------------------------------------------------------------------
; dawn_sweep — morning enters from the sky: row by row the ground
; warms to gold and the night's mist burns off (dark cells get their
; stipple back). Walls, lamps, text, and the two figures are left to
; the palettes they already wear. Blocking, like the fanfare — the
; ending is allowed a second of ceremony.
; ----------------------------------------------------------------------------
dawn_sweep:
            ld      b, 1
.dsr:
            halt
            halt
            ld      c, 0
.dsc:
            push    bc
            call    attr_addr_cr
            ld      a, (hl)
            cp      DARK
            jr      nz, .dsn1
            pop     bc
            push    bc
            push    hl
            ld      de, cobble_tex
            call    blit_tex
            pop     hl
            jr      .dsset
.dsn1:
            cp      COBBLE
            jr      z, .dsset
            cp      GLOW
            jr      nz, .dsnext
.dsset:
            ld      (hl), GLOW
.dsnext:
            pop     bc
            inc     c
            ld      a, c
            cp      32
            jr      c, .dsc
            inc     b
            ld      a, b
            cp      24
            jr      c, .dsr
            ret

; ----------------------------------------------------------------------------
; lamp_index_at — which lamp_data entry sits at (C = col, B = row)?
; Returns the index in A ($FF if none — callers only ask about cells
; they know hold a lamp).
; ----------------------------------------------------------------------------
lamp_index_at:
            ld      hl, lamp_data
            ld      e, 0
.lia:
            ld      a, (hl)
            cp      $FF
            ret     z
            cp      c
            jr      nz, .lian
            inc     hl
            ld      a, (hl)
            dec     hl
            cp      b
            jr      nz, .lian
            ld      a, e
            ret
.lian:
            inc     hl
            inc     hl
            inc     e
            jr      .lia

; lit_push — append lamp index (A) to the lit-order queue.
lit_push:
            ld      e, a
            ld      a, (lit_qcount)
            ld      d, a
            inc     a
            ld      (lit_qcount), a
            ld      a, d
            ld      hl, lit_queue
            add     a, l
            ld      l, a
            jr      nc, .lp
            inc     h
.lp:
            ld      (hl), e
            ret

; lit_remove — take lamp index (A) out of the lit-order queue,
; closing the gap.
lit_remove:
            ld      e, a
            ld      hl, lit_queue
            ld      a, (lit_qcount)
            ld      d, a
            or      a
            ret     z
.lr:
            ld      a, (hl)
            cp      e
            jr      z, .lrfound
            inc     hl
            dec     d
            jr      nz, .lr
            ret
.lrfound:
            dec     d
            jr      z, .lrlast
.lrshift:
            inc     hl
            ld      a, (hl)
            dec     hl
            ld      (hl), a
            inc     hl
            dec     d
            jr      nz, .lrshift
.lrlast:
            ld      a, (lit_qcount)
            dec     a
            ld      (lit_qcount), a
            ret

; ----------------------------------------------------------------------------
; draught_step — the hunt bears grudges. The wisp steps toward the
; OLDEST grievance: the head of the lit-order queue, or, with
; nothing lit, the lamplighter's own flame. Still no walls.
; ----------------------------------------------------------------------------
draught_step:
            ld      a, (draught_timer)
            dec     a
            ld      (draught_timer), a
            ret     nz
            ld      a, (dusk_speed)
            ld      (draught_timer), a

            ; withdrawing? after a snuff the night carries its prize
            ; home before hunting again — behaviour is a MODE now, and
            ; the mode decides what this beat means
            ld      a, (draught_mode)
            or      a
            jr      z, .hunt
            ld      a, (draught_home_col)
            ld      hl, draught_col
            cp      (hl)
            jr      nz, .whome
            ld      a, (draught_home_row)
            ld      hl, draught_row
            cp      (hl)
            jr      nz, .whome
            xor     a                   ; home — rest, then the hunt resumes
            ld      (draught_mode), a
            ld      a, WREST
            ld      (draught_timer), a
            ret
.whome:
            ld      a, (draught_home_col)
            ld      (seek_col), a
            ld      a, (draught_home_row)
            ld      (seek_row), a
            jp      .chase
.hunt:
            ; the oldest flame is the night's grievance — it reclaims
            ; the ground it lost first. With nothing lit, it hunts the
            ; lamplighter's own flame: light your first lamp and the
            ; hunt turns away from you.
            ld      a, (lit_qcount)
            or      a
            jr      nz, .oldest
            ld      a, (lamp_col)
            ld      (seek_col), a
            ld      a, (lamp_row)
            ld      (seek_row), a
            jr      .chase
.oldest:
            ld      a, (lit_queue)
            add     a, a
            ld      e, a
            ld      d, 0
            ld      hl, lamp_data
            add     hl, de
            ld      a, (hl)
            ld      (seek_col), a
            inc     hl
            ld      a, (hl)
            ld      (seek_row), a

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
            ; never step ONTO the lamplighter: adjacent is as close as
            ; the night comes. Two movers, two buffers — and one cell
            ; can only ever be under one of them.
            ld      a, (dtcol)
            ld      hl, lamp_col
            cp      (hl)
            jr      nz, .dmove
            ld      a, (dtrow)
            ld      hl, lamp_row
            cp      (hl)
            jr      nz, .dmove
            call    lose_life       ; the touch, priced
            ret

.dmove:
            call    restore_draught
            ; the tendril: night pools where the wisp has walked. Ground
            ; and spilt light are both taken; posts and stone are not.
            ld      a, (draught_col)
            ld      c, a
            ld      a, (draught_row)
            ld      b, a
            push    bc
            call    attr_addr_cr
            pop     bc
            ld      a, (hl)
            cp      DARK
            jr      z, .retake
            cp      COBBLE
            jr      z, .take
            cp      GLOW
            jr      nz, .notake
.take:
            ld      (hl), DARK
            ld      de, mist_tex
            call    blit_tex
.retake:
            call    tendril_push
.notake:
            ld      a, (dtcol)
            ld      (draught_col), a
            ld      a, (dtrow)
            ld      (draught_row), a
            call    save_draught
            ; the snuff: while the wisp covers a lit lamp, the lamp's
            ; truth is ITS buffer — the same saved-under rule that lights
            ; lamps beneath the lamplighter, run by the villain. Rewrite
            ; the saved attribute to cold, and the wisp's own restore
            ; will leave the lamp out as it moves on.
            ld      a, (under_draught + 8)
            cp      LAMP_LIT
            jr      nz, .nosnuff
            ld      a, LAMP_UNLIT
            ld      (under_draught + 8), a
            ; the grievance is settled — off the lit-order queue
            ld      a, (draught_col)
            ld      c, a
            ld      a, (draught_row)
            ld      b, a
            call    lamp_index_at
            call    lit_remove
            call    unlight_pip
            call    warm_walls
            call    recompute_pools
            ld      a, 1                ; the prize is taken — withdraw
            ld      (draught_mode), a
.nosnuff:
            call    draw_draught
            ret

; ----------------------------------------------------------------------------
; tendril_push — record darkened cell (C = col, B = row) in the tendril
; ring. When the ring is full the oldest cell releases back to bare
; cobble first — the night cannot hold ground beyond its reach, so the
; tendril can never permanently wall the square off.
; ----------------------------------------------------------------------------
tendril_push:
            ld      a, (tendril_len)
            ld      hl, tendril_max
            cp      (hl)
            jr      c, .tgrow
            ; full: release the oldest cell (the slot head points at)
            push    bc
            ld      a, (tendril_head)
            add     a, a
            ld      e, a
            ld      d, 0
            ld      hl, tendril_buf
            add     hl, de
            ld      c, (hl)
            inc     hl
            ld      b, (hl)
            ; a newer ring entry may still claim this cell (the wisp
            ; re-walks its own trail) — then the night keeps it
            call    tendril_claimed
            jr      z, .treld
            ; if the wisp itself is crossing that cell, mend its saved
            ; ground instead of the screen
            ld      a, (draught_col)
            cp      c
            jr      nz, .trel
            ld      a, (draught_row)
            cp      b
            jr      nz, .trel
            ; mend the wisp's saved ground: stipple, and glow if a lit
            ; lamp still pools this cell — the light heals behind the dark
            push    bc
            ld      hl, cobble_tex
            ld      de, under_draught
            ld      bc, 8
            ldir
            pop     bc
            call    pooled_at
            ld      a, COBBLE
            jr      nz, .tsetu
            ld      a, GLOW
.tsetu:
            ld      (under_draught + 8), a
            jr      .treld
.trel:
            push    bc
            call    attr_addr_cr
            pop     bc
            ld      a, (hl)
            cp      DARK
            jr      nz, .treld
            push    hl
            call    pooled_at
            pop     hl
            ld      a, COBBLE
            jr      nz, .tset
            ld      a, GLOW
.tset:
            ld      (hl), a
            ld      de, cobble_tex
            call    blit_tex
.treld:
            pop     bc
            jr      .tstore
.tgrow:
            inc     a
            ld      (tendril_len), a
.tstore:
            ld      a, (tendril_head)
            add     a, a
            ld      e, a
            ld      d, 0
            ld      hl, tendril_buf
            add     hl, de
            ld      (hl), c
            inc     hl
            ld      (hl), b
            ld      a, (tendril_head)
            inc     a
            ld      hl, tendril_max
            cp      (hl)
            jr      c, .tadv
            xor     a
.tadv:
            ld      (tendril_head), a
            ret

; paint_buildings — walk the rectangle table: each entry is col, row,
; width, height; $FF ends the list. Every cell inside a rectangle gets
; the WALL attribute — and because fill_walls textures by the wall bit,
; the brickwork arrives without another line of drawing code.
paint_buildings:
            ld      hl, bldg_data
.pb:
            ld      a, (hl)
            cp      $FF
            ret     z
            ld      c, a                ; col
            inc     hl
            ld      b, (hl)             ; row
            inc     hl
            ld      d, (hl)             ; width
            inc     hl
            ld      e, (hl)             ; height
            inc     hl
            push    hl
.pbrow:
            push    bc
            push    de
.pbcol:
            push    bc
            push    de
            call    attr_addr_cr
            ld      (hl), WALL
            pop     de
            pop     bc
            inc     c
            dec     d
            jr      nz, .pbcol
            pop     de
            pop     bc
            inc     b
            dec     e
            jr      nz, .pbrow
            pop     hl
            jr      .pb

bldg_data:
            defb    5, 5, 4, 3
            defb    23, 5, 4, 3
            defb    $FF

corner_tab:
            ; where the dark enters, per watch (NE, SE, SW, NW)
            defb    28, 4
            defb    28, 19
            defb    3, 19
            defb    3, 4

; ----------------------------------------------------------------------------
; tendril_claimed — does any ring slot other than head hold (C, B)?
; Z set if claimed. Only called with the ring full, so every slot holds
; a real cell.
; ----------------------------------------------------------------------------
tendril_claimed:
            ld      hl, tendril_buf
            ld      e, 0
.tc:
            ld      a, (tendril_head)
            cp      e
            jr      z, .tcn             ; the slot being released — skip
            ld      a, (hl)
            cp      c
            jr      nz, .tcn
            inc     hl
            ld      a, (hl)
            dec     hl
            cp      b
            jr      nz, .tcn
            xor     a                   ; Z — a newer claim holds it
            ret
.tcn:
            inc     hl
            inc     hl
            inc     e
            ld      a, (tendril_max)
            cp      e
            jr      nz, .tc
            or      a                   ; NZ (max is never 0) — free
            ret

; ----------------------------------------------------------------------------
; pooled_at — is cell (C, B) within one cell of a LIT lamp? Z if so.
; The light heals: released tendril ground inside a live pool returns
; to glow, not bare cobble.
; ----------------------------------------------------------------------------
pooled_at:
            ld      hl, lamp_data
.pa:
            ld      a, (hl)
            cp      $FF
            jr      z, .pano
            ld      e, a                ; lamp col
            inc     hl
            ld      d, (hl)             ; lamp row
            inc     hl
            ld      a, e
            sub     c
            jp      p, .pac
            neg
.pac:
            cp      2
            jr      nc, .pa
            ld      a, d
            sub     b
            jp      p, .par
            neg
.par:
            cp      2
            jr      nc, .pa
            push    hl
            push    bc
            ld      c, e
            ld      b, d
            call    attr_addr_cr
            ld      a, (hl)
            pop     bc
            pop     hl
            cp      LAMP_LIT
            jr      nz, .pa
            xor     a                   ; Z — pooled by a lit lamp
            ret
.pano:
            or      1                   ; NZ — bare ground
            ret

; ----------------------------------------------------------------------------
; lose_life — the price of the touch: one ember out, and either a
; fresh start or the fall of night.
; ----------------------------------------------------------------------------
lose_life:
            ld      a, (lives)
            dec     a
            ld      (lives), a
            ld      e, a
            ld      d, 0
            ld      hl, LIFE_BASE
            add     hl, de
            ld      (hl), COBBLE    ; the ember at the new count goes out
            ld      a, (lives)
            or      a
            jr      z, .gone
            ; a life left: the lamplighter returns to the start cell
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
            ld      a, (draught_home_col)
            ld      (draught_col), a
            ld      a, (draught_home_row)
            ld      (draught_row), a
            ld      a, (dusk_speed)
            ld      (draught_timer), a
            xor     a                   ; already home — hunt on arrival
            ld      (draught_mode), a
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
; print_string / print_char — the machine's own letters. The Spectrum
; keeps its font in ROM: eight bytes per character, and FONT is chosen
; so that ASCII code x 8 + FONT is the glyph's address. Each character
; is drawn like any cell: attribute first, eight rows down the cell.
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

; light_pip — warm the next pip along and count the lamp. lit_count is
; the index of the pip to light AND the number of lamps lit so far —
; read it for the address, then step it.
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

; unlight_pip — light_pip's mirror: step the count back and cool the
; pip at the new count. The tally can go DOWN now.
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

; draw_pips — the tally row: one cell per lamp on the HUD ledge, all
; cold to start. A pip is pure attribute — no glyph, just a block of
; PAPER — so the row costs eight bytes of screen and no bitmap at all.
draw_pips:
            ld      hl, PIP_BASE
            ld      b, NUM_LAMPS
            ld      a, PIP_UNLIT
.dp:
            ld      (hl), a
            inc     hl
            djnz    .dp
            ret

; draw_lives — the embers on the ledge's right shoulder. Read the
; CARRIED lives, not the constant: a run's lives survive the watches
; now, and the ledge must say so. (The constant version repainted
; three every watch — a lie we only caught while taking this game
; apart for this module. Playtests read the square; nobody read the
; ledger across a watch boundary.)
draw_lives:
            ld      hl, LIFE_BASE
            ld      a, (lives)
            ld      b, a
            ld      a, LIFE_PIP
.dlv:
            ld      (hl), a
            inc     hl
            djnz    .dlv
            ret

; ----------------------------------------------------------------------------
; draw_lamps — walk the position table: col, row pairs, $FF to finish.
; Placement is data; the drawing code neither knows nor cares how many
; lamps the town has tonight.
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

; draw_lantern — an unlit lamp into cell (C, B): cold cyan attribute,
; then the lantern glyph down the cell like any texture.
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
; scr_addr_cr — HL = bitmap address of cell (C, B)'s first pixel row.
; The row's top two bits pick the third of the screen (H), its bottom
; three become L's top bits, and the column fills L's low five.
; ----------------------------------------------------------------------------

scr_addr_cr:
            ld      a, b
            and     %00011000       ; the third (row bits 4-3) ...
            or      %01000000       ; ... under the screen base $40xx
            ld      h, a
            ld      a, b
            and     %00000111       ; the char row within the third ...
            rrca                    ; ... rotated into bits 7-5
            rrca
            rrca
            or      c               ; the column in bits 4-0
            ld      l, a
            ret

; attr_addr_cr — HL = attribute address of cell (C, B):
; $5800 + row*32 + col, the row shifted up five times.
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

; wall_at — is cell (C, B) wall? The answer is already on the screen:
; every wall cell's attribute has WALL_BIT set, so one bit-test of
; attribute memory is the whole collision system. NZ = wall.
wall_at:
            call    attr_addr_cr
            bit     WALL_BIT, (hl)
            ret

; ----------------------------------------------------------------------------
; The lamplighter's save / restore / draw.
; ----------------------------------------------------------------------------

; pos_bc — the lamplighter's cell into (C, B), read fresh from the data.
pos_bc:
            ld      a, (lamp_row)
            ld      b, a
            ld      a, (lamp_col)
            ld      c, a
            ret

; save_under — copy the nine bytes of his cell into the buffer: eight
; bitmap rows, then the attribute. Runs as he ARRIVES, before the
; draw — so the buffer always holds true ground, never him.
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

; restore_under — the same nine bytes back the other way: the ground
; returns exactly as it was. Runs as he LEAVES, while the position
; still points at the old cell.
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
            ; his colour first: the cell's attribute becomes his own —
            ; bright white on the black, his own light about him
            call    pos_bc
            call    attr_addr_cr
            ld      (hl), LAMP_ATTR
            ; then his shape, eight bytes down the cell like any texture
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
; The draught's save / restore / draw — the lamplighter's engine, twice.
; Same loops, same nine-byte contract, its own buffer and its own
; position: two movers can share a world but never a buffer.
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
            ; The final watch is pace 9, not 8 — playtested: 8 is the
            ; human wall, 9 is beatable. The last watch should be the
            ; climax, not the ceiling.
            defb    16, 13, 11, 9, 9

dusk_lentab:
            ; the tendril's reach per watch (cells of night held) —
            ; the second axis of the deepening. Front-loading reach
            ; made watch 1 brutal (playtested: a practised player lost
            ; at watch 2) — the opening teaches the mechanic, the deep
            ; watches punish with it.
            defb    3, 6, 9, 13, 18

wall_ramp:
            ; The square warms in the game's own vocabulary: the stone
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
best_lives:
            defb    0               ; lives kept on the finest win — never reset

draught_col:
            defb    28
draught_row:
            defb    4
draught_home_col:
            defb    28
draught_home_row:
            defb    4
draught_mode:
            defb    0               ; 0 = hunting, 1 = withdrawing home
draught_timer:
            defb    16
player_timer:
            defb    0
dusk:
            defb    0               ; which watch of the night this is
dusk_speed:
            defb    16
seek_col:
            defb    0
seek_row:
            defb    0
lit_queue:
            defb    0, 0, 0, 0, 0, 0, 0, 0
lit_qcount:
            defb    0
tendril_head:
            defb    0
tendril_len:
            defb    0
tendril_max:
            defb    6               ; the night's reach — six cells of held ground
tendril_buf:
            defb    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
            defb    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
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

dawn_text:
            defb    "DAWN BREAKS"
            defb    $FF

            end     start
