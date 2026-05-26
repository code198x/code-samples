; ============================================================================
; SHADOWKEEP — Unit 5, Stage 2: A Second Room
; ============================================================================
; The render code in Stages 1–4 cares only that it's pointed at 352 bytes
; of room data. It doesn't know whether those bytes describe the great hall
; or anything else. This stage exploits that.
;
; A second `room_data_antechamber` table sits next to `room_data_great_hall`
; in memory. A two-entry pointer table (`room_table`) maps a one-byte room
; index to the right starting address. A single state byte, `current_room`,
; selects which entry of the table to use.
;
; At boot we set `current_room = 1` and render the antechamber to prove the
; mechanism works. Stage 3 will give both rooms a door and let the thief
; cross between them, but the engine — generalisation from one room to N —
; lands here.
; ============================================================================

WALL       equ $48
FLOOR      equ $38
GOLD       equ $70
HERO_ATTR  equ $3A
STONE      equ $08

KBD_Q      equ $FBFE
KBD_A      equ $FDFE
KBD_P      equ $DFFE

HERO_START_COL equ 16
HERO_START_ROW equ 10
START_ROOM     equ 1                            ; 0 = great hall, 1 = antechamber

MOVE_INTERVAL equ 6

            org     32768

start:
            im      1
            ei
            ld      a, 0
            out     ($FE), a

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

            ld      a, START_ROOM
            ld      (current_room), a

            call    draw_current_room

            ld      a, HERO_START_COL
            ld      (hero_col), a
            ld      a, HERO_START_ROW
            ld      (hero_row), a
            xor     a
            ld      (move_tick), a

            call    save_under_hero
            call    draw_hero

; ----------------------------------------------------------------------------
; Main loop (unchanged from Stage 1).
; ----------------------------------------------------------------------------

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

; ----------------------------------------------------------------------------
; draw_current_room: render the room selected by `current_room`. Walks the
; pointer table, then runs the attribute pass and the stone-bitmap pass.
; ----------------------------------------------------------------------------

draw_current_room:
            ; Look up the current room's data pointer
            ld      a, (current_room)
            add     a, a
            ld      e, a
            ld      d, 0
            ld      hl, room_table
            add     hl, de
            ld      a, (hl)
            inc     hl
            ld      h, (hl)
            ld      l, a                       ; HL = room_data_X
            ld      (room_data_ptr), hl

            ; Attribute pass
            ld      hl, (room_data_ptr)
            ld      de, $5845
            ld      b, 16
.row_loop:
            push    bc
            ld      b, 22
.col_loop:
            ld      a, (hl)
            ld      (de), a
            inc     hl
            inc     de
            djnz    .col_loop
            ld      a, e
            add     a, 32 - 22
            ld      e, a
            jr      nc, .no_carry
            inc     d
.no_carry:
            pop     bc
            djnz    .row_loop

            ; Stone-bitmap pass
            ld      hl, (room_data_ptr)
            ld      iy, bitmap_rows
            ld      b, 16
.row_loop2:
            push    bc
            ld      e, (iy+0)
            ld      d, (iy+1)
            inc     iy
            inc     iy
            ld      b, 22
.col_loop2:
            ld      a, (hl)
            cp      WALL
            jr      nz, .not_wall
            push    hl
            push    de
            push    bc
            ex      de, hl
            call    draw_stone
            pop     bc
            pop     de
            pop     hl
.not_wall:
            inc     hl
            inc     de
            djnz    .col_loop2
            pop     bc
            djnz    .row_loop2
            ret

; ----------------------------------------------------------------------------
; try_move and helpers (unchanged from Stage 1)
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
.ok:
            ld      a, h
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
.sl:         ld      a, (hl)
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
.rl:         ld      a, (de)
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
.dh:         ld      a, (de)
            ld      (hl), a
            inc     de
            inc     h
            djnz    .dh
            ret

draw_stone:
            ld      de, stone_block
            ld      b, 8
.ds:         ld      a, (de)
            ld      (hl), a
            inc     de
            inc     h
            djnz    .ds
            ret

; ----------------------------------------------------------------------------
; Static data
; ----------------------------------------------------------------------------

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

; ----------------------------------------------------------------------------
; Mutable state
; ----------------------------------------------------------------------------

current_room:       defb 0
hero_col:           defb 0
hero_row:           defb 0
target_col:         defb 0
target_row:         defb 0
move_tick:          defb 0
room_data_ptr:      defw 0
player_under_attr:  defb 0
player_under_bitmap:
            defb 0, 0, 0, 0, 0, 0, 0, 0

; ----------------------------------------------------------------------------
; Room 0: The Great Hall (as Unit 4)
; ----------------------------------------------------------------------------

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
            rept 10
                defb    WALL, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR
                defb    FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR
                defb    FLOOR, WALL
            endm
            defb    WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL
            defb    WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL

; ----------------------------------------------------------------------------
; Room 1: The Antechamber — narrower, with two short pillars and gold
;                            tucked near the top corners.
; ----------------------------------------------------------------------------

room_data_antechamber:
            ; Row 0 — top wall
            defb    WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL
            defb    WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL
            ; Row 1 — gold tucked near corners
            defb    WALL
            defb    FLOOR, FLOOR, FLOOR, GOLD
            defb    FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR
            defb    GOLD, FLOOR, FLOOR, FLOOR
            defb    WALL
            ; Rows 2-3 — open
            rept 2
                defb    WALL
                defb    FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR
                defb    FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR
                defb    WALL
            endm
            ; Rows 4-7 — two single-cell pillars at cols 7 and 14
            rept 4
                defb    WALL
                defb    FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR
                defb    WALL
                defb    FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR
                defb    WALL
                defb    FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR
                defb    WALL
            endm
            ; Rows 8-14 — open chamber
            rept 7
                defb    WALL
                defb    FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR
                defb    FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR
                defb    WALL
            endm
            ; Row 15 — bottom wall
            defb    WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL
            defb    WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL

            end     start
