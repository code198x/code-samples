; ============================================================================
; PRIMER — Beat 4: A Street of Numbered Boxes
; ============================================================================
; Memory is one long street of numbered boxes. Every box has an address (just
; a number) and holds one byte. There are 65536 of them, and they're yours.
;
; Two new instructions, and they're mirror images:
;
;   ld ($9000), a   -- STORE: put A's byte into the box at address $9000
;   ld a, ($9000)   -- READ:  fetch the box at $9000 back into A
;
; (The brackets mean "the box AT this address", not the address itself.)
;
; We prove a byte really lives in memory the same way we proved registers in
; Beat 2 — a round trip. But this time it travels out to address $9000 and
; back, not just into register B:
;
;   1. Put 4 into A.            (4 = green)
;   2. Store A at $9000.        (the box at $9000 now holds 4)
;   3. Wipe A to 0.             (A = 0; the 4 is out in memory)
;   4. Read $9000 back into A.  (A = 4 again, fetched from the box)
;   5. Show A on the border.    (green proves the box kept our 4)
;
; $9000 is just a free patch of RAM, well clear of our program at $8000. Open
; the memory view in Emu198x and watch $9000 fill with 4.
; ============================================================================

            org     32768

start:
            ld      a, 4             ; a byte to store        (4 = green)
            ld      ($9000), a       ; STORE it at $9000       (POKE)
            ld      a, 0             ; wipe A                  (the 4 is in memory now)
            ld      a, ($9000)       ; READ it back from $9000 (PEEK)
            out     ($FE), a         ; show A — green proves the box kept it

.loop:
            halt
            jr      .loop

            end     start
