; ============================================================================
; GLOAMING — Unit 12: Nightheld
; ============================================================================
; The tally can fill (Unit 11) — so filling it should mean something. This unit
; adds the WIN: light every lamp and the lamplighter has held back the dark.
; The game says so with a closing line, then holds that end state.
;
; Two new pieces:
;
;   1. The win condition. We already count lit lamps; when lit_count reaches
;      NUM_LAMPS, the game is won. We test it right after a lamp lights — the
;      only moment the count can change.
;
;   2. Printing text. The closing line is drawn with the SPECTRUM'S OWN FONT,
;      which lives in ROM at $3C00. Each character's 8-byte shape sits at
;      $3C00 + code*8, so printing a letter is the glyph-draw we've done since
;      Unit 2, with the bytes coming from ROM instead of our own data. One
;      routine, print_char, then a loop over the string.
;
; On a win we reveal the last lamp (the lamplighter steps aside), print the
; line across the middle, and sit in a tiny end loop — the game is over, and
; won.
; ============================================================================

            org     32768

COBBLE      equ     %00000001
WALL        equ     %00001111
LAMP_ATTR   equ     %01000111
LAMP_UNLIT  equ     %00000101
LAMP_LIT    equ     %01000110
WALL_BIT    equ     3

PIP_UNLIT   equ     %00101000
PIP_LIT     equ     %01110000
PIP_BASE    equ     $5800 + 12
NUM_LAMPS   equ     8

MSG_ATTR    equ     %01000111       ; BRIGHT, PAPER black, INK white — the closing line
MSG_ROW     equ     11
MSG_COL     equ     7               ; centred for a 17-character line
FONT        equ     $3C00           ; ROM font base; glyph for code c is FONT + c*8

START_COL   equ     15
START_ROW   equ     11

KEYS_OP     equ     $DFFE
KEYS_Q      equ     $FBFE
KEYS_A      equ     $FDFE

; ============================================================================
; SETUP — runs once.
; ============================================================================
start:
            ld      a, 0
            out     ($FE), a

            ld      hl, $5800
            ld      de, $5801
            ld      (hl), COBBLE
            ld      bc, 767
            ldir

            ld      hl, $5820       ; top wall — row 1
            ld      b, 32
.top:
            ld      (hl), WALL
            inc     hl
            djnz    .top

            ld      hl, $5AE0       ; bottom wall — row 23
            ld      b, 32
.bottom:
            ld      (hl), WALL
            inc     hl
            djnz    .bottom

            ld      hl, $5820       ; sides, rows 1..23
            ld      b, 23
.sides:
            ld      (hl), WALL
            push    hl
            ld      de, 31
            add     hl, de
            ld      (hl), WALL
            pop     hl
            ld      de, 32
            add     hl, de
            djnz    .sides

            call    draw_pips
            call    draw_lamps
            call    save_under
            call    draw_lamp

; ============================================================================
; THE HEARTBEAT — move, light, tally, and check for the win.
; ============================================================================
            im      1
            ei

game_loop:
            halt

            ld      a, (lamp_col)
            ld      (tcol), a
            ld      a, (lamp_row)
            ld      (trow), a

            ld      bc, KEYS_OP
            in      a, (c)
            bit     1, a
            jr      z, .left
            bit     0, a
            jr      z, .right
            ld      bc, KEYS_Q
            in      a, (c)
            bit     0, a
            jr      z, .up
            ld      bc, KEYS_A
            in      a, (c)
            bit     0, a
            jr      z, .down
            jr      game_loop

.left:
            ld      hl, tcol
            dec     (hl)
            jr      .try
.right:
            ld      hl, tcol
            inc     (hl)
            jr      .try
.up:
            ld      hl, trow
            dec     (hl)
            jr      .try
.down:
            ld      hl, trow
            inc     (hl)
.try:
            ld      a, (trow)
            ld      b, a
            ld      a, (tcol)
            ld      c, a
            call    wall_at
            jr      nz, game_loop

            call    restore_under
            ld      a, (tcol)
            ld      (lamp_col), a
            ld      a, (trow)
            ld      (lamp_row), a
            call    save_under

            ld      a, (under_lamp + 8)
            cp      LAMP_UNLIT
            jr      nz, .not_lamp
            ld      a, LAMP_LIT
            ld      (under_lamp + 8), a
            call    light_pip
.not_lamp:
            call    draw_lamp

            ld      a, (lit_count)  ; all lamps lit?
            cp      NUM_LAMPS
            jp      z, win
            jr      game_loop

; ----------------------------------------------------------------------------
; win — reveal the last lamp, print the closing line, hold the end state.
; ----------------------------------------------------------------------------
win:
            call    restore_under   ; the lamplighter steps aside; last lamp shows
            call    draw_message
.hold:
            halt
            jr      .hold

; ----------------------------------------------------------------------------
; draw_message — print msg_text from (MSG_ROW, MSG_COL), ended by $FF.
; ----------------------------------------------------------------------------
draw_message:
            ld      hl, msg_text
            ld      c, MSG_COL
.dm:
            ld      a, (hl)
            cp      $FF
            ret     z
            push    hl
            ld      b, MSG_ROW
            call    print_char      ; A=char, B=row, C=col; preserves C
            pop     hl
            inc     hl
            inc     c               ; next column
            jr      .dm

; ----------------------------------------------------------------------------
; print_char — A=char code, B=row, C=col. Copy the ROM-font glyph into the cell.
; ----------------------------------------------------------------------------
print_char:
            ld      l, a            ; HL = code * 8
            ld      h, 0
            add     hl, hl
            add     hl, hl
            add     hl, hl
            ld      de, FONT
            add     hl, de
            ex      de, hl          ; DE = glyph address in ROM
            push    de
            call    attr_addr_cr    ; HL = attribute of (B,C); BC preserved
            ld      (hl), MSG_ATTR
            call    scr_addr_cr     ; HL = screen of (B,C)
            pop     de              ; DE = glyph address
            ld      b, 8
.pc:
            ld      a, (de)
            ld      (hl), a
            inc     de
            inc     h
            djnz    .pc
            ret

; ----------------------------------------------------------------------------
; light_pip / draw_pips  (Unit 11).
; ----------------------------------------------------------------------------
light_pip:
            ld      a, (lit_count)
            ld      e, a
            ld      d, 0
            inc     a
            ld      (lit_count), a
            ld      hl, PIP_BASE
            add     hl, de
            ld      (hl), PIP_LIT
            ret

draw_pips:
            ld      hl, PIP_BASE
            ld      b, NUM_LAMPS
            ld      a, PIP_UNLIT
.dp:
            ld      (hl), a
            inc     hl
            djnz    .dp
            ret

; ----------------------------------------------------------------------------
; draw_lamps / draw_lantern  (Unit 9).
; ----------------------------------------------------------------------------
draw_lamps:
            ld      hl, lamp_data
.next:
            ld      a, (hl)
            cp      $FF
            ret     z
            ld      c, a
            inc     hl
            ld      b, (hl)
            inc     hl
            push    hl
            call    draw_lantern
            pop     hl
            jr      .next

draw_lantern:
            call    attr_addr_cr
            ld      (hl), LAMP_UNLIT
            call    scr_addr_cr
            ld      de, lantern
            ld      b, 8
.dlt:
            ld      a, (de)
            ld      (hl), a
            inc     de
            inc     h
            djnz    .dlt
            ret

; ----------------------------------------------------------------------------
; scr_addr_cr / attr_addr_cr / wall_at / pos_bc  (Unit 8).
; ----------------------------------------------------------------------------
scr_addr_cr:
            ld      a, b
            and     %00011000
            or      %01000000
            ld      h, a
            ld      a, b
            and     %00000111
            rrca
            rrca
            rrca
            or      c
            ld      l, a
            ret

attr_addr_cr:
            ld      a, b
            ld      l, a
            ld      h, 0
            add     hl, hl
            add     hl, hl
            add     hl, hl
            add     hl, hl
            add     hl, hl
            ld      de, $5800
            add     hl, de
            ld      a, c
            ld      e, a
            ld      d, 0
            add     hl, de
            ret

wall_at:
            call    attr_addr_cr
            bit     WALL_BIT, (hl)
            ret

pos_bc:
            ld      a, (lamp_row)
            ld      b, a
            ld      a, (lamp_col)
            ld      c, a
            ret

; ----------------------------------------------------------------------------
; save_under / restore_under / draw_lamp  (Unit 8).
; ----------------------------------------------------------------------------
save_under:
            call    pos_bc
            call    scr_addr_cr
            ld      de, under_lamp
            ld      b, 8
.su:
            ld      a, (hl)
            ld      (de), a
            inc     de
            inc     h
            djnz    .su
            call    pos_bc
            call    attr_addr_cr
            ld      a, (hl)
            ld      (under_lamp + 8), a
            ret

restore_under:
            call    pos_bc
            call    scr_addr_cr
            ld      de, under_lamp
            ld      b, 8
.ru:
            ld      a, (de)
            ld      (hl), a
            inc     de
            inc     h
            djnz    .ru
            call    pos_bc
            call    attr_addr_cr
            ld      a, (under_lamp + 8)
            ld      (hl), a
            ret

draw_lamp:
            call    pos_bc
            call    attr_addr_cr
            ld      (hl), LAMP_ATTR
            call    pos_bc
            call    scr_addr_cr
            ld      de, lamplighter
            ld      b, 8
.dl:
            ld      a, (de)
            ld      (hl), a
            inc     de
            inc     h
            djnz    .dl
            ret

; ----------------------------------------------------------------------------
; Level data, state, buffer, shapes, and the closing line.
; ----------------------------------------------------------------------------
lamp_data:
            defb    4, 3
            defb    27, 3
            defb    9, 7
            defb    22, 7
            defb    6, 15
            defb    25, 15
            defb    13, 20
            defb    18, 20
            defb    $FF

lamp_col:
            defb    START_COL
lamp_row:
            defb    START_ROW
tcol:
            defb    0
trow:
            defb    0
lit_count:
            defb    0

under_lamp:
            defb    0, 0, 0, 0, 0, 0, 0, 0, 0

lamplighter:
            defb    %00111100
            defb    %00111100
            defb    %00011000
            defb    %01111110
            defb    %00011000
            defb    %00011000
            defb    %00100100
            defb    %01000010

lantern:
            defb    %00011000
            defb    %00100100
            defb    %01111110
            defb    %01111110
            defb    %01011010
            defb    %01111110
            defb    %01111110
            defb    %00111100

msg_text:
            defb    "THE NIGHT IS HELD"
            defb    $FF

            end     start
