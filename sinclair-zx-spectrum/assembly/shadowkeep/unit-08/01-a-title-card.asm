;
; Shadowkeep Unit 8, Stage 1 — A Title Card
;
; Unit 7 gave the keep a voice. This stage gives it a face: the word
; SHADOWKEEP, painted from the Spectrum's ROM character set, centred
; near the top of an otherwise-black screen. A presentation card —
; what a player sees in the seconds before they press a key to begin.
;
; The technique is direct bitmap manipulation. The Spectrum's ROM at
; $3D00 contains the 8x8-pixel bitmaps for every printable character.
; To draw 'S' at a screen cell, we copy its 8 bytes from ROM into the
; bitmap area at that cell's 8 successive scan-lines. Repeat for each
; character of the title. Then set the attribute cells under the title
; to white-on-black so the painted pixels show.
;

            org     32768

TITLE_ROW   equ     6                   ; character row (0-23) for title
TITLE_COL   equ     11                  ; character col (0-31) for "SHADOWKEEP"
TITLE_LEN   equ     10                  ; "SHADOWKEEP" is 10 characters
TITLE_ATTR  equ     $07                 ; INK 7 (white), PAPER 0 (black)

ROM_FONT    equ     $3D00               ; ROM character bitmaps base

start:
            im      1
            ei
            xor     a
            out     ($FE), a            ; BORDER black

            ; Clear the screen to solid black.
            call    clear_screen

            ; Paint the title.
            call    draw_title

.halt_forever:
            halt
            jr      .halt_forever

; ----------------------------------------------------------------------------
; clear_screen: bitmap → $00 (no pixels), attributes → $00 (INK 0 PAPER 0,
; both black). The screen becomes uniformly invisible-black.
; ----------------------------------------------------------------------------

clear_screen:
            ld      hl, $4000
            ld      de, $4001
            ld      (hl), 0
            ld      bc, 6143
            ldir

            ld      hl, $5800
            ld      de, $5801
            ld      (hl), 0
            ld      bc, 767
            ldir
            ret

; ----------------------------------------------------------------------------
; draw_title: render the SHADOWKEEP title at row TITLE_ROW, col TITLE_COL.
; Sets attributes under the title to white-on-black, then walks the text
; string and renders each character via draw_char.
; ----------------------------------------------------------------------------

draw_title:
            ; Set the attribute cells under the title to white-on-black.
            ; Attribute address for row R, col C = $5800 + R*32 + C.
            ld      hl, $5800 + TITLE_ROW * 32 + TITLE_COL
            ld      b, TITLE_LEN
.fill_attr:
            ld      (hl), TITLE_ATTR
            inc     hl
            djnz    .fill_attr

            ; Walk the title text and draw each character.
            ld      hl, title_text
            ld      d, TITLE_ROW
            ld      e, TITLE_COL
.next_char:
            ld      a, (hl)
            or      a                   ; null terminator?
            ret     z
            push    hl
            call    draw_char
            pop     hl
            inc     hl
            inc     e                   ; advance column
            jr      .next_char

; ----------------------------------------------------------------------------
; draw_char: render character A at screen cell (D=row, E=col).
;
; The bitmap address for the top scanline of a cell is:
;   addr = $4000 | ((row & $18) << 8) | ((row & $07) << 5) | col
;
; For successive scanlines within the cell, the address advances by $100
; per line (i.e. high byte += 1). 8 scanlines per cell, so we copy 8
; bytes from ROM, each to a destination offset by $100 from the previous.
; ----------------------------------------------------------------------------

draw_char:
            push    de

            ; HL = ROM_FONT + (A - 32) * 8 (source font bytes).
            sub     32
            ld      l, a
            ld      h, 0
            add     hl, hl              ; * 2
            add     hl, hl              ; * 4
            add     hl, hl              ; * 8
            ld      bc, ROM_FONT
            add     hl, bc              ; HL = ROM font byte 0 for char

            ; Compute destination bitmap address line-0 in DE.
            ; The row is in D (the saved copy on the stack will be popped
            ; back to restore caller's D); we already have it in D.
            push    hl                  ; save font ptr
            ld      a, d
            and     $18                 ; bits 4-3: third (0/8/16)
            or      $40                 ; OR in $40 (bitmap base high)
            ld      h, a
            ld      a, d
            and     $07                 ; bits 0-2: row within third
            rrca
            rrca
            rrca                        ; rotate 3 right == multiply 32
            or      e                   ; OR in the column (0-31)
            ld      l, a                ; HL = bitmap line-0 address
            ex      de, hl              ; DE = bitmap line-0
            pop     hl                  ; restore font ptr (HL)

            ; Copy 8 bytes from font (HL) to bitmap (DE), each on a new
            ; scanline (DE high-byte += 1 per iteration).
            ld      b, 8
.line:
            ld      a, (hl)
            ld      (de), a
            inc     hl
            inc     d                   ; DE += $100 (one scanline down)
            djnz    .line

            pop     de                  ; restore caller's row/col
            ret

; ----------------------------------------------------------------------------
; title_text: null-terminated ASCII string. Each character must be
; printable (32-127) — the ROM character set doesn't cover lower-case
; properly on the Spectrum, but uppercase letters render cleanly.
; ----------------------------------------------------------------------------

title_text:
            defm    "SHADOWKEEP", 0

            end     start
