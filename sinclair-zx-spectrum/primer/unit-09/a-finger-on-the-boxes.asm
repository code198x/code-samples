; ============================================================================
; PRIMER — Beat 9: A Finger on the Boxes
; ============================================================================
; Back in Beat 6 you coloured one cell with a fixed address:  ld ($5800), a.
; To colour the NEXT cell you'd need a whole new instruction with a new
; address baked in. That doesn't scale.
;
; A POINTER fixes this. HL is a 16-bit register pair you can use as a finger
; pointing at a box on the memory street:
;
;   ld hl, $5800   -- point the finger at the first colour cell
;   ld (hl), $17   -- write into the box the finger points at
;   inc hl         -- move the finger one box along
;
; (We deferred this in Beat 5 -- here it is. (HL) means "the box HL points
; at", just like ($5800) meant "the box at $5800" -- but now the address can
; MOVE.)
;
; We colour three cells in a row by writing, stepping, writing, stepping.
; ============================================================================

            org     32768

start:
            ld      hl, $5800        ; finger on the first colour cell (top-left)

            ld      (hl), $17        ; colour it       (PAPER red, INK white)
            inc     hl               ; step to the next cell
            ld      (hl), $17        ; colour it
            inc     hl               ; step again
            ld      (hl), $17        ; colour it

.loop:
            halt
            jr      .loop

            end     start
