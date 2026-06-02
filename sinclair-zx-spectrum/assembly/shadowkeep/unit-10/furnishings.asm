; ============================================================================
; SHADOWKEEP — Unit 10: Furnishings
; ============================================================================
; The keep is lit, but its rooms are bare — stone, pillars, floor. A place you
; believe in has *things* in it: a statue, banners on the walls, a scatter of
; rubble underfoot. This unit furnishes the keep, and it needs almost no new
; code — because "furniture" is just more tiles in the palette, placed in the
; map like everything else.
;
; The one idea worth naming is BLOCKING vs NON-BLOCKING. The keep already
; decides solidity by light: a BRIGHT cell is solid, a dim one is walkable. So
; furniture sorts itself:
;
;   STATUE, BANNER  — BRIGHT, so SOLID: the thief walks *around* them.
;   RUBBLE          — dim, so WALKABLE: the thief walks *over* it, and his
;                     save/restore carries it just like floor.
;
; No collision code changes at all. A statue is a wall that looks like a statue;
; rubble is a floor that looks like broken stone. Atmosphere from the palette.
; ============================================================================

            org     32768

WALL_ATTR   equ     %01001000
FLOOR_ATTR  equ     %00001000
TORCH_ATTR  equ     %01001110
STATUE_ATTR equ     %01001111       ; BRIGHT white on blue — pale stone (solid)
BANNER_ATTR equ     %01001011       ; BRIGHT magenta on blue — a hanging (solid)
RUBBLE_ATTR equ     %00001000       ; dim, like floor — walkable broken stone
MARK_ATTR   equ     %00001111
THIEF       equ     %01001010
WALL_BIT    equ     6

START_COL   equ     15
START_ROW   equ     11
NO_EXIT     equ     $FF
NO_TORCH    equ     $FF
MAX_SHADE   equ     4

KEYS_OP     equ     $DFFE
KEYS_Q      equ     $FBFE
KEYS_A      equ     $FDFE
KEYS_SPACE  equ     $7FFE

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
            ld      hl, room2_template
            ld      de, room2_state
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

mark_step:
            ld      bc, KEYS_SPACE
            in      a, (c)
            bit     0, a
            ret     nz
            call    cell_state_addr
            ld      (hl), '+'
            ld      hl, mark_tile
            ld      de, under_thief
            ld      bc, 8
            ldir
            ld      a, MARK_ATTR
            ld      (under_thief + 8), a
            ret

cell_state_addr:
            call    room_entry_addr
            ld      a, (hl)
            inc     hl
            ld      h, (hl)
            ld      l, a
            push    hl
            ld      a, (thief_row)
            ld      l, a
            ld      h, 0
            add     hl, hl
            add     hl, hl
            add     hl, hl
            add     hl, hl
            add     hl, hl
            ld      a, (thief_col)
            ld      e, a
            ld      d, 0
            add     hl, de
            pop     de
            add     hl, de
            ret

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

find_torch:
            ld      a, NO_TORCH
            ld      (torch_col), a
            ld      (torch_row), a
            call    room_entry_addr
            ld      a, (hl)
            inc     hl
            ld      h, (hl)
            ld      l, a
            ld      b, 0
.ft_row:
            ld      c, 0
.ft_col:
            ld      a, (hl)
            cp      'T'
            jr      nz, .ft_skip
            ld      a, c
            ld      (torch_col), a
            ld      a, b
            ld      (torch_row), a
.ft_skip:
            inc     hl
            inc     c
            ld      a, c
            cp      32
            jr      nz, .ft_col
            inc     b
            ld      a, b
            cp      24
            jr      nz, .ft_row
            ret

shade_for_cell:
            ld      a, (torch_col)
            cp      NO_TORCH
            jr      z, .sf_dark
            ld      a, b
            ld      hl, torch_row
            sub     (hl)
            jr      nc, .sf_rpos
            neg
.sf_rpos:
            ld      d, a
            ld      a, c
            ld      hl, torch_col
            sub     (hl)
            jr      nc, .sf_cpos
            neg
.sf_cpos:
            cp      d
            jr      nc, .sf_max
            ld      a, d
.sf_max:
            srl     a
            cp      MAX_SHADE + 1
            jr      c, .sf_done
            ld      a, MAX_SHADE
.sf_done:
            ret
.sf_dark:
            ld      a, MAX_SHADE
            ret

draw_room:
            call    find_torch
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
            cp      '.'
            jr      nz, .not_floor
            call    shade_for_cell
            add     a, a
            ld      e, a
            ld      d, 0
            ld      hl, shade_tiles
            add     hl, de
            ld      e, (hl)
            inc     hl
            ld      d, (hl)
            ld      (tile_ptr), de
            ld      a, FLOOR_ATTR
            ld      (tile_attr), a
            call    draw_tile
            jr      .cell_done
.not_floor:
            call    lookup_tile
            call    draw_tile
.cell_done:
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
; Palette — now furnished. 'S' statue and 'B' banner are bright (solid); 'o'
; rubble is dim (walkable). '.' is still handled by the lighting path.
; ----------------------------------------------------------------------------
palette:
            defb    '.'
            defw    shade2_tile
            defb    FLOOR_ATTR
            defb    '#'
            defw    wall_tile
            defb    WALL_ATTR
            defb    'T'
            defw    torch_tile
            defb    TORCH_ATTR
            defb    'S'
            defw    statue_tile
            defb    STATUE_ATTR
            defb    'B'
            defw    banner_tile
            defb    BANNER_ATTR
            defb    'o'
            defw    rubble_tile
            defb    RUBBLE_ATTR
            defb    '+'
            defw    mark_tile
            defb    MARK_ATTR

shade_tiles:
            defw    shade0_tile
            defw    shade1_tile
            defw    shade2_tile
            defw    shade3_tile
            defw    shade4_tile

rooms:
            defw    room0_state
            defb    NO_EXIT, NO_EXIT, 1, NO_EXIT
            defw    room1_state
            defb    2, NO_EXIT, NO_EXIT, 0
            defw    room2_state
            defb    NO_EXIT, 1, NO_EXIT, NO_EXIT

; The Great Hall — torch above, banners flanking a statue, rubble at its feet.
room0_template:
            defb    "###############T################"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "B..............S...............B"
            defb    "#.............ooo..............#"
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

; The Gallery — a banner on the west wall, a heap of rubble in the corner.
room1_template:
            defb    "###############.################"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "###############.################"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "...............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "B..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#........................ooo...#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "###############T################"

; The Vault — banners flanking the great altar.
room2_template:
            defb    "###############T################"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#.............####.............#"
            defb    "B.............####.............#"
            defb    "#.............####.............B"
            defb    "#.............####.............#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "###############.################"

; ----------------------------------------------------------------------------
; Floor shade ramp.
; ----------------------------------------------------------------------------
shade0_tile:
            defb    %00000000
            defb    %00100010
            defb    %00000000
            defb    %00000000
            defb    %00000000
            defb    %10001000
            defb    %00000000
            defb    %00000000
shade1_tile:
            defb    %00100010
            defb    %00000000
            defb    %10001000
            defb    %00000000
            defb    %00100010
            defb    %00000000
            defb    %10001000
            defb    %00000000
shade2_tile:
            defb    %10101010
            defb    %01010101
            defb    %10101010
            defb    %01010101
            defb    %10101010
            defb    %01010101
            defb    %10101010
            defb    %01010101
shade3_tile:
            defb    %10101010
            defb    %11111111
            defb    %01010101
            defb    %11111111
            defb    %10101010
            defb    %11111111
            defb    %01010101
            defb    %11111111
shade4_tile:
            defb    %11111111
            defb    %11101110
            defb    %11111111
            defb    %10111011
            defb    %11111111
            defb    %11101110
            defb    %11111111
            defb    %10111011

wall_tile:
            defb    %00010001
            defb    %00000000
            defb    %01000100
            defb    %00000000
            defb    %00010001
            defb    %00000000
            defb    %01000100
            defb    %00000000

torch_tile:
            defb    %00010000
            defb    %00111000
            defb    %00111000
            defb    %01111100
            defb    %01111100
            defb    %01111100
            defb    %00111000
            defb    %00010000

statue_tile:
            defb    %00111100
            defb    %01111110
            defb    %00111100
            defb    %00011000
            defb    %00011000
            defb    %00111100
            defb    %01111110
            defb    %01111110

banner_tile:
            defb    %01111110
            defb    %01111110
            defb    %01011010
            defb    %01011010
            defb    %01111110
            defb    %01111110
            defb    %00111100
            defb    %00011000

rubble_tile:
            defb    %00000000
            defb    %01100000
            defb    %01100000
            defb    %00000110
            defb    %00000110
            defb    %00011000
            defb    %00011000
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

current_room:
            defb    0
torch_col:
            defb    NO_TORCH
torch_row:
            defb    NO_TORCH
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
room2_state:
            defs    768

            end     start
