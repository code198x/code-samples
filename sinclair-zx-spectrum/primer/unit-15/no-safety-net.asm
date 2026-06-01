; ============================================================================
; PRIMER — Beat 12: The Machine Trusts You
; ============================================================================
; Every program so far ended with something that worked. This one ends with
; something that's WRONG -- on purpose -- because the most important thing to
; learn about this machine is what it does when you make a mistake.
;
; This looks like Beat 10's "colour the top row". But the count is 255, not
; 32. We meant one row. Watch what the machine does with what we actually
; wrote: it colours 255 cells -- about eight rows -- and never says a word.
;
; There is no "Wrong count" error. No bounds check. No "did you mean 32?".
; The Z80 does EXACTLY what the bytes say, even when the bytes are wrong.
; Debugging here is not reading an error message -- it's OBSERVING the state
; (the register and memory views you've used all Primer) and reasoning about
; what really happened.
; ============================================================================

            org     32768

start:
            ld      hl, $5800        ; the top colour row
            ld      a, $17           ; red
            ld      b, 255           ; BUG: we meant 32. The machine won't mind.

.fill:
            ld      (hl), a
            inc     hl
            djnz    .fill            ; runs 255 times, not 32 -- no warning

.loop:
            halt
            jr      .loop

            end     start
