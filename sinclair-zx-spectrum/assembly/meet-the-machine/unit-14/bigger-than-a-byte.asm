; ============================================================================
; PRIMER — Beat 14: Bigger Than a Byte
; ============================================================================
; One byte stops at 255. But addresses run to 65535, far past a byte -- which
; is why registers PAIR UP: HL, DE and BC each hold a 16-bit number, 0-65535.
;
; In Beat 9 the finger stepped by one: inc hl. To step by MORE than one, you
; add a 16-bit number to it:
;
;   ld de, 32      -- 32 = one cell-row down the colour map
;   add hl, de     -- HL = HL + 32  (a 16-bit add)
;
; inc hl walked ACROSS (Beat 9); add hl, de here walks DOWN. We colour three
; cells in a column by stepping 32 each time. (This is exactly how the tiny
; game draws the sides of a wall.)
; ============================================================================

            org     32768

start:
            ld      hl, $5800        ; top-left colour cell
            ld      a, $17           ; red
            ld      de, 32           ; one cell-row = 32 cells

            ld      (hl), a          ; colour the top cell
            add     hl, de           ; step down one row  (HL = HL + 32)
            ld      (hl), a          ; colour the cell below
            add     hl, de           ; down again
            ld      (hl), a          ; and the next

.loop:
            halt
            jr      .loop

            end     start
