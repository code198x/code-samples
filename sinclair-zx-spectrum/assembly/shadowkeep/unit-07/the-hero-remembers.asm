; ============================================================================
; SHADOWKEEP — Unit 7: The Hero Remembers
; ============================================================================
; The thief can step between rooms, but the keep has no memory: each room is
; drawn from its fixed template every time he enters, so nothing he does to a
; room can last. This unit gives the keep a memory.
;
; The trick is to stop treating the maps as read-only. At start-up we COPY each
; room's template into a RAM buffer — its "state" — and from then on the keep
; lives in those buffers, not in the templates. draw_room paints from the state;
; anything we write into the state persists, because the state is never thrown
; away.
;
; To make that visible, the thief maps the keep the old way: hold SPACE and he
; chalks a mark on the floor as he goes. Each mark is written into the room's
; state buffer, so when you leave a room and come back, your trail is exactly
; where you left it. The keep remembers.
;
; (Two rooms, two 768-byte buffers — fine here. It doesn't scale to a hundred
; rooms; a later game packs state far tighter. Honest version first.)
; ============================================================================

            org     32768

WALL_ATTR   equ     %01001000
FLOOR_ATTR  equ     %00001000
MARK_ATTR   equ     %00001111       ; dim, PAPER 1 (blue), INK 7 (white) — chalk, walkable
THIEF       equ     %01001010
WALL_BIT    equ     6

START_COL   equ     15
START_ROW   equ     11
NO_EXIT     equ     $FF

KEYS_OP     equ     $DFFE
KEYS_Q      equ     $FBFE
KEYS_A      equ     $FDFE
KEYS_SPACE  equ     $7FFE

; ----------------------------------------------------------------------------
; SETUP — copy the room templates into their RAM state buffers, then run.
; ----------------------------------------------------------------------------
start:
            ld      a, 0
            out     ($FE), a

            ld      hl, room0_template
            ld      de, room0_state
            ld      bc, 768
            ldir
            ld      hl, room1_template
            ld      de, room1_state
            ld      bc, 768
            ldir

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
            call    mark_step
            jr      .loop

; ----------------------------------------------------------------------------
; mark_step — while SPACE is held, chalk the cell the thief is on: write the
; mark glyph into the room's state buffer (so it persists and redraws), and
; set what's "under" him to the mark, so it shows the moment he steps off.
; ----------------------------------------------------------------------------
mark_step:
            ld      bc, KEYS_SPACE
            in      a, (c)
            bit     0, a
            ret     nz              ; SPACE not held

            call    cell_state_addr ; HL -> this cell in the state buffer
            ld      (hl), '+'

            ld      hl, mark_tile   ; remember the mark as what's under him
            ld      de, under_thief
            ld      bc, 8
            ldir
            ld      a, MARK_ATTR
            ld      (under_thief + 8), a
            ret

; cell_state_addr — HL = current room's state buffer + thief_row*32 + thief_col.
cell_state_addr:
            call    room_entry_addr
            ld      a, (hl)         ; state buffer pointer (low)
            inc     hl
            ld      h, (hl)
            ld      l, a            ; HL = state base
            push    hl
            ld      a, (thief_row)
            ld      l, a
            ld      h, 0
            add     hl, hl
            add     hl, hl
            add     hl, hl
            add     hl, hl
            add     hl, hl          ; HL = row * 32
            ld      a, (thief_col)
            ld      e, a
            ld      d, 0
            add     hl, de          ; + col
            pop     de
            add     hl, de          ; + base
            ret

; ----------------------------------------------------------------------------
; room_entry_addr / draw_room — draw_room now paints from the state buffer the
; room table points at.
; ----------------------------------------------------------------------------
room_entry_addr:
            ld      a, (current_room)
            ld      l, a
            ld      h, 0
            ld      d, h
            ld      e, l
            add     hl, hl
            add     hl, de
            add     hl, hl
            ld      de, rooms
            add     hl, de
            ret

draw_room:
            call    room_entry_addr
            ld      a, (hl)
            inc     hl
            ld      h, (hl)
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
; player_step / wall_at / check_exit — unchanged from Unit 6.
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

check_exit:
            ld      a, (thief_col)
            or      a
            jr      z, .west
            cp      31
            jr      z, .east
            ld      a, (thief_row)
            or      a
            jr      z, .north
            cp      23
            jr      z, .south
            ret
.east:
            call    room_entry_addr
            ld      de, 4
            add     hl, de
            ld      a, (hl)
            cp      NO_EXIT
            ret     z
            ld      (current_room), a
            ld      a, 1
            ld      (thief_col), a
            jr      .enter
.west:
            call    room_entry_addr
            ld      de, 5
            add     hl, de
            ld      a, (hl)
            cp      NO_EXIT
            ret     z
            ld      (current_room), a
            ld      a, 30
            ld      (thief_col), a
            jr      .enter
.north:
            call    room_entry_addr
            inc     hl
            inc     hl
            ld      a, (hl)
            cp      NO_EXIT
            ret     z
            ld      (current_room), a
            ld      a, 22
            ld      (thief_row), a
            jr      .enter
.south:
            call    room_entry_addr
            inc     hl
            inc     hl
            inc     hl
            ld      a, (hl)
            cp      NO_EXIT
            ret     z
            ld      (current_room), a
            ld      a, 1
            ld      (thief_row), a
.enter:
            call    draw_room
            call    save_under
            call    draw_thief
            ret

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
; Palette — now with a chalk mark. The mark is dim, so it stays walkable.
; ----------------------------------------------------------------------------
palette:
            defb    '.'
            defw    floor_tile
            defb    FLOOR_ATTR
            defb    '#'
            defw    wall_tile
            defb    WALL_ATTR
            defb    '+'
            defw    mark_tile
            defb    MARK_ATTR

; ----------------------------------------------------------------------------
; The room graph — pointers now name the RAM STATE buffers, not the templates.
; ----------------------------------------------------------------------------
rooms:
            defw    room0_state
            defb    NO_EXIT, NO_EXIT, 1, NO_EXIT
            defw    room1_state
            defb    NO_EXIT, NO_EXIT, NO_EXIT, 0

room0_template:
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

room1_template:
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

mark_tile:
            defb    %00000000
            defb    %00011000
            defb    %00011000
            defb    %01111110
            defb    %01111110
            defb    %00011000
            defb    %00011000
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
; Variables, then the room state buffers (RAM copies of the templates).
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

room0_state:
            defs    768
room1_state:
            defs    768

            end     start
