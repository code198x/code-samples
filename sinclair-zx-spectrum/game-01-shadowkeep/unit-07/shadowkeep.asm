; ============================================================================
; SHADOWKEEP — Unit 7: Wall Collision
; ============================================================================
; Before moving, read the attribute at the target cell. If its INK colour
; is 1 (blue = wall), the move is blocked. Any other INK colour is passable.
;
; This replaces the hard-coded boundary checks from Unit 6. The walls
; themselves are the collision map — no separate boundary data needed.
; The attribute system that seemed like a colour trick in Unit 1 is now
; the entire collision detection system.
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
ROOM_INNER  equ     7

; Screen addresses for starting position (row 11, col 13)
START_ROW   equ     11
START_COL   equ     13
START_SCR   equ     $486d
START_ATT   equ     $596d

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
            ; Draw the room
            ; ==================================================================

            ; --- Top wall ---
            ld      hl, $594c       ; Row 10, col 12
            ld      b, ROOM_WIDTH
            ld      a, WALL
.top:       ld      (hl), a
            inc     hl
            djnz    .top

            ; --- Row 11: wall, floor, wall ---
            ld      hl, $596c
            ld      a, WALL
            ld      (hl), a
            inc     hl
            ld      a, FLOOR
            ld      b, ROOM_INNER
.r11:       ld      (hl), a
            inc     hl
            djnz    .r11
            ld      a, WALL
            ld      (hl), a

            ; --- Row 12: wall, floor, wall ---
            ld      hl, $598c
            ld      a, WALL
            ld      (hl), a
            inc     hl
            ld      a, FLOOR
            ld      b, ROOM_INNER
.r12:       ld      (hl), a
            inc     hl
            djnz    .r12
            ld      a, WALL
            ld      (hl), a

            ; --- Row 13: wall, floor, wall ---
            ld      hl, $59ac
            ld      a, WALL
            ld      (hl), a
            inc     hl
            ld      a, FLOOR
            ld      b, ROOM_INNER
.r13:       ld      (hl), a
            inc     hl
            djnz    .r13
            ld      a, WALL
            ld      (hl), a

            ; --- Bottom wall ---
            ld      hl, $59cc
            ld      b, ROOM_WIDTH
            ld      a, WALL
.bot:       ld      (hl), a
            inc     hl
            djnz    .bot

            ; --- Treasure, hazard, and internal wall ---
            ld      a, TREASURE
            ld      ($5990), a      ; Row 12, col 16
            ld      a, HAZARD
            ld      ($59af), a      ; Row 13, col 15
            ld      a, WALL
            ld      ($598f), a      ; Row 12, col 15 — pillar

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
            ld      de, $ffe0       ; -32 (one row up)
            add     hl, de
            ld      a, (hl)         ; Read target attribute
            and     $07             ; Extract INK
            cp      WALL_INK
            jr      z, .not_q       ; Wall — blocked

            ; Move up
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
            ld      de, 32          ; +32 (one row down)
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
            dec     hl              ; -1 (one column left)
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
            inc     hl              ; +1 (one column right)
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
; Data
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
