; ============================================================================
; PRIMER — Beat 10, "Try this: the dashed line, properly"
; ============================================================================
; Beat 5's dashed line took eight near-identical pokes. Here it is as a loop:
; point at the screen, write the dotted byte, step, repeat 32 times -- a full
; dashed line across the very top, and not a line of source repeated.
; ============================================================================

            org     32768

start:
            ld      hl, $4000        ; finger on the top-left pixel cell
            ld      b, 32            ; 32 cells across the top

.fill:
            ld      (hl), %10101010  ; the dotted byte from Beat 5
            inc     hl
            djnz    .fill

.loop:
            halt
            jr      .loop

            end     start
