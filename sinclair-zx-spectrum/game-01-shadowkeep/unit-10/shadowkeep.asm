; ============================================================================
; SHADOWKEEP — Unit 10: Collect Treasure
; ============================================================================
; When the player moves onto a cell with BRIGHT set (bit 6), it's treasure.
; RES 6,A clears the BRIGHT bit — the cell dims from bright yellow to
; regular yellow. A counter tracks how many items have been collected.
;
; The collection happens at the moment of movement. The saved value in
; player_under is updated to the dimmed attribute, so when the player
; walks away, the collected treasure stays dim. It's gone.
;
; INC (HL) increments a byte in memory directly — no need to load it
; into A first. One instruction, one counter update.
; ============================================================================

            org     32768

; Attribute values
WALL        equ     $09             ; PAPER 1 (blue) + INK 1
FLOOR       equ     $38             ; PAPER 7 (white) + INK 0
TREASURE    equ     $70             ; BRIGHT + PAPER 6 (yellow) + INK 0
HAZARD      equ     $90             ; FLASH + PAPER 2 (red) + INK 0
PLAYER      equ     $3a             ; PAPER 7 (white) + INK 2 (red)

; Collision
WALL_INK    equ     1               ; INK colour that means "wall"

; Room
ROOM_TOP    equ     10
ROOM_LEFT   equ     12
ROOM_WIDTH  equ     9
ROOM_HEIGHT equ     5
ROW_SKIP    equ     23              ; 32 - ROOM_WIDTH
TOTAL_TREASURE equ  3               ; Treasures in the room

; Screen addresses for starting position (row 12, col 13)
START_ROW   equ     12
START_COL   equ     13
START_SCR   equ     $488d
START_ATT   equ     $598d

; Keyboard rows
KEY_ROW_QT  equ     $fb             ; Q, W, E, R, T
KEY_ROW_AG  equ     $fd             ; A, S, D, F, G
KEY_ROW_PY  equ     $df             ; P, O, I, U, Y

; ----------------------------------------------------------------------------
; Entry point
; ----------------------------------------------------------------------------

start:
            ld      a, 0
            out     ($fe), a

            ; Clear screen
            ld      hl, $4000
            ld      de, $4001
            ld      bc, 6911
            ld      (hl), 0
            ldir

            ; ==================================================================
            ; Draw room from data table
            ; ==================================================================

            ld      hl, $594c           ; Attribute address: row 10, col 12
            ld      de, room_data
            ld      c, ROOM_HEIGHT

.row:       ld      b, ROOM_WIDTH
.cell:      ld      a, (de)
            ld      (hl), a
            inc     de
            inc     hl
            djnz    .cell

            push    de
            ld      de, ROW_SKIP
            add     hl, de
            pop     de
            dec     c
            jr      nz, .row

            ; ==================================================================
            ; Draw the player at starting position
            ; ==================================================================

            ld      a, (START_ATT)
            ld      (player_under), a

            ld      hl, START_SCR
            ld      de, player_gfx
            ld      b, 8
.initdraw:  ld      a, (de)
            ld      (hl), a
            inc     de
            inc     h
            djnz    .initdraw

            ld      a, PLAYER
            ld      (START_ATT), a

            ; ==================================================================
            ; Main loop
            ; ==================================================================

.loop:      halt

            ; --- Erase player at current position ---
            ld      hl, (player_scr)
            ld      b, 8
            ld      a, 0
.erase:     ld      (hl), a
            inc     h
            djnz    .erase

            ld      hl, (player_att)
            ld      a, (player_under)
            ld      (hl), a

            ; --- Check Q (up) ---
            ld      a, KEY_ROW_QT
            in      a, ($fe)
            bit     0, a
            jr      nz, .not_q

            ld      hl, (player_att)
            ld      de, $ffe0           ; -32 (one row up)
            add     hl, de
            ld      a, (hl)
            and     $07
            cp      WALL_INK
            jr      z, .not_q

            ; Move valid — save target and check for treasure
            ld      a, (hl)
            ld      (player_under), a
            bit     6, a
            jr      z, .no_tr_q
            res     6, a
            ld      (player_under), a
            push    hl
            ld      hl, treasure_count
            inc     (hl)
            pop     hl
.no_tr_q:
            ld      (player_att), hl

            ld      hl, (player_scr)
            ld      de, $ffe0
            add     hl, de
            ld      (player_scr), hl

            ld      a, (player_row)
            dec     a
            ld      (player_row), a

.not_q:
            ; --- Check A (down) ---
            ld      a, KEY_ROW_AG
            in      a, ($fe)
            bit     0, a
            jr      nz, .not_a

            ld      hl, (player_att)
            ld      de, 32
            add     hl, de
            ld      a, (hl)
            and     $07
            cp      WALL_INK
            jr      z, .not_a

            ld      a, (hl)
            ld      (player_under), a
            bit     6, a
            jr      z, .no_tr_a
            res     6, a
            ld      (player_under), a
            push    hl
            ld      hl, treasure_count
            inc     (hl)
            pop     hl
.no_tr_a:
            ld      (player_att), hl

            ld      hl, (player_scr)
            ld      de, 32
            add     hl, de
            ld      (player_scr), hl

            ld      a, (player_row)
            inc     a
            ld      (player_row), a

.not_a:
            ; --- Check O (left) ---
            ld      a, KEY_ROW_PY
            in      a, ($fe)
            bit     1, a
            jr      nz, .not_o

            ld      hl, (player_att)
            dec     hl
            ld      a, (hl)
            and     $07
            cp      WALL_INK
            jr      z, .not_o

            ld      a, (hl)
            ld      (player_under), a
            bit     6, a
            jr      z, .no_tr_o
            res     6, a
            ld      (player_under), a
            push    hl
            ld      hl, treasure_count
            inc     (hl)
            pop     hl
.no_tr_o:
            ld      (player_att), hl

            ld      hl, (player_scr)
            dec     hl
            ld      (player_scr), hl

            ld      a, (player_col)
            dec     a
            ld      (player_col), a

.not_o:
            ; --- Check P (right) ---
            ld      a, KEY_ROW_PY
            in      a, ($fe)
            bit     0, a
            jr      nz, .not_p

            ld      hl, (player_att)
            inc     hl
            ld      a, (hl)
            and     $07
            cp      WALL_INK
            jr      z, .not_p

            ld      a, (hl)
            ld      (player_under), a
            bit     6, a
            jr      z, .no_tr_p
            res     6, a
            ld      (player_under), a
            push    hl
            ld      hl, treasure_count
            inc     (hl)
            pop     hl
.no_tr_p:
            ld      (player_att), hl

            ld      hl, (player_scr)
            inc     hl
            ld      (player_scr), hl

            ld      a, (player_col)
            inc     a
            ld      (player_col), a

.not_p:
            ; --- Draw player at current position ---
            ld      hl, (player_scr)
            ld      de, player_gfx
            ld      b, 8
.draw:      ld      a, (de)
            ld      (hl), a
            inc     de
            inc     h
            djnz    .draw

            ld      hl, (player_att)
            ld      a, PLAYER
            ld      (hl), a

            ; --- Border shows collection progress ---
            ld      a, (treasure_count)
            cp      TOTAL_TREASURE
            jr      nz, .not_all
            ld      a, 4                ; Green border — all collected
            out     ($fe), a
            jp      .loop
.not_all:
            ld      a, 0                ; Black border
            out     ($fe), a

            jp      .loop

; ============================================================================
; Room data — one byte per cell
; ============================================================================

room_data:
            db      WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL
            db      WALL, FLOOR, WALL, FLOOR, FLOOR, FLOOR, TREASURE, FLOOR, WALL
            db      WALL, FLOOR, TREASURE, FLOOR, FLOOR, FLOOR, WALL, FLOOR, WALL
            db      WALL, FLOOR, FLOOR, FLOOR, HAZARD, FLOOR, FLOOR, TREASURE, WALL
            db      WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL

; ============================================================================
; Player data
; ============================================================================

player_gfx: db      $18, $3c, $7e, $ff
            db      $ff, $7e, $3c, $18

player_row: db      START_ROW
player_col: db      START_COL

player_scr: dw      START_SCR
player_att: dw      START_ATT

player_under:
            db      FLOOR

treasure_count:
            db      0

            end     start
