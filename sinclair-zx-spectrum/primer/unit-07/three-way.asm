; ============================================================================
; PRIMER — Beat 7, "Try this: branch three ways"
; ============================================================================
; One compare can answer three questions at once: less, equal, or greater.
;   jr z  jumps when A == n  (zero flag)
;   jr c  jumps when A <  n  (the CARRY flag -- set when the subtract borrowed;
;                             we'll meet carry properly later, just use it here)
; Anything that falls past both is A > n.
; Change the value: 3 (less -> blue), 5 (equal -> green), 9 (greater -> red).
; ============================================================================

            org     32768

start:
            ld      a, 7             ; change me: 3, 5, or 9
            cp      5                ; compare A with 5

            jr      z, .equal        ; A == 5
            jr      c, .less         ; A < 5

            ld      a, 2             ; A > 5 -> red
            out     ($FE), a
            jr      .hold

.less:
            ld      a, 1             ; A < 5 -> blue
            out     ($FE), a
            jr      .hold

.equal:
            ld      a, 4             ; A == 5 -> green
            out     ($FE), a

.hold:
            halt
            jr      .hold

            end     start
