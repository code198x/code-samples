; ============================================================================
; GLOAMING — Unit 1: The Empty Square
; ============================================================================
; Before a lamplighter, before a single lamp, there is the square. And on the
; Spectrum the square is not a picture we draw — it is a table of colour we
; write. One byte per 8x8 cell, 768 of them, living at $5800. Write a byte,
; a cell changes colour. The screen *is* the map.
;
; Three acts, each just a write to memory:
;
;   1. The BORDER — the edge outside the playable screen — is held a dusk
;      blue. One port write. We meet OUT.
;
;   2. The whole grid is washed in cobbles — dark stone underfoot. One LDIR
;      cascade fills all 768 attribute cells. We meet the Z80 block-fill.
;
;   3. A WALL FRAME is drawn round the edge — the square has sides now. Two
;      row fills and a walk down the two columns. We meet DJNZ.
;
; The pixels themselves stay blank, so every cell shows as a solid block of
; its PAPER colour: a black square framed in blue. The stipple and brick come
; later; today the map is pure colour.
; ============================================================================

            org     32768

; --- the cell vocabulary, as attribute bytes ---
; An attribute byte is:  FLASH(7) BRIGHT(6) PAPER(5-3) INK(2-0).
COBBLE      equ     %00000001       ; PAPER black (0), INK blue (1) — dark ground
WALL        equ     %00001111       ; PAPER blue (1), INK white (7) — pale stone

start:
            ; --- 1. the border goes black — the night beyond the square ---
            ; Port $FE bits 0-2 set the BORDER colour. A = 0 = black. (The
            ; walls are blue; a blue border would hide them, so the night
            ; outside the square is black and the blue walls read against it.)
            ld      a, 0
            out     ($FE), a

            ; --- 2. wash the whole grid in cobbles ---
            ; Seed $5800 with COBBLE, point DE one cell on, and let LDIR
            ; cascade that single byte through all 768 attribute cells.
            ld      hl, $5800       ; first attribute cell
            ld      de, $5801       ; one cell forward
            ld      (hl), COBBLE    ; seed the cascade
            ld      bc, 767         ; the remaining cells
            ldir

            ; --- 3. draw the wall frame ---
            ; Top row: 32 cells from $5800.
            ld      hl, $5800
            ld      b, 32
.top:
            ld      (hl), WALL
            inc     hl
            djnz    .top

            ; Bottom row: 32 cells from $5800 + 23*32 = $5AE0.
            ld      hl, $5AE0
            ld      b, 32
.bottom:
            ld      (hl), WALL
            inc     hl
            djnz    .bottom

            ; Left and right columns: walk all 24 rows, writing the first
            ; cell (col 0) and the last cell (col 31) of each.
            ld      hl, $5800
            ld      b, 24
.sides:
            ld      (hl), WALL      ; col 0 of this row
            push    hl
            ld      de, 31
            add     hl, de
            ld      (hl), WALL      ; col 31 of this row
            pop     hl
            ld      de, 32
            add     hl, de          ; advance to the next row
            djnz    .sides

; ----------------------------------------------------------------------------
; Idle loop — hold the frame, never exit. (The real game loop arrives in
; Unit 3; for now we just keep the square on screen.)
; ----------------------------------------------------------------------------
.loop:
            halt
            jr      .loop

            end     start
