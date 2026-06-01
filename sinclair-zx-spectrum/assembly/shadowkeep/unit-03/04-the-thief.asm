; ============================================================================
; SHADOWKEEP — Unit 3, Stage 4: The Thief
; ============================================================================
; The keep is lit. The great hall stands. The walls remember they were stone.
; Now someone walks among them.
;
; We extend Stage 3 by one final step: a hooded thief at the centre of the
; great hall. The placement takes two writes — one to the attribute byte (so
; the cell renders as red on white instead of the floor's plain black on
; white), and one routine that writes 8 bytes of sprite bitmap to the cell's
; top-pixel-row address at the $0100 stride we met in Stage 2.
;
; Eight bytes. One byte per pixel row. Each bit is a pixel; lit bits render
; in INK 2 (red); unlit in PAPER 7 (white). What emerges is a small hooded
; silhouette — narrow at the top, widening to a cloak, narrowing at the
; base, two feet at the bottom. He's eight pixels of red on a white square,
; standing at the centre of a 22×16 room built from data.
;
; He's also the first thing in the keep that isn't the keep.
; ============================================================================

WALL       equ $48       ; INK 0 on PAPER 1 + BRIGHT — bright blue stone with black mortar
FLOOR      equ $38       ; INK 0 on PAPER 7 (white) — clean walking surface
GOLD       equ $70       ; INK 0 on PAPER 6 (yellow) + BRIGHT — glittering treasure
HERO_ATTR  equ $3A       ; INK 2 (red) on PAPER 7 (white) — the hooded thief on the floor

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

            ; --- dark stone everywhere outside the room ---
            ld      hl, $5800
            ld      de, $5801
            ld      (hl), $08
            ld      bc, 767
            ldir

            ; --- Pass 1: draw the great hall (room attributes) ---
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

            ; --- Pass 2: write stone bitmap for every WALL cell ---
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

            ; --- Pass 3: place the hero at the centre cell ---
            ; Screen cell (col 16, row 10).
            ; Attribute address: $5800 + 10*32 + 16 = $5950
            ; Bitmap address:    third 1, row_in_third 2, col 16 = $4850

            ld      a, HERO_ATTR
            ld      ($5950), a

            ld      hl, $4850                ; destination: top pixel row
            ld      de, hero                 ; source: hero sprite data
            ld      b, 8

.hero_loop:
            ld      a, (de)
            ld      (hl), a
            inc     de
            inc     h                        ; +$0100: next pixel row, same cell
            djnz    .hero_loop

.idle:
            halt
            jr      .idle

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
; Stone-block bitmap: bordered rectangle, 8 pixels square.
; ----------------------------------------------------------------------------

stone_block:
            defb    %11111111
            defb    %10000001
            defb    %10000001
            defb    %10000001
            defb    %10000001
            defb    %10000001
            defb    %10000001
            defb    %11111111

; ----------------------------------------------------------------------------
; The hooded thief: 8 bytes of pixel art, top-down silhouette.
;
;   Row 0:  ░░░██░░░    tip of hood
;   Row 1:  ░░████░░    hood
;   Row 2:  ░██████░    shoulders inside the hood
;   Row 3:  ░██████░    cloak
;   Row 4:  ████████    cloak at its widest
;   Row 5:  ░██████░    cloak narrows
;   Row 6:  ░░████░░    base of the cloak
;   Row 7:  ░░█░░█░░    two feet
; ----------------------------------------------------------------------------

hero:
            defb    %00011000
            defb    %00111100
            defb    %01111110
            defb    %01111110
            defb    %11111111
            defb    %01111110
            defb    %00111100
            defb    %00100100

; ----------------------------------------------------------------------------
; bitmap_rows: top-pixel-row bitmap address (col 5) for each of the 16 room rows.
; ----------------------------------------------------------------------------

bitmap_rows:
            defw    $4045
            defw    $4065
            defw    $4085
            defw    $40A5
            defw    $40C5
            defw    $40E5
            defw    $4805
            defw    $4825
            defw    $4845
            defw    $4865
            defw    $4885
            defw    $48A5
            defw    $48C5
            defw    $48E5
            defw    $5005
            defw    $5025

; ----------------------------------------------------------------------------
; Room data: the great hall (same as Unit 2 Stage 4)
; ----------------------------------------------------------------------------

room_data:

            ; Row 0 — top wall (unbroken)
            defb    WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL
            defb    WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL

            ; Row 1 — broad altar flanked by gold arcs
            defb    WALL
            defb    FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR
            defb    GOLD, GOLD, GOLD
            defb    WALL, WALL, WALL
            defb    GOLD, GOLD, GOLD
            defb    FLOOR, FLOOR, FLOOR, FLOOR
            defb    WALL

            ; Row 2 — altar shoulders narrow, gold continues
            defb    WALL
            defb    FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR
            defb    GOLD, GOLD
            defb    WALL, WALL, WALL
            defb    GOLD, GOLD
            defb    FLOOR, FLOOR, FLOOR, FLOOR, FLOOR
            defb    WALL

            ; Row 3 — altar steps
            defb    WALL
            defb    FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR
            defb    GOLD
            defb    WALL
            defb    GOLD
            defb    WALL
            defb    GOLD
            defb    FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR
            defb    WALL

            ; Row 4 — altar columns frame the aisle
            defb    WALL
            defb    FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR
            defb    WALL
            defb    FLOOR
            defb    WALL
            defb    FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR
            defb    WALL

            ; Rows 5-14 — ten uniform wall + 20 floors + wall rows
            rept 10
                defb    WALL
                defb    FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR
                defb    FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR
                defb    WALL
            endm

            ; Row 15 — bottom wall (unbroken)
            defb    WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL
            defb    WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL

            end     start
