; Gloaming — Unit 13: The Tally
; Cumulative build; every step runs on its own. Narrative: the unit page.
; Progress as coloured pips — no digits.

            org     32768

COBBLE      equ     %00000001       ; PAPER black (0), INK blue (1) — dark ground
WALL        equ     %00001111       ; PAPER blue (1), INK white (7) — pale stone
WALL_BIT    equ     3               ; the attribute bit that says "this is wall"
LAMP_ATTR   equ     %01000111       ; BRIGHT, PAPER black, INK white — his own light
LAMP_UNLIT  equ     %00000101       ; cold cyan INK on black PAPER — bit 3
                                    ; clear, so a lamp reads as floor
LAMP_LIT    equ     %01000110       ; BRIGHT yellow INK on black — a held flame

PIP_UNLIT   equ     %00101000       ; a cold pip: cyan PAPER, a solid block
PIP_LIT     equ     %01110000       ; a warm pip: BRIGHT yellow PAPER
PIP_BASE    equ     $5800 + 12      ; row 0, column 12 — the HUD ledge,
                                    ; eight cells, centred over the square
NUM_LAMPS   equ     8

START_COL   equ     15              ; where the lamplighter begins
START_ROW   equ     11
PLAYER_REPEAT equ   6               ; frames between steps while a key is held

KEYS_OP     equ     $DFFE           ; half-row P O I U Y — bits 1 and 0
KEYS_Q      equ     $FBFE           ; half-row Q W E R T — bit 0 is Q
KEYS_A      equ     $FDFE           ; half-row A S D F G — bit 0 is A

start:
            ; --- the border goes black — the night beyond the square ---
            ; Port $FE bits 0-2 set the BORDER colour. A = 0 = black.
            ld      a, 0
            out     ($FE), a

            ; --- place the lamplighter ---
            ; His position is data. Everything that draws him reads it.
            ld      a, START_COL
            ld      (lamp_col), a
            ld      a, START_ROW
            ld      (lamp_row), a
            xor     a
            ld      (player_timer), a

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

            call    paint_walls
            call    paint_buildings

            ; --- brick the walls ---
            ; Now that the wall cells are painted, fill_walls can read the
            ; map back and lay brick wherever the wall bit is set.
            call    fill_walls
            call    draw_pips
            call    draw_lamps
            ; save what he is about to stand on, BEFORE the first draw
            call    save_under
            call    draw_lamp

            ; --- start the heartbeat ---
            ; IM 1: every 50 Hz frame interrupt calls the ROM's handler.
            ; EI: let it. HALT then sleeps until the next frame arrives,
            ; so the loop below beats exactly once per frame.
            im      1
            ei

main_loop:
            halt
            call    play_step
            jr      main_loop

; play_step — one beat of the game: ask the keyboard.
play_step:
            call    player_step
            ret

; ----------------------------------------------------------------------------
; paint_walls — the square's edge, one attribute write per cell.
; ----------------------------------------------------------------------------
paint_walls:
            ld      c, WALL         ; the byte every wall cell gets

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

; ----------------------------------------------------------------------------
; draw_pips — the tally row: one cell per lamp on the HUD ledge, all
; cold to start. A pip is pure attribute — no glyph, just a block of
; PAPER — so the row costs eight bytes of screen and no bitmap at all.
; ----------------------------------------------------------------------------
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
; Data.
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
player_timer:
            defb    0

under_lamp:
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

            end     start
