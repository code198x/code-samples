; Gloaming — route skeleton, unit 02: The Cobbles and the Brick
; The canvas: bitmap texture under the attributes — cobbles and brickwork.
; Method: subset of gloaming-m1.asm, derived by reverse subtraction.

            org     32768

COBBLE      equ     %00000001
WALL        equ     %00001111
WALL_BIT    equ     3

; ============================================================================
; SETUP.
; ============================================================================
start:
            ld      a, 0
            out     ($FE), a
            call    clear_bitmap
            call    fill_ground
            ld      hl, $5800
            ld      de, $5801
            ld      (hl), COBBLE
            ld      bc, 767
            ldir
            call    paint_walls
            call    fill_walls

forever:
            jr      forever

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

            end     start
