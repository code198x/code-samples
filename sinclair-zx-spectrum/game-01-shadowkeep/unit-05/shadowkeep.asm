; ============================================================================
; SHADOWKEEP — Unit 5: Player Character
; ============================================================================
; Draw an 8x8 character to screen bitmap memory using a data table.
;
; Until now, we've only written to attribute memory ($5800+).
; The screen bitmap ($4000–$57FF) controls which pixels are lit.
; Each byte = 8 pixels. 1-bits show the cell's INK colour,
; 0-bits show the PAPER colour.
;
; Within a character cell, the 8 pixel rows are 256 bytes apart.
; INC H moves down one pixel row inside the cell.
; ============================================================================

            org     32768

; Attribute values
WALL        equ     $09             ; PAPER 1 (blue) + INK 1
FLOOR       equ     $38             ; PAPER 7 (white) + INK 0
TREASURE    equ     $70             ; BRIGHT + PAPER 6 (yellow)
HAZARD      equ     $90             ; FLASH + PAPER 2 (red)
PLAYER      equ     $3a             ; PAPER 7 (white) + INK 2 (red)

; Room dimensions
ROOM_TOP    equ     10
ROOM_LEFT   equ     12
ROOM_WIDTH  equ     9
ROOM_INNER  equ     7

; Player starting position
START_ROW   equ     11
START_COL   equ     13

; Screen addresses for player start
; Bitmap: $4800 + ((11-8) * 32) + 13 = $486D
; Attribute: $5800 + (11 * 32) + 13 = $596D
PLAYER_SCR  equ     $486d
PLAYER_ATT  equ     $596d

; Keyboard rows
KEY_ROW_QT  equ     $fb             ; Q, W, E, R, T
KEY_ROW_AG  equ     $fd             ; A, S, D, F, G
KEY_ROW_PY  equ     $df             ; P, O, I, U, Y

; ----------------------------------------------------------------------------
; Entry point
; ----------------------------------------------------------------------------

start:
            ; Black border
            ld      a, 0
            out     ($fe), a

            ; Clear screen
            ld      hl, $4000
            ld      de, $4001
            ld      bc, 6911
            ld      (hl), 0
            ldir

            ; ==================================================================
            ; Draw the room (same as Unit 3)
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

            ; --- Treasure and hazard ---
            ld      a, TREASURE
            ld      ($5990), a      ; Row 12, col 16
            ld      a, HAZARD
            ld      ($59af), a      ; Row 13, col 15

            ; ==================================================================
            ; Draw the player character
            ; ==================================================================

            ; --- Write pixel data to screen bitmap ---
            ld      hl, PLAYER_SCR  ; Screen bitmap address
            ld      de, player_gfx  ; Character data
            ld      b, 8            ; 8 pixel rows

.draw:      ld      a, (de)         ; Load byte from pattern
            ld      (hl), a         ; Write to screen
            inc     de              ; Next pattern byte
            inc     h               ; Next pixel row (+256)
            djnz    .draw

            ; --- Set player attribute ---
            ld      a, PLAYER
            ld      (PLAYER_ATT), a ; Red INK on white PAPER

            ; ==================================================================
            ; Main loop — read keyboard, change border
            ; ==================================================================

.loop:      halt

            ld      a, 0
            out     ($fe), a        ; Default: black border

            ; --- Check Q (up) ---
            ld      a, KEY_ROW_QT
            in      a, ($fe)
            bit     0, a
            jr      nz, .not_q
            ld      a, 1            ; Blue border
            out     ($fe), a
.not_q:
            ; --- Check A (down) ---
            ld      a, KEY_ROW_AG
            in      a, ($fe)
            bit     0, a
            jr      nz, .not_a
            ld      a, 2            ; Red border
            out     ($fe), a
.not_a:
            ; --- Check O (left) ---
            ld      a, KEY_ROW_PY
            in      a, ($fe)
            bit     1, a
            jr      nz, .not_o
            ld      a, 4            ; Green border
            out     ($fe), a
.not_o:
            ; --- Check P (right) ---
            ld      a, KEY_ROW_PY
            in      a, ($fe)
            bit     0, a
            jr      nz, .not_p
            ld      a, 6            ; Yellow border
            out     ($fe), a
.not_p:
            jr      .loop

; ============================================================================
; Data
; ============================================================================

; Player character — diamond shape
;   ...##...   $18
;   ..####..   $3C
;   .######.   $7E
;   ########   $FF
;   ########   $FF
;   .######.   $7E
;   ..####..   $3C
;   ...##...   $18

player_gfx: db      $18, $3c, $7e, $ff
            db      $ff, $7e, $3c, $18

; Player position (used for movement in Unit 6)
player_row: db      START_ROW
player_col: db      START_COL

            end     start
