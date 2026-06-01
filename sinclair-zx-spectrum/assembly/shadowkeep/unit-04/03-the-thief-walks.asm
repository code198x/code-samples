; ============================================================================
; SHADOWKEEP — Unit 4, Stage 3: The Thief Walks
; ============================================================================
; Stage 2's hero left a trail because no one cleared the cell he left. This
; stage gives him a memory of what was there.
;
; Two new ideas. First: nine bytes of state — one attribute byte and eight
; bitmap bytes — track the cell *underneath* the hero. Before he steps into
; a new cell, we save that cell's nine bytes. Before he leaves a cell, we
; write the nine saved bytes back, restoring the floor or gold or whatever
; was there. The keep is no longer haunted by his previous positions.
;
; Second: full QAOP movement. Q goes north (row decrement), A goes south,
; O goes west (column decrement), P goes east. A single `move_by` helper
; takes a (dcol, drow) delta and handles the entire save → update → draw
; cycle. Bounds keep the thief inside the room (rows 3-16, cols 6-25); he
; can walk over the altar walls in this stage because we don't yet check
; what's in his target cell. Collision is Unit 5's domain.
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

ROOM_MIN_COL equ 6
ROOM_MAX_COL equ 25
ROOM_MIN_ROW equ 3
ROOM_MAX_ROW equ 16

            org     32768

start:
            ; --- BORDER black ---
            ld      a, 0
            out     ($FE), a

            ; --- clear the bitmap ---
            ld      hl, $4000
            ld      de, $4001
            ld      (hl), 0
            ld      bc, 6143
            ldir

            ; --- dark stone everywhere ---
            ld      hl, $5800
            ld      de, $5801
            ld      (hl), STONE
            ld      bc, 767
            ldir

            ; --- draw the great hall (room attributes) ---
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

            ; --- stone bitmaps for every WALL cell ---
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

            ; --- initialise hero position, save what's under, draw ---
            ld      a, HERO_START_COL
            ld      (hero_col), a
            ld      a, HERO_START_ROW
            ld      (hero_row), a

            call    save_under_hero
            call    draw_hero

; ----------------------------------------------------------------------------
; Main loop: poll keys, dispatch to direction handlers, idle if none held.
; ----------------------------------------------------------------------------

main_loop:
            halt

            ld      bc, KBD_Q
            in      a, (c)
            bit     0, a
            jr      z, .move_up

            ld      bc, KBD_A
            in      a, (c)
            bit     0, a
            jr      z, .move_down

            ld      bc, KBD_P
            in      a, (c)
            ld      d, a                       ; save reading for both bits
            bit     1, a
            jr      z, .move_left
            bit     0, d
            jr      z, .move_right

            jr      main_loop

.move_up:
            ld      a, (hero_row)
            cp      ROOM_MIN_ROW
            jr      z, main_loop
            ld      b, 0
            ld      c, $FF                     ; drow = -1
            call    move_by
            jr      main_loop

.move_down:
            ld      a, (hero_row)
            cp      ROOM_MAX_ROW
            jr      z, main_loop
            ld      b, 0
            ld      c, 1                       ; drow = +1
            call    move_by
            jr      main_loop

.move_left:
            ld      a, (hero_col)
            cp      ROOM_MIN_COL
            jr      z, main_loop
            ld      b, $FF                     ; dcol = -1
            ld      c, 0
            call    move_by
            jr      main_loop

.move_right:
            ld      a, (hero_col)
            cp      ROOM_MAX_COL
            jr      z, main_loop
            ld      b, 1                       ; dcol = +1
            ld      c, 0
            call    move_by
            jr      main_loop

; ----------------------------------------------------------------------------
; move_by: take a (dcol=B, drow=C) signed delta. Restore old cell, update
; position, save new cell, draw hero. Caller has already bounds-checked.
; ----------------------------------------------------------------------------

move_by:
            push    bc                         ; save delta across the restore
            call    restore_under_hero
            pop     bc

            ld      a, (hero_col)
            add     a, b
            ld      (hero_col), a

            ld      a, (hero_row)
            add     a, c
            ld      (hero_row), a

            call    save_under_hero
            call    draw_hero
            ret

; ----------------------------------------------------------------------------
; get_attr_addr: HL = attribute address for (hero_col, hero_row)
;   $5800 + hero_row * 32 + hero_col
; ----------------------------------------------------------------------------

get_attr_addr:
            ld      h, 0
            ld      a, (hero_row)
            ld      l, a
            add     hl, hl                     ; row * 2
            add     hl, hl                     ; row * 4
            add     hl, hl                     ; row * 8
            add     hl, hl                     ; row * 16
            add     hl, hl                     ; row * 32
            ld      a, (hero_col)
            add     a, l
            ld      l, a
            jr      nc, .ok
            inc     h
.ok:
            ld      a, h
            add     a, $58
            ld      h, a                       ; HL += $5800
            ret

; ----------------------------------------------------------------------------
; get_bitmap_addr: HL = bitmap address for (hero_col, hero_row)
;   Uses bitmap_rows table indexed by (hero_row - 2).
; ----------------------------------------------------------------------------

get_bitmap_addr:
            ld      a, (hero_row)
            sub     2                          ; room row index
            add     a, a                       ; * 2 bytes per table entry
            ld      e, a
            ld      d, 0
            ld      hl, bitmap_rows
            add     hl, de
            ld      a, (hl)
            inc     hl
            ld      h, (hl)
            ld      l, a                       ; HL = start of that row at col 5
            ld      a, (hero_col)
            sub     5                          ; col offset from room start
            add     a, l
            ld      l, a
            ret     nc
            inc     h
            ret

; ----------------------------------------------------------------------------
; save_under_hero: read the cell at the hero's position into player_under.
; ----------------------------------------------------------------------------

save_under_hero:
            call    get_attr_addr
            ld      a, (hl)
            ld      (player_under_attr), a

            call    get_bitmap_addr
            ld      de, player_under_bitmap
            ld      b, 8
.save_loop:
            ld      a, (hl)
            ld      (de), a
            inc     de
            inc     h
            djnz    .save_loop
            ret

; ----------------------------------------------------------------------------
; restore_under_hero: write player_under back to the hero's cell.
; ----------------------------------------------------------------------------

restore_under_hero:
            call    get_attr_addr
            ld      a, (player_under_attr)
            ld      (hl), a

            call    get_bitmap_addr
            ld      de, player_under_bitmap
            ld      b, 8
.restore_loop:
            ld      a, (de)
            ld      (hl), a
            inc     de
            inc     h
            djnz    .restore_loop
            ret

; ----------------------------------------------------------------------------
; draw_hero: write the hero attribute + sprite to the hero's cell.
; ----------------------------------------------------------------------------

draw_hero:
            call    get_attr_addr
            ld      a, HERO_ATTR
            ld      (hl), a

            call    get_bitmap_addr
            ld      de, hero
            ld      b, 8
.draw_loop:
            ld      a, (de)
            ld      (hl), a
            inc     de
            inc     h
            djnz    .draw_loop
            ret

; ----------------------------------------------------------------------------
; draw_stone: write 8 bytes of stone_block to bitmap address in HL.
; ----------------------------------------------------------------------------

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
