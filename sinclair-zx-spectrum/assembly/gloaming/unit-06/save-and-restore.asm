; ============================================================================
; GLOAMING — Unit 6: Save and Restore
; ============================================================================
; Unit 5 moved the lamplighter by blanking the cell he left — and we named the
; flaw out loud: that only works because the floor has no pixels. Step him onto
; anything with a shape (a lamp, soon) and the blank-erase would scrub it away.
;
; This unit fixes it properly, and it's the second half of the cell-sprite
; major. Instead of blanking, we *remember*. Before the lamplighter stands in a
; cell, we SAVE the nine bytes already there — the eight bitmap rows plus the
; one attribute — into a little buffer. When he leaves, we RESTORE them, putting
; the cell back exactly as we found it. He can now cross anything unharmed.
;
; The dance, every move:
;
;   RESTORE   put back what was under him (he's leaving this cell)
;   step      change the column
;   SAVE      grab what's under the new cell (before we cover it)
;   DRAW      draw him in the new cell
;
; On today's blank floor this looks identical to Unit 5 — he walks, no trail,
; no damage. The difference is invisible *now* and load-bearing *later*: it's
; the honest, simple preservation that a future game upgrades into true masking.
; (Remember Unit 5's "watch the assumption bite"? Try the mirror of it below.)
; ============================================================================

            org     32768

COBBLE      equ     %00000001       ; PAPER black, INK blue — dark ground
WALL        equ     %00001111       ; PAPER blue, INK white — pale stone
LAMP_ATTR   equ     %01000111       ; BRIGHT, PAPER black, INK white — the figure

ROW         equ     11
ROW_THIRD   equ     ROW / 8
ROW_CHARROW equ     ROW - ROW_THIRD * 8
ROW_SCR     equ     $4000 + ROW_THIRD * $0800 + ROW_CHARROW * 32
ROW_ATTR    equ     $5800 + ROW * 32
START_COL   equ     15

KEYS_OP     equ     $DFFE

; ============================================================================
; SETUP — runs once.
; ============================================================================
start:
            ld      a, 0            ; border black
            out     ($FE), a

            ld      hl, $5800       ; wash the grid in cobbles
            ld      de, $5801
            ld      (hl), COBBLE
            ld      bc, 767
            ldir

            ld      hl, $5800       ; wall frame — top row
            ld      b, 32
.top:
            ld      (hl), WALL
            inc     hl
            djnz    .top

            ld      hl, $5AE0       ; bottom row
            ld      b, 32
.bottom:
            ld      (hl), WALL
            inc     hl
            djnz    .bottom

            ld      hl, $5800       ; left and right columns
            ld      b, 24
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

            call    save_under      ; remember what's under his start cell
            call    draw_lamp       ; then draw him on top of it

; ============================================================================
; THE HEARTBEAT — restore, step, save, draw.
; ============================================================================
            im      1
            ei

game_loop:
            halt

            ld      bc, KEYS_OP
            in      a, (c)
            bit     1, a            ; O (left)?
            jr      z, .step_left
            bit     0, a            ; P (right)?
            jr      z, .step_right
            jr      game_loop

.step_left:
            call    restore_under   ; put the old cell back as it was
            ld      a, (lamp_col)
            dec     a
            ld      (lamp_col), a
            call    save_under      ; remember the new cell's contents
            call    draw_lamp       ; draw him over them
            jr      game_loop

.step_right:
            call    restore_under
            ld      a, (lamp_col)
            inc     a
            ld      (lamp_col), a
            call    save_under
            call    draw_lamp
            jr      game_loop

; ----------------------------------------------------------------------------
; scr_addr  — HL = screen address of his cell  (ROW_SCR + lamp_col)
; attr_addr — HL = attribute address of his cell (ROW_ATTR + lamp_col)
;   Both clobber A, DE, HL.
; ----------------------------------------------------------------------------
scr_addr:
            ld      a, (lamp_col)
            ld      e, a
            ld      d, 0
            ld      hl, ROW_SCR
            add     hl, de
            ret

attr_addr:
            ld      a, (lamp_col)
            ld      e, a
            ld      d, 0
            ld      hl, ROW_ATTR
            add     hl, de
            ret

; ----------------------------------------------------------------------------
; save_under — copy the nine bytes at his cell into the buffer.
;   8 bitmap rows -> under_lamp[0..7], attribute -> under_lamp[8].
; ----------------------------------------------------------------------------
save_under:
            call    scr_addr        ; HL = screen cell
            ld      de, under_lamp
            ld      b, 8
.su:
            ld      a, (hl)
            ld      (de), a
            inc     de
            inc     h               ; down one screen row
            djnz    .su
            call    attr_addr       ; HL = attribute cell
            ld      a, (hl)
            ld      (under_lamp + 8), a
            ret

; ----------------------------------------------------------------------------
; restore_under — write the nine saved bytes back over his cell.
; ----------------------------------------------------------------------------
restore_under:
            call    scr_addr
            ld      de, under_lamp
            ld      b, 8
.ru:
            ld      a, (de)
            ld      (hl), a
            inc     de
            inc     h
            djnz    .ru
            call    attr_addr
            ld      a, (under_lamp + 8)
            ld      (hl), a
            ret

; ----------------------------------------------------------------------------
; draw_lamp — colour his cell and stamp his shape into it.
; ----------------------------------------------------------------------------
draw_lamp:
            call    attr_addr
            ld      (hl), LAMP_ATTR
            call    scr_addr
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
; State, buffer, and shape.
; ----------------------------------------------------------------------------
lamp_col:
            defb    START_COL       ; his column

under_lamp:
            defb    0, 0, 0, 0, 0, 0, 0, 0, 0   ; 9-byte buffer: 8 pixels + 1 attribute

lamplighter:
            defb    %00111100       ; ..XXXX..   head
            defb    %00111100       ; ..XXXX..   head
            defb    %00011000       ; ...XX...   neck
            defb    %01111110       ; .XXXXXX.   arms
            defb    %00011000       ; ...XX...   body
            defb    %00011000       ; ...XX...   body
            defb    %00100100       ; ..X..X..   legs
            defb    %01000010       ; .X....X.   feet

            end     start
