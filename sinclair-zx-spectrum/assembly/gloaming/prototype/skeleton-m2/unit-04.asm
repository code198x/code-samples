; Gloaming — route skeleton (module 2), unit 04: The Tendril
; The night takes territory: a ring buffer of darkness that releases its oldest claim.
; Method: detour spine — the history's nearest-light hunt (7463ded..b601157) under final-form text; converges on the backbone at unit 5.

            org     32768

COBBLE      equ     %00000001
GLOW        equ     %00000110       ; pool-warmed cobble — ground the light holds
DARK        equ     %01000001       ; the night made solid — bright-blue mist, impassable
WALL        equ     %00001111
LAMP_ATTR   equ     %01000111
LAMP_UNLIT  equ     %00000101
LAMP_LIT    equ     %01000110
WALL_BIT    equ     3

DRAUGHT_ATTR  equ   %01000101
DRAUGHT_SPEED equ   16              ; frames between the wisp's steps
DRAUGHT_COL0  equ   28              ; the corner the dark enters from
DRAUGHT_ROW0  equ   4
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
STATE_WIN   equ     2               ; the night is held — the game is won
STATE_LOSE  equ     3
LOCK        equ     25              ; input-lock frames after entering a screen

START_COL   equ     15
START_ROW   equ     11
GATHER      equ     120             ; frames the dark gathers before its first step
WREST       equ     48              ; frames it rests at home after a withdrawal —
                                    ; the snuff window holds even when home is close

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
            call    init_game
            ld      a, STATE_PLAY
            ld      (game_state), a
            ret

; ----------------------------------------------------------------------------
; end_step — WIN or LOSE: after the lock, SPACE returns to the title.
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
            call    draw_title_screen
            call    chime_dusk
            ld      a, LOCK
            ld      (input_lock), a
            ld      a, STATE_TITLE
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
            ld      (draught_home_col), a
            ld      a, DRAUGHT_ROW0
            ld      (draught_row), a
            ld      (draught_home_row), a
            ; the dark gathers before its first step — a beat to read
            ; the square before the hunt begins
            ld      a, GATHER
            ld      (draught_timer), a
            xor     a
            ld      (player_timer), a
            ld      (tendril_len), a
            ld      (tendril_head), a
            ld      (draught_mode), a

            call    clear_bitmap
            call    fill_ground
            ld      hl, $5800
            ld      de, $5801
            ld      (hl), COBBLE
            ld      bc, 767
            ldir
            call    warm_walls
            call    paint_buildings
            call    fill_walls
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
            ; the solid night blocks too — you cannot walk into the dark
            ld      a, (hl)
            cp      DARK
            ret     z

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
            call    recompute_pools
.pdrawn:
            call    draw_lamp
            ret

; ----------------------------------------------------------------------------
; recompute_pools — the lamps cast their light. Every glow cell dies back
; to bare cobble, then every LIT lamp warms its eight neighbours. Called
; after any light or snuff. Both movers are restored to the screen first
; so cell truth is readable, and re-saved after — their under-buffers
; stay honest through the recolour.
; ----------------------------------------------------------------------------
; ----------------------------------------------------------------------------
; fill_ground — the cobble stipple (brief §6). Not decoration: the
; stipple is what makes ground-state changes visible. Glow recolours
; these pixels warm; the dark (ink = paper = black) swallows them —
; a void in the stipple field reads as ground the night has taken.
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

; fill_walls — brickwork (brief §6: "reads as built, solid"). Driven by
; the wall attribute bit, so any future interior buildings get their
; brick for free. Runs at init while the ramp's blue holds the bit.
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

recompute_pools:
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
            ld      a, DRAUGHT_SPEED
            ld      (draught_timer), a

            ; withdrawing? after a snuff the night carries its prize
            ; home before hunting again — every snuff buys the
            ; lamplighter a window, and the hunt re-enters from a
            ; quarter he can plan against
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
            ; the tendril: night pools where the wisp has walked. Ground
            ; and spilt light are both taken (the pool heals on release);
            ; posts and stone are not. Re-walking its own trail refreshes
            ; the night's claim, so the tendril never gaps mid-vein.
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
            ld      a, (under_draught + 8)
            cp      LAMP_LIT
            jr      nz, .nosnuff
            ld      a, LAMP_UNLIT
            ld      (under_draught + 8), a
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

; ----------------------------------------------------------------------------
; paint_buildings — interior buildings for routing (brief §6 layout).
; Rectangles from bldg_data (col, row, width, height); the wall
; attribute makes them solid to the player, and fill_walls bricks them.
; The wisp ghosts through — you walk around what the night ignores.
; ----------------------------------------------------------------------------
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
            ld      a, (draught_home_col)
            ld      (draught_col), a
            ld      a, (draught_home_row)
            ld      (draught_row), a
            ld      a, DRAUGHT_SPEED
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
seek_col:
            defb    0
seek_row:
            defb    0
seek_best:
            defb    0
tendril_head:
            defb    0
tendril_len:
            defb    0
tendril_max:
            defb    6
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

            end     start
