; Shadowkeep — Unit 1: A Hooded Figure
; Cumulative build; every step runs on its own. Narrative: the unit page.
; step-02 stands the hooded thief in the centre of the keep.

            org     32768

STONE       equ     %00001000       ; PAPER 1 (blue), INK 0 — cold blue stone
THIEF       equ     %01001010       ; BRIGHT, PAPER 1 (blue), INK 2 (red) — the thief
HERO_COL    equ     15              ; the middle of the keep, as in Gloaming
HERO_ROW    equ     11

; ----------------------------------------------------------------------------
; SETUP — the keep is dark, and a figure stands in it.
; ----------------------------------------------------------------------------
start:
            ld      a, 0
            out     ($FE), a        ; black border — the keep wants the dark

            ld      hl, $5800       ; wash all 768 attribute cells in stone
            ld      de, $5801
            ld      (hl), STONE
            ld      bc, 767
            ldir

            call    draw_thief

            im      1
            ei
.loop:
            halt
            jr      .loop

; ----------------------------------------------------------------------------
; draw_thief — colour his cell, then lay his eight rows into the bitmap.
; Exactly Gloaming's draw_lamp, pointed at a different eight bytes.
; ----------------------------------------------------------------------------
draw_thief:
            ld      b, HERO_ROW
            ld      c, HERO_COL
            call    attr_addr_cr
            ld      (hl), THIEF
            call    scr_addr_cr     ; B,C still hold the row and column
            ld      de, thief
            ld      b, 8
.dt:
            ld      a, (de)
            ld      (hl), a
            inc     de
            inc     h               ; next pixel row is one cell-third down: +256
            djnz    .dt
            ret

; ----------------------------------------------------------------------------
; scr_addr_cr / attr_addr_cr — row in B, column in C, address out in HL.
; Carried verbatim from Gloaming.
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
; The hooded thief — eight bytes, drawn here so you can read the figure in the
; ones and zeros: a pointed hood, a cloaked body, two feet at the hem.
; ----------------------------------------------------------------------------
thief:
            defb    %00011000       ; ...XX...   the hood's peak
            defb    %00111100       ; ..XXXX..   the hood
            defb    %01111110       ; .XXXXXX.   hood meets shoulders
            defb    %01111110       ; .XXXXXX.   the cloak
            defb    %01111110       ; .XXXXXX.   the cloak
            defb    %01111110       ; .XXXXXX.   the cloak
            defb    %00111100       ; ..XXXX..   the cloak narrows
            defb    %00100100       ; ..X..X..   two feet at the hem

            end     start
