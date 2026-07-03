; Gloaming — Unit 5: Reading the Keys
; Cumulative build; every step runs on its own. Narrative: the unit page.
; Port $FE, one half-row at a time — the lamplighter glows while a key is down.

            org     32768

COBBLE      equ     %00000001       ; PAPER black (0), INK blue (1) — dark ground
WALL        equ     %00001111       ; PAPER blue (1), INK white (7) — pale stone
WALL_BIT    equ     3               ; the attribute bit that says "this is wall"
LAMP_ATTR   equ     %01000111       ; BRIGHT, PAPER black, INK white — his own light
LAMP_GLOW   equ     %01000110       ; his warmth while a key is down (this unit only)

START_COL   equ     15              ; where the lamplighter begins
START_ROW   equ     11

KEYS_OP     equ     $DFFE           ; half-row P O I U Y — bit 1 is O

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

            ; --- brick the walls ---
            ; Now that the wall cells are painted, fill_walls can read the
            ; map back and lay brick wherever the wall bit is set.
            call    fill_walls
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
; player_step — scan the keyboard. Reading port $FE with a half-row
; address in B selects five keys; a key held pulls its bit LOW. While
; O is down, the lamplighter glows — proof the machine can feel you.
; ----------------------------------------------------------------------------
player_step:
            ld      bc, KEYS_OP
            in      a, (c)
            bit     1, a            ; O — a zero bit is a pressed key
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

; ----------------------------------------------------------------------------
; The lamplighter's draw.
; ----------------------------------------------------------------------------

; pos_bc — the lamplighter's cell into (C, B), read fresh from the data.
pos_bc:
            ld      a, (lamp_row)
            ld      b, a
            ld      a, (lamp_col)
            ld      c, a
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
