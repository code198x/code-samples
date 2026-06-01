; ============================================================================
; PRIMER — Beat 4, "Try this: two boxes"
; ============================================================================
; Two addresses are two independent boxes. Store a different byte in each,
; then read ONE back and show it. Reading $9000 gives 2 (red), not 4 — the
; two boxes don't interfere. Change the read address to $9001 to fetch the
; other box (4 = green) instead.
; ============================================================================

            org     32768

start:
            ld      a, 2             ; red
            ld      ($9000), a       ; box $9000 <- 2
            ld      a, 4             ; green
            ld      ($9001), a       ; box $9001 <- 4

            ld      a, ($9000)       ; read box $9000 back  (A = 2, not 4)
            out     ($FE), a         ; border red: the boxes are separate

.loop:
            halt
            jr      .loop

            end     start
