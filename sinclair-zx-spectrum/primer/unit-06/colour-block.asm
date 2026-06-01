; ============================================================================
; PRIMER — Beat 6, "Try this: a 2x2 block, one cell BRIGHT"
; ============================================================================
; The colour map is linear: $5800 + row*32 + col. So a 2x2 block of cells is
;   $5800 (top-left)   $5801 (top-right)
;   $5820 (bot-left)   $5821 (bot-right)   <- +32 is one cell row down
; Colour all four red; set the BRIGHT bit (bit 6, +$40) on the last one to
; see bright red against normal red.
; ============================================================================

            org     32768

start:
            ld      a, %00010111     ; PAPER red, INK white
            ld      ($5800), a       ; top-left
            ld      ($5801), a       ; top-right
            ld      ($5820), a       ; bottom-left  (one cell row down)

            ld      a, %01010111     ; same colours, BRIGHT bit set
            ld      ($5821), a       ; bottom-right, bright red

.loop:
            halt
            jr      .loop

            end     start
