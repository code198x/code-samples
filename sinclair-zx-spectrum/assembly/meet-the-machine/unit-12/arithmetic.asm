; ============================================================================
; PRIMER — Beat 12: Adding and Taking Away
; ============================================================================
; You've moved values, compared them, looped and branched -- but never done
; the most ordinary thing of all: maths. BASIC's `LET x = x + 1` becomes one
; instruction here.
;
;   inc a       -- add 1 to A          (dec a takes 1 away)
;   add a, n    -- add n to A          (sub n takes n away)
;   add a, b    -- add register B to A
;
; A holds 8 bits, 0-255. Add past 255 and it wraps round to 0 and sets the
; CARRY flag -- the machine's "it overflowed" signal (the carry we borrowed
; back in Test, Then Jump). We meet it properly in the Try this.
;
; Here we COMPUTE the border colour rather than just loading it: start at 2,
; count up twice, add one -- 5, cyan. In a game the numbers are a score or a
; position you don't know in advance; here they're constants so you can check.
; ============================================================================

            org     32768

start:
            ld      a, 2             ; start at 2
            inc     a                ; + 1 -> 3
            inc     a                ; + 1 -> 4
            add     a, 1             ; + 1 -> 5   (cyan)
            out     ($FE), a         ; show the computed result

.loop:
            halt
            jr      .loop

            end     start
