; Gloaming — route skeleton, unit 05: Reading the Keys
; Scan a half-row; a zero bit is a pressed key — the lamplighter glows to prove it.
; Method: detour, authored forward; converges on the backbone at unit 10.

            org     32768

COBBLE      equ     %00000001
WALL        equ     %00001111
LAMP_ATTR   equ     %01000111
LAMP_GLOW   equ     %01000110       ; the glow while a key is down (detour)
WALL_BIT    equ     3

START_COL   equ     15
START_ROW   equ     11

KEYS_OP     equ     $DFFE
KEYS_Q      equ     $FBFE
KEYS_A      equ     $FDFE

; ============================================================================
; SETUP.
; ============================================================================
start:
            ld      a, 0
            out     ($FE), a
            ld      a, START_COL
            ld      (lamp_col), a
            ld      a, START_ROW
            ld      (lamp_row), a

            call    clear_bitmap
            call    fill_ground
            ld      hl, $5800
            ld      de, $5801
            ld      (hl), COBBLE
            ld      bc, 767
            ldir
            call    paint_walls
            call    fill_walls
            call    draw_lamp
            im      1
            ei

main_loop:
            halt
            call    play_step
            jr      main_loop

play_step:
            call    player_step
            ret

paint_walls:
            ld      c, WALL
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
            ld      bc, KEYS_OP
            in      a, (c)
            bit     1, a
            jr      z, .held
            bit     0, a
            jr      z, .held
            ld      bc, KEYS_Q
            in      a, (c)
            bit     0, a
            jr      z, .held
            ld      bc, KEYS_A
            in      a, (c)
            bit     0, a
            jr      z, .held
            call    pos_bc
            call    attr_addr_cr
            ld      (hl), LAMP_ATTR
            ret
.held:
            call    pos_bc
            call    attr_addr_cr
            ld      (hl), LAMP_GLOW
            ret

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
; brick for free.
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
; scr_addr_cr / attr_addr_cr.
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
; The lamplighter's draw.
; ----------------------------------------------------------------------------

pos_bc:
            ld      a, (lamp_row)
            ld      b, a
            ld      a, (lamp_col)
            ld      c, a
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
; Data.
; ----------------------------------------------------------------------------

lamp_col:
            defb    START_COL
lamp_row:
            defb    START_ROW

lamplighter:
            defb    %00111100
            defb    %00111100
            defb    %00011000
            defb    %01111110
            defb    %00011000
            defb    %00011000
            defb    %00100100
            defb    %01000010

            end     start
