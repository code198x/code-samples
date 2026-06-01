; ============================================================================
; SHADOWKEEP — Unit 1, Stage 3: Two Torches
; ============================================================================
; The first torch glows. We ask the keep what byte we wrote, brighten it,
; and place a brighter torch alongside the first.
;
; Three new ideas:
;   1. Reading a byte back from memory: ld a, (address).
;   2. OR for setting a single bit without disturbing the others.
;   3. Writing the modified byte to a neighbouring cell, one column right.
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

            ; --- the first torch ---
            ld      a, $30
            ld      ($5990), a

            ; --- reading the byte back, brightening it, placing it next door ---
            ; ld a, ($5990): A now holds $30 (the byte we just wrote).
            ; or $40: bit 6 of A is set; A becomes $70 (yellow PAPER + BRIGHT).
            ; ld ($5991), a: write the brightened byte one cell to the right.
            ld      a, ($5990)
            or      $40
            ld      ($5991), a

.loop:
            halt
            jr      .loop

            end     start
