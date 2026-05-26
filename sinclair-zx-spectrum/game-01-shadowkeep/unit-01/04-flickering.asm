; ============================================================================
; SHADOWKEEP — Unit 1, Stage 4: The Flickering Torch
; ============================================================================
; Two torches glow steadily. But the keep is still magic-tainted — the third
; flame, leftmost in the line, struggles to hold. We add it with the FLASH
; bit set. The Spectrum's video hardware alternates INK and PAPER about
; twice a second in any cell whose attribute has bit 7 high; the torch
; reads as flickering.
;
; Three flames now stand against the dark stone: one struggling (FLASH +
; BRIGHT + yellow), one steady (yellow), one bright (BRIGHT + yellow).
; The full attribute vocabulary — INK, PAPER, BRIGHT, FLASH — is on the
; screen, each one doing its job, all from the same five-byte memory
; range we've been writing to.
; ============================================================================

            org     32768

start:
            ; --- the BORDER goes black ---
            ld      a, 0
            out     ($FE), a

            ; --- attribute memory washed in dark stone ---
            ld      hl, $5800
            ld      de, $5801
            ld      (hl), $08
            ld      bc, 767
            ldir

            ; --- the first torch (centre, plain yellow) ---
            ld      a, $30
            ld      ($5990), a

            ; --- reading, brightening, the steady torch (right of centre) ---
            ld      a, ($5990)
            or      $40
            ld      ($5991), a

            ; --- the flickering torch (left of centre) ---
            ; PAPER 6 + BRIGHT (bit 6) + FLASH (bit 7) + INK 0 = $F0.
            ; Address $598F = one cell left of $5990 (same row, prev column).
            ld      a, $F0
            ld      ($598F), a

.loop:
            halt
            jr      .loop

            end     start
