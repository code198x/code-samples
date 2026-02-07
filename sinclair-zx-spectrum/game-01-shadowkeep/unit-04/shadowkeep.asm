; ============================================================================
; SHADOWKEEP — Unit 4: Keyboard Input
; ============================================================================
; Read the keyboard using IN A,($FE) and respond to QAOP keys.
;
; The Spectrum's keyboard is a matrix read through port $FE.
; The high byte of the port address selects which row to scan.
; Each row returns 5 key states in bits 0–4 (0 = pressed).
;
; QAOP mapping:
;   Q (up)    — row $FB, bit 0
;   A (down)  — row $FD, bit 0
;   O (left)  — row $DF, bit 1
;   P (right) — row $DF, bit 0
; ============================================================================

            org     32768

; Attribute values
WALL        equ     $09             ; PAPER 1 (blue) + INK 1
FLOOR       equ     $38             ; PAPER 7 (white) + INK 0
TREASURE    equ     $70             ; BRIGHT + PAPER 6 (yellow)
HAZARD      equ     $90             ; FLASH + PAPER 2 (red)

; Room dimensions
ROOM_TOP    equ     10
ROOM_LEFT   equ     12
ROOM_WIDTH  equ     9
ROOM_INNER  equ     7

; Keyboard rows (active-low — 0 on the address line selects the row)
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
            ; Main loop — read keyboard, change border colour
            ; ==================================================================

.loop:      halt                    ; Wait for next frame

            ; Reset border to black (no key held = black)
            ld      a, 0
            out     ($fe), a

            ; --- Check Q (up) ---
            ld      a, KEY_ROW_QT   ; Select row: Q, W, E, R, T
            in      a, ($fe)        ; Read keyboard row
            bit     0, a            ; Test Q (bit 0)
            jr      nz, .not_q      ; 1 = not pressed
            ld      a, 1            ; Q pressed — blue border
            out     ($fe), a
.not_q:

            ; --- Check A (down) ---
            ld      a, KEY_ROW_AG   ; Select row: A, S, D, F, G
            in      a, ($fe)
            bit     0, a            ; Test A (bit 0)
            jr      nz, .not_a
            ld      a, 2            ; A pressed — red border
            out     ($fe), a
.not_a:

            ; --- Check O (left) ---
            ld      a, KEY_ROW_PY   ; Select row: P, O, I, U, Y
            in      a, ($fe)
            bit     1, a            ; Test O (bit 1)
            jr      nz, .not_o
            ld      a, 4            ; O pressed — green border
            out     ($fe), a
.not_o:

            ; --- Check P (right) ---
            ld      a, KEY_ROW_PY   ; Same row as O
            in      a, ($fe)
            bit     0, a            ; Test P (bit 0)
            jr      nz, .not_p
            ld      a, 6            ; P pressed — yellow border
            out     ($fe), a
.not_p:

            jr      .loop

            end     start
