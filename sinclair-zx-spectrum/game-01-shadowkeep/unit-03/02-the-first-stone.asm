; ============================================================================
; SHADOWKEEP — Unit 3, Stage 2: The First Stone
; ============================================================================
; Eight pixels was a stroke. Eight BYTES, written at $0100 intervals, is a
; whole cell of pixel art. We bring back the great hall from Unit 2, but
; change WALL's attribute from $49 to $48: the difference is the INK bits,
; which switch from blue to black. With INK black and PAPER bright blue, any
; lit pixel will now show as a black mark on a bright blue stone — the cell
; can finally carry texture instead of being a uniform colour.
;
; Then we write our stone-block bitmap — a bordered rectangle, 8 pixels
; square — to the bitmap addresses of the top-left wall cell. Eight bytes
; at the addresses $4045, $4145, $4245 ... $4745. The $0100 stride between
; pixel rows of the same cell is the Spectrum screen's defining quirk.
;
; The result: the great hall stands again, but one of its wall cells is no
; longer a flat block of bright blue — it's a stone, with black mortar
; lines outlining its shape.
; ============================================================================

WALL    equ $48       ; INK 0 (black) on PAPER 1 + BRIGHT — bright blue stone with black mortar
FLOOR   equ $38       ; INK 0 on PAPER 7 (white) — clean walking surface
GOLD    equ $70       ; INK 0 on PAPER 6 (yellow) + BRIGHT — glittering treasure

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

            ; --- draw the great hall (room attributes) ---
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

            ; --- the first stone: 8 bytes of bitmap at $0100 stride ---
            ; Target: screen cell (col 5, row 2) — top-left of the great hall.
            ; Bitmap addresses for that cell's 8 pixel rows:
            ;   $4045, $4145, $4245, $4345, $4445, $4545, $4645, $4745
            ld      hl, stone_block   ; source: stone-block pattern
            ld      de, $4045          ; destination: top pixel row of cell
            ld      b, 8               ; 8 pixel rows

.stone_loop:
            ld      a, (hl)            ; read next byte of stone pattern
            ld      (de), a            ; write to current pixel row
            inc     hl                  ; next source byte
            inc     d                   ; +$0100: high byte of DE goes up by 1
            djnz    .stone_loop

.idle:
            halt
            jr      .idle

; ----------------------------------------------------------------------------
; Stone-block bitmap: a bordered rectangle, 8 pixels square.
;
;   Row 0:  ████████   $FF
;   Row 1:  █      █   $81
;   Row 2:  █      █   $81
;   Row 3:  █      █   $81
;   Row 4:  █      █   $81
;   Row 5:  █      █   $81
;   Row 6:  █      █   $81
;   Row 7:  ████████   $FF
;
; Lit pixels render as INK (black). Unlit as PAPER (bright blue).
; The result is a single bright-blue stone with a black mortar border.
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
; Room data: the great hall (same as Unit 2 Stage 4)
; ----------------------------------------------------------------------------

room_data:

            ; Row 0 — top wall (unbroken)
            defb    WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL
            defb    WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL

            ; Row 1 — broad altar (3 cells wide) flanked by gold arcs (3 each side)
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

            ; Row 3 — altar steps: columns separated by aisle, single gold each side
            defb    WALL
            defb    FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR
            defb    GOLD
            defb    WALL
            defb    GOLD
            defb    WALL
            defb    GOLD
            defb    FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR
            defb    WALL

            ; Row 4 — altar columns frame the aisle (no gold)
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
