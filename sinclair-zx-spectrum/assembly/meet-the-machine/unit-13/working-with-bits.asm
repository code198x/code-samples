; ============================================================================
; PRIMER — Beat 13: Working With Bits
; ============================================================================
; In Beat 8 you TESTED a bit (bit 0, a). Now you change them. Three tools, one
; bit-at-a-time each:
;
;   or  n   -- SET the bits that are 1 in n   (leaves the rest alone)
;   and n   -- CLEAR the bits that are 0 in n  (keeps the bits that are 1)
;   xor n   -- TOGGLE (flip) the bits that are 1 in n
;
; This is how you flip a single flag -- like the BRIGHT bit of an attribute --
; without disturbing the others. Here we start with colour 2 (red) and OR in
; bit 0, turning it into colour 3 (magenta): red + blue = magenta, one bit set.
; ============================================================================

            org     32768

start:
            ld      a, %00000010     ; bit 1 set -> colour 2 (red)
            or      %00000001        ; SET bit 0 -> %00000011 = 3 (magenta)
            out     ($FE), a         ; show it

.loop:
            halt
            jr      .loop

            end     start
