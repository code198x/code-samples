; ============================================================================
; PRIMER — Beat 7: Test, Then Jump
; ============================================================================
; There is no IF on the Z80. Instead the CPU does two smaller things:
;
;   cp 5          -- COMPARE A with 5. (It subtracts 5 from A, throws the
;                    answer away, and just keeps the FLAGS. If A was 5, the
;                    result was 0, so the ZERO FLAG is set.)
;   jr z, .equal  -- JUMP if the zero flag is set. Otherwise carry straight on.
;
; You build the IF yourself: test, then jump. Below, A is shown on the border
; as green if it equals 5, red if it doesn't. Change the value and the path
; the program takes changes with it.
;
; .equal and .hold are labels WE name. The leading dot makes them "local" to
; the routine above (start) -- that, and the rule that label spelling is
; case-sensitive, are conventions of the ASSEMBLER (pasmonext), not the Z80.
; See the unit text.
; ============================================================================

            org     32768

start:
            ld      a, 5             ; the value we're testing  (change me, re-run)
            cp      5                ; compare A with 5 -> sets the zero flag if equal
            jr      z, .equal        ; zero flag set? (A was 5) jump to .equal

            ld      a, 2             ; A was NOT 5 -> red
            out     ($FE), a
            jr      .hold

.equal:
            ld      a, 4             ; A was 5 -> green
            out     ($FE), a

.hold:
            halt
            jr      .hold

            end     start
