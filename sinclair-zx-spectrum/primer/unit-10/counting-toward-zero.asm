; ============================================================================
; PRIMER — Beat 10: Counting Toward Zero
; ============================================================================
; In Beat 9 you stepped the finger by hand: write, inc, write, inc... A loop
; hands that repetition to the machine.
;
;   ld b, 32       -- B is the dedicated COUNTER. Load it with how many times.
;   .fill:  ...    -- the body: do the thing once.
;   djnz .fill     -- DJNZ = "Decrement B, Jump if Not Zero". One instruction
;                     subtracts 1 from B and loops back until B reaches 0.
;
; So the body runs exactly B times. Here it colours one cell and steps the
; finger -- 32 times -- which paints the whole top row of the screen red.
; That's BASIC's `FOR i = 1 TO 32 ... NEXT`, built from a counter and a jump.
;
; The pointer walk (ld hl / ld (hl) / inc hl) is exactly Beat 9; the only new
; thing is letting the machine do the counting.
; ============================================================================

            org     32768

start:
            ld      hl, $5800        ; finger on the first colour cell
            ld      b, 32            ; count: 32 cells = one full row

.fill:
            ld      (hl), $17        ; colour the cell  (PAPER red, INK white)
            inc     hl               ; step to the next
            djnz    .fill            ; B = B - 1; not zero? back to .fill

.loop:
            halt
            jr      .loop

            end     start
