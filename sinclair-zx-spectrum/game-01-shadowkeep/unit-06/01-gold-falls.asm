; ============================================================================
; SHADOWKEEP — Unit 6, Stage 1: Gold Falls
; ============================================================================
; Gold has been decoration through Unit 5. The thief walked over it; it
; stayed. This stage makes gold something the thief *takes*.
;
; Pickup is a two-byte mutation to two pieces of state, performed after the
; thief has stepped onto the gold cell:
;
;   1. The hero's `player_under_attr` is rewritten from GOLD to FLOOR — so
;      when he leaves, FLOOR is restored, not GOLD. The cell appears empty.
;
;   2. The room data table is patched at the picked-up cell — that byte
;      also becomes FLOOR — so that when the room is re-rendered (after a
;      transition there and back), the cell stays empty.
;
; Plus a one-byte counter `gold_taken` increments. It has no display yet
; (Phase 2's HUD adds that); for now it sits in RAM, ready for Stage 4 to
; use as the gate on the exit.
;
; The whole pickup pipeline is the brief's central thesis at work again:
; one attribute read decides what kind of cell it is; the type drives the
; action; the data table is the single source of truth.
; ============================================================================

WALL       equ $48
FLOOR      equ $38
GOLD       equ $70
DOOR_OPEN  equ $28
HERO_ATTR  equ $3A
STONE      equ $08

KBD_Q      equ $FBFE
KBD_A      equ $FDFE
KBD_P      equ $DFFE

HERO_START_COL equ 16
HERO_START_ROW equ 10
START_ROOM     equ 0

MOVE_INTERVAL equ 6

            org     32768

start:
            im      1
            ei
            ld      a, 0
            out     ($FE), a

            call    clear_screen

            ld      a, START_ROOM
            ld      (current_room), a
            call    draw_current_room

            xor     a
            ld      (gold_taken), a

            ld      a, HERO_START_COL
            ld      (hero_col), a
            ld      a, HERO_START_ROW
            ld      (hero_row), a
            xor     a
            ld      (move_tick), a

            call    save_under_hero
            call    draw_hero

main_loop:
            halt
            ld      a, (move_tick)
            inc     a
            ld      (move_tick), a
            cp      MOVE_INTERVAL
            jr      c, main_loop
            xor     a
            ld      (move_tick), a

            ld      bc, KBD_Q
            in      a, (c)
            bit     0, a
            jr      z, .try_up
            ld      bc, KBD_A
            in      a, (c)
            bit     0, a
            jr      z, .try_down
            ld      bc, KBD_P
            in      a, (c)
            ld      d, a
            bit     1, a
            jr      z, .try_left
            bit     0, d
            jr      z, .try_right
            jr      main_loop

.try_up:    ld      b, 0
            ld      c, $FF
            call    try_move
            jr      main_loop
.try_down:  ld      b, 0
            ld      c, 1
            call    try_move
            jr      main_loop
.try_left:  ld      b, $FF
            ld      c, 0
            call    try_move
            jr      main_loop
.try_right: ld      b, 1
            ld      c, 0
            call    try_move
            jr      main_loop

clear_screen:
            ld      hl, $4000
            ld      de, $4001
            ld      (hl), 0
            ld      bc, 6143
            ldir
            ld      hl, $5800
            ld      de, $5801
            ld      (hl), STONE
            ld      bc, 767
            ldir
            ret

draw_current_room:
            ld      a, (current_room)
            add     a, a
            ld      e, a
            ld      d, 0
            ld      hl, room_table
            add     hl, de
            ld      a, (hl)
            inc     hl
            ld      h, (hl)
            ld      l, a
            ld      (room_data_ptr), hl

            ld      hl, (room_data_ptr)
            ld      de, $5845
            ld      b, 16
.r1:        push    bc
            ld      b, 22
.c1:        ld      a, (hl)
            ld      (de), a
            inc     hl
            inc     de
            djnz    .c1
            ld      a, e
            add     a, 32 - 22
            ld      e, a
            jr      nc, .nc1
            inc     d
.nc1:       pop     bc
            djnz    .r1

            ld      hl, (room_data_ptr)
            ld      iy, bitmap_rows
            ld      b, 16
.r2:        push    bc
            ld      e, (iy+0)
            ld      d, (iy+1)
            inc     iy
            inc     iy
            ld      b, 22
.c2:        ld      a, (hl)
            cp      WALL
            jr      nz, .nw
            push    hl
            push    de
            push    bc
            ex      de, hl
            call    draw_stone
            pop     bc
            pop     de
            pop     hl
.nw:        inc     hl
            inc     de
            djnz    .c2
            pop     bc
            djnz    .r2
            ret

; ----------------------------------------------------------------------------
; try_move: walk if FLOOR/GOLD, transition if DOOR_OPEN, block otherwise.
; On a successful walk onto GOLD, mutate state to consume the gold.
; ----------------------------------------------------------------------------

try_move:
            ld      a, (hero_col)
            add     a, b
            ld      (target_col), a
            ld      a, (hero_row)
            add     a, c
            ld      (target_row), a

            ld      a, (target_col)
            ld      b, a
            ld      a, (target_row)
            ld      c, a
            call    get_attr_addr_bc
            ld      a, (hl)
            ld      (target_attr), a            ; save for later branches

            cp      DOOR_OPEN
            jr      z, .door
            cp      FLOOR
            jr      z, .walk
            cp      GOLD
            jr      z, .walk
            ret

.walk:
            call    restore_under_hero

            ld      a, (target_col)
            ld      (hero_col), a
            ld      a, (target_row)
            ld      (hero_row), a

            call    save_under_hero

            ; --- if target was GOLD, pick it up ---
            ld      a, (target_attr)
            cp      GOLD
            jr      nz, .skip_pickup

            ld      a, FLOOR
            ld      (player_under_attr), a      ; (1) under-hero now FLOOR

            ld      a, (gold_taken)
            inc     a
            ld      (gold_taken), a              ; counter ++

            call    cell_addr_in_room_data       ; HL = byte in room_data
            ld      a, FLOOR
            ld      (hl), a                      ; (2) data table now FLOOR

.skip_pickup:
            call    draw_hero
            ret

.door:
            jp      do_transition

; ----------------------------------------------------------------------------
; cell_addr_in_room_data: HL = pointer into the current room's data table
; for the cell at (target_col, target_row).
;
;   offset = (target_row - 2) * 22 + (target_col - 5)
;
; Multiplication by 22 done via repeated addition (room is at most 16 rows
; so the loop is bounded by 14 iterations).
; ----------------------------------------------------------------------------

cell_addr_in_room_data:
            ld      hl, 0
            ld      a, (target_row)
            sub     2
            or      a
            jr      z, .skip_rows
            ld      b, a
            ld      de, 22
.acc:       add     hl, de
            djnz    .acc
.skip_rows:
            ld      a, (target_col)
            sub     5
            add     a, l
            ld      l, a
            jr      nc, .nc
            inc     h
.nc:
            ld      de, (room_data_ptr)
            add     hl, de
            ret

do_transition:
            ld      a, (current_room)
            xor     1
            ld      (current_room), a

            or      a
            jr      nz, .into_antechamber

            ld      a, 25
            ld      (hero_col), a
            ld      a, 10
            ld      (hero_row), a
            jr      .render

.into_antechamber:
            ld      a, 6
            ld      (hero_col), a
            ld      a, 10
            ld      (hero_row), a

.render:
            call    clear_screen
            call    draw_current_room
            call    save_under_hero
            call    draw_hero
            ret

get_attr_addr_bc:
            ld      h, 0
            ld      a, c
            ld      l, a
            add     hl, hl
            add     hl, hl
            add     hl, hl
            add     hl, hl
            add     hl, hl
            ld      a, b
            add     a, l
            ld      l, a
            jr      nc, .ok
            inc     h
.ok:        ld      a, h
            add     a, $58
            ld      h, a
            ret

get_bitmap_addr_bc:
            ld      a, c
            sub     2
            add     a, a
            ld      e, a
            ld      d, 0
            ld      hl, bitmap_rows
            add     hl, de
            ld      a, (hl)
            inc     hl
            ld      h, (hl)
            ld      l, a
            ld      a, b
            sub     5
            add     a, l
            ld      l, a
            ret     nc
            inc     h
            ret

save_under_hero:
            ld      a, (hero_col)
            ld      b, a
            ld      a, (hero_row)
            ld      c, a
            call    get_attr_addr_bc
            ld      a, (hl)
            ld      (player_under_attr), a
            ld      a, (hero_col)
            ld      b, a
            ld      a, (hero_row)
            ld      c, a
            call    get_bitmap_addr_bc
            ld      de, player_under_bitmap
            ld      b, 8
.sl:        ld      a, (hl)
            ld      (de), a
            inc     de
            inc     h
            djnz    .sl
            ret

restore_under_hero:
            ld      a, (hero_col)
            ld      b, a
            ld      a, (hero_row)
            ld      c, a
            call    get_attr_addr_bc
            ld      a, (player_under_attr)
            ld      (hl), a
            ld      a, (hero_col)
            ld      b, a
            ld      a, (hero_row)
            ld      c, a
            call    get_bitmap_addr_bc
            ld      de, player_under_bitmap
            ld      b, 8
.rl:        ld      a, (de)
            ld      (hl), a
            inc     de
            inc     h
            djnz    .rl
            ret

draw_hero:
            ld      a, (hero_col)
            ld      b, a
            ld      a, (hero_row)
            ld      c, a
            call    get_attr_addr_bc
            ld      a, HERO_ATTR
            ld      (hl), a
            ld      a, (hero_col)
            ld      b, a
            ld      a, (hero_row)
            ld      c, a
            call    get_bitmap_addr_bc
            ld      de, hero
            ld      b, 8
.dh:        ld      a, (de)
            ld      (hl), a
            inc     de
            inc     h
            djnz    .dh
            ret

draw_stone:
            ld      de, stone_block
            ld      b, 8
.ds:        ld      a, (de)
            ld      (hl), a
            inc     de
            inc     h
            djnz    .ds
            ret

stone_block:
            defb    %11111111, %10000001, %10000001, %10000001
            defb    %10000001, %10000001, %10000001, %11111111

hero:
            defb    %00011000, %00111100, %01111110, %01111110
            defb    %11111111, %01111110, %00111100, %00100100

bitmap_rows:
            defw    $4045, $4065, $4085, $40A5, $40C5, $40E5, $4805, $4825
            defw    $4845, $4865, $4885, $48A5, $48C5, $48E5, $5005, $5025

room_table:
            defw    room_data_great_hall
            defw    room_data_antechamber

current_room:       defb 0
hero_col:           defb 0
hero_row:           defb 0
target_col:         defb 0
target_row:         defb 0
target_attr:        defb 0
move_tick:          defb 0
gold_taken:         defb 0
room_data_ptr:      defw 0
player_under_attr:  defb 0
player_under_bitmap:
            defb 0, 0, 0, 0, 0, 0, 0, 0

room_data_great_hall:
            defb    WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL
            defb    WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL
            defb    WALL, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR
            defb    GOLD, GOLD, GOLD, WALL, WALL, WALL, GOLD, GOLD, GOLD
            defb    FLOOR, FLOOR, FLOOR, FLOOR, WALL
            defb    WALL, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR
            defb    GOLD, GOLD, WALL, WALL, WALL, GOLD, GOLD
            defb    FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, WALL
            defb    WALL, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR
            defb    GOLD, WALL, GOLD, WALL, GOLD, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, WALL
            defb    WALL, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR
            defb    WALL, FLOOR, WALL, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, WALL
            rept 3
                defb    WALL, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR
                defb    FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR
                defb    FLOOR, WALL
            endm
            defb    WALL, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR
            defb    FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR
            defb    FLOOR, DOOR_OPEN
            rept 6
                defb    WALL, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR
                defb    FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR
                defb    FLOOR, WALL
            endm
            defb    WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL
            defb    WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL

room_data_antechamber:
            defb    WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL
            defb    WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL
            defb    WALL
            defb    FLOOR, FLOOR, FLOOR, GOLD
            defb    FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR
            defb    GOLD, FLOOR, FLOOR, FLOOR
            defb    WALL
            rept 2
                defb    WALL
                defb    FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR
                defb    FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR
                defb    WALL
            endm
            rept 4
                defb    WALL
                defb    FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR
                defb    WALL
                defb    FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR
                defb    WALL
                defb    FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR
                defb    WALL
            endm
            defb    DOOR_OPEN
            defb    FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR
            defb    FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR
            defb    WALL
            rept 6
                defb    WALL
                defb    FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR
                defb    FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR
                defb    WALL
            endm
            defb    WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL
            defb    WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL

            end     start
