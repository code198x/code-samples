; ============================================================================
; SHADOWKEEP — Unit 13: Exit Door
; ============================================================================
; Every room needs a goal. The exit door is a new attribute colour — cyan
; paper ($28) — that stands out against the white floor and blue walls.
;
; The exit sits in the bottom wall, visible from the start. The player
; can walk onto it (INK 0 passes the wall check). It doesn't do anything
; yet — Unit 14 adds the win condition.
;
; The room layout is the same structure, but with one wall cell replaced
; by the exit. A gap in the blue border, filled with cyan.
; ============================================================================

            org     32768

; Attribute values
WALL        equ     $09             ; PAPER 1 (blue) + INK 1
FLOOR       equ     $38             ; PAPER 7 (white) + INK 0
TREASURE    equ     $70             ; BRIGHT + PAPER 6 (yellow) + INK 0
HAZARD      equ     $90             ; FLASH + PAPER 2 (red) + INK 0
EXIT        equ     $28             ; PAPER 5 (cyan) + INK 0
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

; Score display position (row 23, col 10)
SCORE_SCR   equ     $50ea           ; Screen bitmap: row 23, col 10
SCORE_ATT   equ     $5aea           ; Attribute: row 23, col 10
SCORE_LEN   equ     12              ; "TREASURE n/3" = 12 characters

; Keyboard rows
KEY_ROW_QT  equ     $fb             ; Q, W, E, R, T
KEY_ROW_AG  equ     $fd             ; A, S, D, F, G
KEY_ROW_PY  equ     $df             ; P, O, I, U, Y

; ROM font
FONT_BASE   equ     $3c00           ; Character set in ROM

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

            ; Set attributes for score line
            ld      hl, SCORE_ATT
            ld      a, $47              ; BRIGHT + INK 7 (white on black)
            ld      b, SCORE_LEN
.sattr:     ld      (hl), a
            inc     hl
            djnz    .sattr

            call    print_score         ; Show initial status

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

            call    check_collect

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

            call    check_collect

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

            call    check_collect

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

            call    check_collect

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

            ; --- Update score display ---
            call    print_score

            ; --- Border shows completion ---
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
; Subroutines
; ============================================================================

; ----------------------------------------------------------------------------
; check_collect — save target cell, check for treasure, collect if found
; Entry: HL = target attribute address
; Exit:  HL preserved, player_under updated
; ----------------------------------------------------------------------------
check_collect:
            ld      a, (hl)
            ld      (player_under), a
            bit     6, a                ; BRIGHT = treasure?
            ret     z                   ; No — done
            res     6, a                ; Clear BRIGHT (collected)
            ld      (player_under), a
            push    hl
            ld      hl, treasure_count
            inc     (hl)
            pop     hl

            ; Play collect sound — short rising tone
            push    hl
            push    de
            ld      hl, 80              ; Duration (cycles)
            ld      e, 40               ; Pitch (delay — lower = higher)
            call    beep
            ld      hl, 80
            ld      e, 30               ; Higher pitch
            call    beep
            ld      hl, 80
            ld      e, 20               ; Highest pitch
            call    beep
            pop     de
            pop     hl
            ret

; ----------------------------------------------------------------------------
; beep — generate a tone on the speaker
; Entry: HL = duration (number of wave cycles), E = pitch (delay per half)
; Exit:  speaker off, border black
; Destroys: A, B, HL
; ----------------------------------------------------------------------------
beep:
            ld      a, $10              ; Bit 4 high — speaker on
.on:        out     ($fe), a            ; Push speaker cone out
            ld      b, e                ; Delay counter = pitch
.delay1:    djnz    .delay1             ; Wait

            xor     $10                 ; Toggle bit 4
            out     ($fe), a            ; Pull speaker cone back
            ld      b, e                ; Same delay
.delay2:    djnz    .delay2             ; Wait

            xor     $10                 ; Toggle bit 4 back
            dec     hl                  ; One cycle done
            ld      a, h
            or      l                   ; HL = 0?
            ld      a, $10              ; Reload (doesn't affect flags)
            jr      nz, .on             ; More cycles — continue

            xor     a                   ; A = 0 — speaker off, border black
            out     ($fe), a
            ret

; ----------------------------------------------------------------------------
; print_score — display "TREASURE n/3" at row 23
; Destroys: A, BC, DE, HL
; ----------------------------------------------------------------------------
print_score:
            ld      de, SCORE_SCR

            ld      hl, score_text
            call    print_str

            ld      a, (treasure_count)
            add     a, '0'
            call    print_char

            ld      a, '/'
            call    print_char

            ld      a, TOTAL_TREASURE
            add     a, '0'
            call    print_char

            ret

; ----------------------------------------------------------------------------
; print_str — print null-terminated string at screen address DE
; Entry: HL = string address, DE = screen address
; Exit:  HL past null terminator, DE advanced past last character
; ----------------------------------------------------------------------------
print_str:
            ld      a, (hl)
            or      a
            ret     z
            push    hl
            call    print_char
            pop     hl
            inc     hl
            jr      print_str

; ----------------------------------------------------------------------------
; print_char — draw one character to screen memory using ROM font
; Entry: A = character (32-127), DE = screen address (pixel row 0)
; Exit:  DE advanced to next column (E incremented)
; ----------------------------------------------------------------------------
print_char:
            push    de

            ld      l, a
            ld      h, 0
            add     hl, hl
            add     hl, hl
            add     hl, hl
            ld      bc, FONT_BASE
            add     hl, bc

            ld      b, 8
.pchar:     ld      a, (hl)
            ld      (de), a
            inc     hl
            inc     d
            djnz    .pchar

            pop     de
            inc     e
            ret

; ============================================================================
; Room data — one byte per cell
; ============================================================================
;
;   W W W W W W W W W
;   W . W . . . T . W      T = treasure
;   W . T . . . W . W      H = hazard
;   W . . . H . . T W      X = exit
;   W W W W W X W W W
;

room_data:
            db      WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL
            db      WALL, FLOOR, WALL, FLOOR, FLOOR, FLOOR, TREASURE, FLOOR, WALL
            db      WALL, FLOOR, TREASURE, FLOOR, FLOOR, FLOOR, WALL, FLOOR, WALL
            db      WALL, FLOOR, FLOOR, FLOOR, HAZARD, FLOOR, FLOOR, TREASURE, WALL
            db      WALL, WALL, WALL, WALL, WALL, EXIT, WALL, WALL, WALL

; ============================================================================
; String data
; ============================================================================

score_text: db      "TREASURE ", 0

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
