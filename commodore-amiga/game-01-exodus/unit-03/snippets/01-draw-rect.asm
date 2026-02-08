;──────────────────────────────────────────────────────────────
; draw_rect — Fill a byte-aligned rectangle in the bitplane
;
; Input:  D0.W = x position (must be multiple of 8)
;         D1.W = y position
;         D2.W = width in pixels (must be multiple of 8)
;         D3.W = height in pixels
; Destroys: D0-D5, A0-A1
;──────────────────────────────────────────────────────────────
draw_rect:
            ; Calculate starting address: bitplane + y*40 + x/8
            lea     bitplane,a0
            mulu    #BYTES_PER_ROW,d1   ; D1 = y * 40 (32-bit result)
            add.l   d1,a0               ; A0 += y offset
            lsr.w   #3,d0               ; D0 = x / 8
            add.w   d0,a0               ; A0 += x offset

            ; Convert width from pixels to bytes
            lsr.w   #3,d2               ; D2 = width / 8

            ; Outer loop: rows
            subq.w  #1,d3               ; Height - 1 for DBRA
.row:
            move.w  d2,d5
            subq.w  #1,d5               ; Width_bytes - 1 for DBRA
            move.l  a0,a1               ; A1 = row write pointer
.col:
            move.b  #$ff,(a1)+          ; Fill 8 pixels (one byte)
            dbra    d5,.col

            add.w   #BYTES_PER_ROW,a0   ; Advance to next row
            dbra    d3,.row
            rts
