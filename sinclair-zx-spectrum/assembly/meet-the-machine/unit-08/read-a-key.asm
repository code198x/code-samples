; ============================================================================
; PRIMER — Beat 8: The Machine Can Hear You
; ============================================================================
; There's no INKEY$ waiting politely for a keypress. You READ the keyboard,
; the same way you'd read any port, and test one bit.
;
;   ld bc, $7FFE   -- pick the half-row of keys. The high byte ($7F) chooses
;                     which group; this one holds SPACE, SYM SHIFT, M, N, B.
;   in a, (c)      -- read that half-row into A. Each bit is one key.
;   bit 0, a       -- test bit 0 = SPACE.
;
; The twist: a pressed key reads as 0, not 1 -- the bit is CLEARED while held.
; So `bit 0, a` sets the zero flag when SPACE is DOWN (bit 0 = 0).
;
; We do this every frame: read SPACE, paint the border red while it's held,
; blue while it isn't. The machine is listening, frame after frame.
;
; (One key, one bit. Reading the whole keyboard -- all eight half-rows, several
; keys at once -- is the tiny game's job, where movement needs it.)
; ============================================================================

            org     32768

start:
.loop:
            ld      bc, $7FFE        ; the half-row holding SPACE
            in      a, (c)           ; read it  (a pressed key's bit = 0)
            bit     0, a             ; test bit 0 = SPACE
            jr      z, .down         ; zero flag set -> SPACE is held DOWN

            ld      a, 1             ; SPACE up   -> blue
            out     ($FE), a
            jr      .next

.down:
            ld      a, 2             ; SPACE down -> red
            out     ($FE), a

.next:
            halt                     ; wait for the frame
            jr      .loop            ; ...and read again

            end     start
