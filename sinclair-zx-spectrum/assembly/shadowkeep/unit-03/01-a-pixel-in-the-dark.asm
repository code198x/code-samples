; ============================================================================
; SHADOWKEEP — Unit 3, Stage 1: A Pixel in the Dark
; ============================================================================
; Until now, every change we've made to the screen has been a change to an
; attribute byte — the colour-and-style word at $5800+. The pixels themselves
; have been an unspoken background: cleared by the BASIC ROM at boot,
; uniformly unlit, painted by whichever PAPER colour the attribute called for.
;
; This stage acknowledges the pixels. We clear the bitmap area at $4000-$57FF
; explicitly (no more relying on what BASIC left), then write a single byte
; at $4045 — top row of the cell where the great hall's top-left wall will
; sit. With the keep painted dark stone (PAPER 1, INK 0), the eight bits of
; that single byte appear as eight black pixels on dark blue.
;
; One byte. Eight pixels. The first stroke of pixel art in Shadowkeep.
; ============================================================================

            org     32768

start:
            ; --- BORDER black (from Unit 1) ---
            ld      a, 0
            out     ($FE), a

            ; --- clear the bitmap: 6144 bytes from $4000 to $57FF ---
            ld      hl, $4000
            ld      de, $4001
            ld      (hl), 0
            ld      bc, 6143
            ldir

            ; --- fill the attribute area with dark stone ---
            ld      hl, $5800
            ld      de, $5801
            ld      (hl), $08
            ld      bc, 767
            ldir

            ; --- one byte of bitmap data, where the wall will be ---
            ; $4045 is the top pixel row of screen cell (col 5, row 2) —
            ; the future top-left of the great hall.
            ld      a, %11111111
            ld      ($4045), a

.idle:
            halt
            jr      .idle

            end     start
