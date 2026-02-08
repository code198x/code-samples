;──────────────────────────────────────────────────────────────
; check_pixel — Test a single pixel in the bitplane
;
; Input:  D0.W = x position (0-319)
;         D1.W = y position (0-255)
; Output: D0.B = 1 if pixel is set, 0 if clear
; Destroys: D1-D3, A0
;──────────────────────────────────────────────────────────────
check_pixel:
            lea     bitplane,a0

            ; Calculate byte offset: y * 40 + x / 8
            mulu    #BYTES_PER_ROW,d1
            add.l   d1,a0

            move.w  d0,d2
            lsr.w   #3,d2               ; D2 = x / 8 (byte offset)
            add.w   d2,a0               ; A0 = address of the byte

            ; Calculate bit number within the byte
            ; Bit 7 is the leftmost pixel, bit 0 is the rightmost
            not.w   d0                  ; Invert x
            and.w   #7,d0               ; D0 = 7 - (x & 7) = bit number

            btst    d0,(a0)             ; Test the bit
            sne     d0                  ; D0 = $FF if set, $00 if clear
            and.b   #1,d0               ; D0 = 1 or 0

            rts
