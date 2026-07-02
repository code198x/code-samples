; Gloaming — route skeleton, unit 01: The Empty Square
; The screen is the map: one attribute write per cell makes a square at dusk.
; Method: subset of gloaming-m1.asm, derived by reverse subtraction.

            org     32768

COBBLE      equ     %00000001
WALL        equ     %00001111

; ============================================================================
; SETUP.
; ============================================================================
start:
            ld      a, 0
            out     ($FE), a
            call    clear_bitmap
            ld      hl, $5800
            ld      de, $5801
            ld      (hl), COBBLE
            ld      bc, 767
            ldir
            call    paint_walls

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

            end     start
