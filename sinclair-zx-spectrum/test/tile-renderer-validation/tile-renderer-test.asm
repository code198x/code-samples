;
; Tile-renderer validation program
;
; Renders a 22 x 16 tile-map at char rows 2-17 using 4 distinct 8x8 tile
; patterns. Proves out:
;   - tile graphics encoding (8 bytes per tile, MSB = leftmost pixel)
;   - tile-map indexing (map_row * 22 + map_col)
;   - char-cell -> screen address conversion
;   - per-cell 8-byte blit with inc-h scanline stepping
;
; Expected visual:
;   - char rows 0-1 (HUD area) remain black (untouched)
;   - char rows 2-17 show a 22-wide room with walls around the edge
;   - asymmetric features (top-left inset 2x2 block at row 2-3 col 1-2,
;     deco square at row 5-7 col 5-8, right-edge inset block at row 9-10
;     col 19-20) make alignment errors visible at a glance
;
; Build (from this directory):
;   docker run --rm -v ../../..:/code-samples \
;       -w /code-samples/sinclair-zx-spectrum/test/tile-renderer-validation \
;       ghcr.io/code198x/sinclair-zx-spectrum:latest \
;       pasmonext --sna tile-renderer-test.asm tile-renderer-test.sna
;

            org     $8000

T_FLOOR         equ 0
T_WALL          equ 1
T_FLOOR_INSET   equ 2
T_WALL_DECO     equ 3

MAP_COLS        equ 22
MAP_ROWS        equ 16
HUD_ROWS        equ 2                  ; char rows 0-1 reserved for HUD

start:
            di
            im      1
            ei

            xor     a
            out     ($FE), a            ; black border

            call    clear_screen
            call    render_room

.halt:      halt
            jr      .halt

; ----------------------------------------------------------------------------
; clear_screen - bitmap to 0; attribute to $47 (PAPER 0, INK 7, BRIGHT 0)
; so tile-painted pixels appear white on black.
; ----------------------------------------------------------------------------
clear_screen:
            ld      hl, $4000
            ld      de, $4001
            ld      (hl), 0
            ld      bc, 6143
            ldir

            ld      hl, $5800
            ld      de, $5801
            ld      (hl), $47
            ld      bc, 767
            ldir
            ret

; ----------------------------------------------------------------------------
; render_room - iterate the 22 x 16 test map, blit one tile per cell.
; ----------------------------------------------------------------------------
render_room:
            xor     a
            ld      (cur_map_row), a    ; 0..15
.row:
            xor     a
            ld      (cur_map_col), a    ; 0..21
.col:
            ; --- tile_id = test_tile_map[map_row*22 + map_col] ---
            ld      a, (cur_map_row)
            ld      h, 0
            ld      l, a
            add     hl, hl
            ld      de, row_offset_table
            add     hl, de
            ld      e, (hl)
            inc     hl
            ld      d, (hl)             ; DE = map_row * 22

            ld      a, (cur_map_col)
            ld      h, 0
            ld      l, a
            add     hl, de              ; HL = map_row*22 + map_col
            ld      de, test_tile_map
            add     hl, de
            ld      a, (hl)             ; A = tile_id

            ; --- tile_addr = tile_graphics + tile_id * 8 ---
            ld      h, 0
            ld      l, a
            add     hl, hl
            add     hl, hl
            add     hl, hl
            ld      de, tile_graphics
            add     hl, de
            ex      de, hl              ; DE = tile graphic bytes

            ; --- screen_addr = top of char cell (map_col, map_row + HUD_ROWS) ---
            ld      a, (cur_map_row)
            add     a, HUD_ROWS
            add     a, a
            add     a, a
            add     a, a                ; pixel_row = (map_row + 2) * 8
            call    row_to_screen_addr  ; HL = addr of col 0 for that pixel row
            ld      a, (cur_map_col)
            add     a, l                ; char_col is the byte offset within row
            ld      l, a

            ; --- blit 8 bytes ---
            call    blit_tile

            ; --- next col ---
            ld      a, (cur_map_col)
            inc     a
            ld      (cur_map_col), a
            cp      MAP_COLS
            jr      nz, .col

            ; --- next row ---
            ld      a, (cur_map_row)
            inc     a
            ld      (cur_map_row), a
            cp      MAP_ROWS
            jr      nz, .row
            ret

; ----------------------------------------------------------------------------
; blit_tile - copy 8 bytes from (DE) to (HL), (HL+$100), ..., (HL+$700).
; Preserves HL; advances DE by 8.
; ----------------------------------------------------------------------------
blit_tile:
            push    hl
            ld      b, 8
.l:
            ld      a, (de)
            ld      (hl), a
            inc     de
            inc     h                   ; next scanline within the cell
            djnz    .l
            pop     hl
            ret

; ----------------------------------------------------------------------------
; row_to_screen_addr - A = pixel row (0..191) -> HL = $4000 + addr.
;
;   addr = $4000 | ((row & $C0) << 5) | ((row & $07) << 8) | ((row & $38) << 2)
; ----------------------------------------------------------------------------
row_to_screen_addr:
            push    af
            and     $C0
            rrca
            rrca
            rrca
            or      $40
            ld      h, a

            pop     af
            push    af
            and     $07
            or      h
            ld      h, a

            pop     af
            and     $38
            rlca
            rlca
            ld      l, a
            ret

; ----------------------------------------------------------------------------
; row_offset_table[map_row] = map_row * 22  (16 entries, 32 bytes)
; ----------------------------------------------------------------------------
row_offset_table:
            defw    0,    22,   44,   66
            defw    88,   110,  132,  154
            defw    176,  198,  220,  242
            defw    264,  286,  308,  330

cur_map_row:    defb 0
cur_map_col:    defb 0

; ----------------------------------------------------------------------------
; tile_graphics - 4 tiles x 8 bytes = 32 bytes.
; ----------------------------------------------------------------------------
tile_graphics:
            ; T_FLOOR - sparse asymmetric dots so adjacent floor cells don't
            ; line up into stripes that mask alignment errors.
            defb    %00000000
            defb    %01000001
            defb    %00000000
            defb    %00001000
            defb    %00000000
            defb    %10000010
            defb    %00000000
            defb    %00010000

            ; T_WALL - solid border with an internal rectangle and cross,
            ; making the cell boundary unambiguous on every side.
            defb    %11111111
            defb    %10000001
            defb    %10111101
            defb    %10100101
            defb    %10100101
            defb    %10111101
            defb    %10000001
            defb    %11111111

            ; T_FLOOR_INSET - left-half-solid + right-half-solid swap on row 4.
            ; Looks like a small diagonal staircase block.
            defb    %11110000
            defb    %11110000
            defb    %11110000
            defb    %11110000
            defb    %00001111
            defb    %00001111
            defb    %00001111
            defb    %00001111

            ; T_WALL_DECO - solid border + interior X.
            defb    %11111111
            defb    %10100101
            defb    %11010011
            defb    %11101011
            defb    %11010111
            defb    %10110011
            defb    %10101101
            defb    %11111111

; ----------------------------------------------------------------------------
; test_tile_map - 22 x 16 = 352 bytes
; ----------------------------------------------------------------------------
TW              equ T_WALL
TF              equ T_FLOOR
TI              equ T_FLOOR_INSET
TD              equ T_WALL_DECO

test_tile_map:
            ; row 0
            defb TW,TW,TW,TW,TW,TW,TW,TW,TW,TW,TW,TW,TW,TW,TW,TW,TW,TW,TW,TW,TW,TW
            ; row 1
            defb TW,TF,TF,TF,TF,TF,TF,TF,TF,TF,TF,TF,TF,TF,TF,TF,TF,TF,TF,TF,TF,TW
            ; row 2  (inset block top-left, flags column-0/1 alignment)
            defb TW,TI,TI,TF,TF,TF,TF,TF,TF,TF,TF,TF,TF,TF,TF,TF,TF,TF,TF,TF,TF,TW
            ; row 3
            defb TW,TI,TI,TF,TF,TF,TF,TF,TF,TF,TF,TF,TF,TF,TF,TF,TF,TF,TF,TF,TF,TW
            ; row 4
            defb TW,TF,TF,TF,TF,TF,TF,TF,TF,TF,TF,TF,TF,TF,TF,TF,TF,TF,TF,TF,TF,TW
            ; row 5  (deco square 5..7 x 5..8 mid-room)
            defb TW,TF,TF,TF,TF,TD,TD,TD,TD,TF,TF,TF,TF,TF,TF,TF,TF,TF,TF,TF,TF,TW
            ; row 6
            defb TW,TF,TF,TF,TF,TD,TF,TF,TD,TF,TF,TF,TF,TF,TF,TF,TF,TF,TF,TF,TF,TW
            ; row 7
            defb TW,TF,TF,TF,TF,TD,TD,TD,TD,TF,TF,TF,TF,TF,TF,TF,TF,TF,TF,TF,TF,TW
            ; row 8
            defb TW,TF,TF,TF,TF,TF,TF,TF,TF,TF,TF,TF,TF,TF,TF,TF,TF,TF,TF,TF,TF,TW
            ; row 9  (inset block bottom-right, flags right-edge byte arithmetic)
            defb TW,TF,TF,TF,TF,TF,TF,TF,TF,TF,TF,TF,TF,TF,TF,TF,TF,TF,TF,TI,TI,TW
            ; row 10
            defb TW,TF,TF,TF,TF,TF,TF,TF,TF,TF,TF,TF,TF,TF,TF,TF,TF,TF,TF,TI,TI,TW
            ; row 11
            defb TW,TF,TF,TF,TF,TF,TF,TF,TF,TF,TF,TF,TF,TF,TF,TF,TF,TF,TF,TF,TF,TW
            ; row 12
            defb TW,TF,TF,TF,TF,TF,TF,TF,TF,TF,TF,TF,TF,TF,TF,TF,TF,TF,TF,TF,TF,TW
            ; row 13
            defb TW,TF,TF,TF,TF,TF,TF,TF,TF,TF,TF,TF,TF,TF,TF,TF,TF,TF,TF,TF,TF,TW
            ; row 14
            defb TW,TF,TF,TF,TF,TF,TF,TF,TF,TF,TF,TF,TF,TF,TF,TF,TF,TF,TF,TF,TF,TW
            ; row 15
            defb TW,TW,TW,TW,TW,TW,TW,TW,TW,TW,TW,TW,TW,TW,TW,TW,TW,TW,TW,TW,TW,TW

            end     start
