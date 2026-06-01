; ============================================================================
; PRIMER — Beat 5: The Screen Is Memory
; ============================================================================
; The boxes from Beat 4 start at $4000. But these boxes are special: writing
; a byte to them doesn't just store a number — it lights up PIXELS. The screen
; is just a stretch of the same memory street, and PLOT was poking these boxes
; all along.
;
; We use NOTHING new — the very same store from Beat 4 (ld (addr), a), just
; pointed at the screen instead of $9000:
;
;   ld a, %11111111 ; all 8 bits set
;   ld ($4000), a   ; -> 8 solid pixels in the top-left corner
;
; And the byte's BITS are the pixels (remember %01000001 from Beat 3?). A
; dotted byte draws dotted pixels:
;
;   ld a, %10101010 ; every other bit
;   ld ($4001), a   ; -> a row of dots in the next cell
;
; The last store is a deliberate puzzle. $4020 is 32 boxes on from $4000 — so
; if the screen were a simple top-to-bottom list, it would be the next line
; down. Watch where it ACTUALLY lands. (We name that mystery; we don't solve
; it here. The screen's strange map is for later.)
; ============================================================================

            org     32768

start:
            ld      a, %11111111     ; 8 bits set
            ld      ($4000), a       ; solid block, top-left corner

            ld      a, %10101010     ; every other bit
            ld      ($4001), a       ; a row of dots, next cell along
            ld      ($4002), a       ; and again

            ld      a, %11111111     ; the puzzle byte
            ld      ($4020), a       ; "32 on from $4000" — but where does it land?

.loop:
            halt
            jr      .loop

            end     start
