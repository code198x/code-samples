; ============================================================================
; PRIMER — Beat 2, "Try this: a longer trip"
; ============================================================================
; Send a value through THREE registers before showing it:
;   A -> B -> C -> back to A -> border.
; Predict A, B and C at each step, then watch them in the register view.
; (6 is yellow.)
; ============================================================================

            org     32768

start:
            ld      a, 6             ; put 6 into A         (6 = yellow)
            ld      b, a             ; copy A into B
            ld      c, b             ; copy B into C
            ld      a, c             ; copy C back into A
            out     ($FE), a         ; show A on the border (only A can do OUT)

.loop:
            halt
            jr      .loop

            end     start
