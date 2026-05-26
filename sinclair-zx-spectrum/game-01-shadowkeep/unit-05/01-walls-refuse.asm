; ============================================================================
; SHADOWKEEP — Unit 5, Stage 1: Walls Refuse
; ============================================================================
; Unit 4 kept the thief in the room with a numeric bounds check — "don't
; let his column go past 25." That works for one room. It doesn't work the
; moment we have walls that aren't on the perimeter (the altar) or floors
; that look like walls but aren't (doors will, soon).
;
; This stage replaces the numeric bounds with the rule Shadowkeep was
; designed around: **every game rule is a bit-test on the attribute byte
; of the cell in question**. Before each step we read the attribute of the
; *target* cell. If it's FLOOR or GOLD, the thief walks in. If it's WALL
; or the dark stone outside the room, he doesn't. The altar's wall cells
; — same `WALL` attribute as the perimeter — now correctly stop him.
;
; The mechanic is one `IN` instruction (well, one `LD A, (HL)`) and three
; `CP` comparisons. From it the whole rule set of the keep is built.
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

            ld      hl, room_data
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

            ld      hl, room_data
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

            ld      a, HERO_START_COL
            ld      (hero_col), a
            ld      a, HERO_START_ROW
            ld      (hero_row), a
            xor     a
            ld      (move_tick), a

            call    save_under_hero
            call    draw_hero

; ----------------------------------------------------------------------------
; Main loop: rate-limited polling, attribute-based collision.
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

.try_up:
            ld      b, 0
            ld      c, $FF                     ; drow = -1
            call    try_move
            jr      main_loop

.try_down:
            ld      b, 0
            ld      c, 1
            call    try_move
            jr      main_loop

.try_left:
            ld      b, $FF                     ; dcol = -1
            ld      c, 0
            call    try_move
            jr      main_loop

.try_right:
            ld      b, 1
            ld      c, 0
            call    try_move
            jr      main_loop

; ----------------------------------------------------------------------------
; try_move: take a (dcol=B, drow=C) delta. Read the target cell's attribute;
; if walkable, perform the full restore → update → save → draw cycle.
; If blocked, return without changing anything.
; ----------------------------------------------------------------------------

try_move:
            ld      a, (hero_col)
            add     a, b
            ld      (target_col), a
            ld      a, (hero_row)
            add     a, c
            ld      (target_row), a

            ; Read attribute at (target_col, target_row)
            ld      a, (target_col)
            ld      b, a
            ld      a, (target_row)
            ld      c, a
            call    get_attr_addr_bc           ; HL = $5800 + row*32 + col
            ld      a, (hl)                    ; A = target attribute

            ; Is it walkable?
            cp      FLOOR
            jr      z, .walk
            cp      GOLD
            jr      z, .walk
            ret                                ; anything else blocks

.walk:
            call    restore_under_hero

            ld      a, (target_col)
            ld      (hero_col), a
            ld      a, (target_row)
            ld      (hero_row), a

            call    save_under_hero
            call    draw_hero
            ret

; ----------------------------------------------------------------------------
; get_attr_addr_bc: attribute address for (col=B, row=C) → HL
; ----------------------------------------------------------------------------

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

; ----------------------------------------------------------------------------
; get_bitmap_addr_bc: bitmap address for (col=B, row=C) → HL
; ----------------------------------------------------------------------------

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

; ----------------------------------------------------------------------------
; save_under_hero / restore_under_hero / draw_hero — operate on (hero_col, hero_row)
; ----------------------------------------------------------------------------

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
.save_loop:
            ld      a, (hl)
            ld      (de), a
            inc     de
            inc     h
            djnz    .save_loop
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
.restore_loop:
            ld      a, (de)
            ld      (hl), a
            inc     de
            inc     h
            djnz    .restore_loop
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
.draw_loop:
            ld      a, (de)
            ld      (hl), a
            inc     de
            inc     h
            djnz    .draw_loop
            ret

draw_stone:
            ld      de, stone_block
            ld      b, 8
.ds_loop:
            ld      a, (de)
            ld      (hl), a
            inc     de
            inc     h
            djnz    .ds_loop
            ret

; ----------------------------------------------------------------------------
; Data
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

hero_col:           defb 0
hero_row:           defb 0
target_col:         defb 0
target_row:         defb 0
move_tick:          defb 0
player_under_attr:  defb 0
player_under_bitmap:
            defb 0, 0, 0, 0, 0, 0, 0, 0

room_data:
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

            end     start
