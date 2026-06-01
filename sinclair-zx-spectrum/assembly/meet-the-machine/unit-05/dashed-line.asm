; ============================================================================
; PRIMER — Beat 5, "Try this: a dashed line across the top"
; ============================================================================
; Poke the dotted byte %10101010 into eight boxes in a row, $4000 to $4007,
; and the dots run right across the top of the screen. Yes, it's eight near-
; identical lines — Beat 9's loop will do this properly. For now, by hand.
; ============================================================================

            org     32768

start:
            ld      a, %10101010     ; the dotted pattern
            ld      ($4000), a
            ld      ($4001), a
            ld      ($4002), a
            ld      ($4003), a
            ld      ($4004), a
            ld      ($4005), a
            ld      ($4006), a
            ld      ($4007), a       ; eight cells of dots = a dashed line, top row

.loop:
            halt
            jr      .loop

            end     start
