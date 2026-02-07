; ============================================================================
; SHADOWKEEP — Unit 9: Treasure Items
; ============================================================================
; Treasure cells have the BRIGHT bit set (bit 6 of the attribute byte).
; They shine yellow on screen — unmistakable against the white floor.
;
; The player can walk on treasure. When they move away, the treasure
; reappears. This is the save/restore pattern: before overwriting a cell
; with the player attribute, save what was there. When erasing the player,
; put back the saved value instead of always restoring FLOOR.
;
; BIT 6,A tests the BRIGHT bit — the same BIT instruction used for
; keyboard input, now applied to game logic.
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

; Room dimensions
ROOM_TOP    equ     10
ROOM_LEFT   equ     12
ROOM_WIDTH  equ     9
ROOM_HEIGHT equ     5
ROW_SKIP    equ     23              ; 32 - ROOM_WIDTH

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

            ; Save what's at the starting cell
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

            ; Restore what was under the player
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

            ; Move valid — save what's at target
            ld      a, (hl)
            ld      (player_under), a

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

            jp      .loop

; ============================================================================
; Room data — one byte per cell
; ============================================================================
; Three treasure cells (BRIGHT yellow) placed around the room.
; The player can walk on them without destroying them.

room_data:
            db      WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL
            db      WALL, FLOOR, WALL, FLOOR, FLOOR, FLOOR, TREASURE, FLOOR, WALL
            db      WALL, FLOOR, TREASURE, FLOOR, FLOOR, FLOOR, WALL, FLOOR, WALL
            db      WALL, FLOOR, FLOOR, FLOOR, HAZARD, FLOOR, FLOOR, TREASURE, WALL
            db      WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL

; ============================================================================
; Player data
; ============================================================================

; Player character — diamond shape
player_gfx: db      $18, $3c, $7e, $ff
            db      $ff, $7e, $3c, $18

; Position tracking
player_row: db      START_ROW
player_col: db      START_COL

; Screen addresses
player_scr: dw      START_SCR
player_att: dw      START_ATT

; What was under the player before they stood there
player_under:
            db      FLOOR

            end     start
