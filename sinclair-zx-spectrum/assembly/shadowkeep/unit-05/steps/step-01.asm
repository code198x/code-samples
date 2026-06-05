; Shadowkeep — Unit 5: The Room Graph
; Cumulative build; every step runs on its own. Narrative: the unit page.
; step-01 gives the keep a graph of rooms — walk a doorway, flick to the next.

            org     32768

WALL_ATTR   equ     %01001000
FLOOR_ATTR  equ     %00001000
THIEF       equ     %01001010
WALL_BIT    equ     6

START_COL   equ     15
START_ROW   equ     11
NO_EXIT     equ     $FF

KEYS_OP     equ     $DFFE
KEYS_Q      equ     $FBFE
KEYS_A      equ     $FDFE

; ----------------------------------------------------------------------------
; SETUP.
; ----------------------------------------------------------------------------
start:
            ld      a, 0
            out     ($FE), a

            xor     a
            ld      (current_room), a
            ld      a, START_COL
            ld      (thief_col), a
            ld      a, START_ROW
            ld      (thief_row), a

            call    draw_room
            call    save_under
            call    draw_thief

            im      1
            ei
.loop:
            halt
            call    player_step
            jr      .loop

; ----------------------------------------------------------------------------
; room_entry_addr — HL = rooms + current_room * 6 (entry = map ptr + 4 links).
; ----------------------------------------------------------------------------
room_entry_addr:
            ld      a, (current_room)
            ld      l, a
            ld      h, 0
            ld      d, h
            ld      e, l            ; DE = room number
            add     hl, hl          ; *2
            add     hl, de          ; *3
            add     hl, hl          ; *6
            ld      de, rooms
            add     hl, de
            ret

; ----------------------------------------------------------------------------
; draw_room — draw the current room's map. Same walk as Unit 4, but the map
; pointer comes from the room table now, not a fixed label.
; ----------------------------------------------------------------------------
draw_room:
            call    room_entry_addr
            ld      a, (hl)         ; map pointer, low
            inc     hl
            ld      h, (hl)         ; map pointer, high
            ld      l, a
            ld      (map_ptr), hl
            ld      b, 0
.room_row:
            ld      c, 0
.room_col:
            ld      hl, (map_ptr)
            ld      a, (hl)
            call    lookup_tile
            call    draw_tile
            ld      hl, (map_ptr)
            inc     hl
            ld      (map_ptr), hl
            inc     c
            ld      a, c
            cp      32
            jr      nz, .room_col
            inc     b
            ld      a, b
            cp      24
            jr      nz, .room_row
            ret

lookup_tile:
            ld      hl, palette
.scan:
            cp      (hl)
            jr      z, .found
            inc     hl
            inc     hl
            inc     hl
            inc     hl
            jr      .scan
.found:
            inc     hl
            ld      e, (hl)
            inc     hl
            ld      d, (hl)
            ld      (tile_ptr), de
            inc     hl
            ld      a, (hl)
            ld      (tile_attr), a
            ret

draw_tile:
            push    bc
            call    attr_addr_cr
            ld      a, (tile_attr)
            ld      (hl), a
            call    scr_addr_cr
            ld      de, (tile_ptr)
            ld      b, 8
.tile_row:
            ld      a, (de)
            ld      (hl), a
            inc     de
            inc     h
            djnz    .tile_row
            pop     bc
            ret

; ----------------------------------------------------------------------------
; player_step — move as before, then check whether he stepped onto a doorway.
; ----------------------------------------------------------------------------
player_step:
            ld      a, (thief_col)
            ld      (tcol), a
            ld      a, (thief_row)
            ld      (trow), a

            ld      bc, KEYS_OP
            in      a, (c)
            bit     1, a
            jr      z, .left
            bit     0, a
            jr      z, .right
            ld      bc, KEYS_Q
            in      a, (c)
            bit     0, a
            jr      z, .up
            ld      bc, KEYS_A
            in      a, (c)
            bit     0, a
            jr      z, .down
            ret
.left:
            ld      hl, tcol
            dec     (hl)
            jr      .move
.right:
            ld      hl, tcol
            inc     (hl)
            jr      .move
.up:
            ld      hl, trow
            dec     (hl)
            jr      .move
.down:
            ld      hl, trow
            inc     (hl)
.move:
            ld      a, (trow)
            ld      b, a
            ld      a, (tcol)
            ld      c, a
            call    wall_at
            ret     nz

            call    restore_under
            ld      a, (tcol)
            ld      (thief_col), a
            ld      a, (trow)
            ld      (thief_row), a
            call    save_under
            call    draw_thief
            call    check_exit
            ret

wall_at:
            call    attr_addr_cr
            bit     WALL_BIT, (hl)
            ret

; ----------------------------------------------------------------------------
; check_exit — if the thief is standing on an edge, follow that edge's link in
; the room table and travel there.
; ----------------------------------------------------------------------------
check_exit:
            ld      a, (thief_col)
            or      a
            jr      z, .west        ; column 0
            cp      31
            jr      z, .east        ; column 31
            ld      a, (thief_row)
            or      a
            jr      z, .north       ; row 0
            cp      23
            jr      z, .south       ; row 23
            ret                     ; not on an edge
.north:
            call    room_entry_addr
            inc     hl
            inc     hl              ; +2 = North link
            ld      a, (hl)
            jr      .travel
.south:
            call    room_entry_addr
            inc     hl
            inc     hl
            inc     hl              ; +3 = South link
            ld      a, (hl)
            jr      .travel
.east:
            call    room_entry_addr
            ld      de, 4           ; +4 = East link
            add     hl, de
            ld      a, (hl)
            jr      .travel
.west:
            call    room_entry_addr
            ld      de, 5           ; +5 = West link
            add     hl, de
            ld      a, (hl)
.travel:
            cp      NO_EXIT
            ret     z               ; a doorway to nowhere — stay
            ld      (current_room), a
            call    draw_room
            ld      a, START_COL    ; crude: drop him in the centre (Unit 6 fixes this)
            ld      (thief_col), a
            ld      a, START_ROW
            ld      (thief_row), a
            call    save_under
            call    draw_thief
            ret

; ----------------------------------------------------------------------------
; Save / restore / draw the thief — unchanged.
; ----------------------------------------------------------------------------
pos_bc:
            ld      a, (thief_row)
            ld      b, a
            ld      a, (thief_col)
            ld      c, a
            ret

save_under:
            call    pos_bc
            call    scr_addr_cr
            ld      de, under_thief
            ld      b, 8
.save_row:
            ld      a, (hl)
            ld      (de), a
            inc     de
            inc     h
            djnz    .save_row
            call    pos_bc
            call    attr_addr_cr
            ld      a, (hl)
            ld      (under_thief + 8), a
            ret

restore_under:
            call    pos_bc
            call    scr_addr_cr
            ld      de, under_thief
            ld      b, 8
.restore_row:
            ld      a, (de)
            ld      (hl), a
            inc     de
            inc     h
            djnz    .restore_row
            call    pos_bc
            call    attr_addr_cr
            ld      a, (under_thief + 8)
            ld      (hl), a
            ret

draw_thief:
            call    pos_bc
            call    attr_addr_cr
            ld      (hl), THIEF
            call    pos_bc
            call    scr_addr_cr
            ld      de, thief
            ld      b, 8
.thief_row:
            ld      a, (de)
            ld      (hl), a
            inc     de
            inc     h
            djnz    .thief_row
            ret

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
; Palette.
; ----------------------------------------------------------------------------
palette:
            defb    '.'
            defw    floor_tile
            defb    FLOOR_ATTR
            defb    '#'
            defw    wall_tile
            defb    WALL_ATTR

; ----------------------------------------------------------------------------
; The room graph. Each entry: map pointer, then North, South, East, West links
; ($FF = no door). Two rooms, joined east-west: room 0's east door leads to
; room 1, room 1's west door leads back.
; ----------------------------------------------------------------------------
rooms:
            defw    room0_data
            defb    NO_EXIT, NO_EXIT, 1, NO_EXIT
            defw    room1_data
            defb    NO_EXIT, NO_EXIT, NO_EXIT, 0

; Room 0 — the pillared hall, with a doorway in the east wall (row 11).
room0_data:
            defb    "################################"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#........##..........##........#"
            defb    "#........##..........##........#"
            defb    "#..............................#"
            defb    "#..............................."
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#........##..........##........#"
            defb    "#........##..........##........#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "################################"

; Room 1 — a plainer chamber with a block near the top, doorway in the west
; wall (row 11) leading back to room 0.
room1_data:
            defb    "################################"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............##..............#"
            defb    "#..............##..............#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "...............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "################################"

; ----------------------------------------------------------------------------
; Tiles and the thief.
; ----------------------------------------------------------------------------
floor_tile:
            defb    %10101010
            defb    %01010101
            defb    %10101010
            defb    %01010101
            defb    %10101010
            defb    %01010101
            defb    %10101010
            defb    %01010101

wall_tile:
            defb    %00010001
            defb    %00000000
            defb    %01000100
            defb    %00000000
            defb    %00010001
            defb    %00000000
            defb    %01000100
            defb    %00000000

thief:
            defb    %00011000
            defb    %00111100
            defb    %01111110
            defb    %01111110
            defb    %01111110
            defb    %01111110
            defb    %00111100
            defb    %00100100

; ----------------------------------------------------------------------------
; Variables.
; ----------------------------------------------------------------------------
current_room:
            defb    0
thief_col:
            defb    START_COL
thief_row:
            defb    START_ROW
tcol:
            defb    0
trow:
            defb    0
map_ptr:
            defw    0
tile_ptr:
            defw    0
tile_attr:
            defb    0
under_thief:
            defb    0, 0, 0, 0, 0, 0, 0, 0, 0

            end     start
