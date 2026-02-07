; ============================================================================
; SHADOWKEEP — Unit 8: Room from Data Table
; ============================================================================
; The room layout is now a byte array — one attribute value per cell.
; A nested loop reads the table and writes each byte to attribute memory.
; Change the data, change the room. No drawing code changes needed.
;
; The room is more complex than before: internal walls create corridors,
; treasure is tucked behind a wall, and a hazard guards the lower path.
; All of this from data alone — the drawing code doesn't know or care
; what shape the room is.
; ============================================================================

            org     32768

; Attribute values
WALL        equ     $09             ; PAPER 1 (blue) + INK 1
FLOOR       equ     $38             ; PAPER 7 (white) + INK 0
TREASURE    equ     $70             ; BRIGHT + PAPER 6 (yellow)
HAZARD      equ     $90             ; FLASH + PAPER 2 (red)
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
            ld      de, room_data       ; Pointer to room bytes
            ld      c, ROOM_HEIGHT      ; Row counter

.row:       ld      b, ROOM_WIDTH       ; Column counter
.cell:      ld      a, (de)             ; Read one cell from table
            ld      (hl), a             ; Write to attribute memory
            inc     de                  ; Next data byte
            inc     hl                  ; Next screen column
            djnz    .cell               ; Repeat for row width

            ; Skip to next row: add (32 - ROOM_WIDTH) to HL
            push    de                  ; Save data pointer
            ld      de, ROW_SKIP
            add     hl, de
            pop     de                  ; Restore data pointer
            dec     c
            jr      nz, .row

            ; ==================================================================
            ; Draw the player at starting position
            ; ==================================================================

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
            ld      a, FLOOR
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

            ld      hl, (player_att)
            ld      de, $ffe0
            add     hl, de
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

            ld      hl, (player_att)
            ld      de, 32
            add     hl, de
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

            ld      hl, (player_att)
            dec     hl
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

            ld      hl, (player_att)
            inc     hl
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
; 9 columns × 5 rows = 45 bytes.
; Change this table to change the room. The drawing code stays the same.

room_data:
            db      WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL
            db      WALL, FLOOR, WALL, FLOOR, FLOOR, FLOOR, TREASURE, FLOOR, WALL
            db      WALL, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, WALL, FLOOR, WALL
            db      WALL, FLOOR, FLOOR, FLOOR, HAZARD, FLOOR, FLOOR, FLOOR, WALL
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

            end     start
