; Attribute byte format: FBPPPIII
;
; F   = Flash (bit 7) - 1 = flashing, 0 = steady
; B   = Bright (bit 6) - 1 = bright colours, 0 = normal
; PPP = Paper colour (bits 5-3) - background
; III = Ink colour (bits 2-0) - foreground
;
; Example: Red paper with white ink
;   Paper = RED (2)   = 010 in bits 5-3
;   Ink   = WHITE (7) = 111 in bits 2-0
;   Result: %00010111

        ld a, %00010111     ; Red paper (010), white ink (111)
