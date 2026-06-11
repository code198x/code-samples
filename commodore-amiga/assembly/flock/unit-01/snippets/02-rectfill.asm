;──────────────────────────────────────────────────────────────
; rectfill — set a byte-aligned rectangle of pixels
;   d0 = x (bytes)   d1 = row   d2 = width (bytes)   d3 = height
;   Trashes d1, d4, d5, a0, a1.
;──────────────────────────────────────────────────────────────
rectfill:
            lea     plane,a0
            move.w  d1,d4
            mulu    #ROW_BYTES,d4       ; row * 40
            add.w   d0,d4               ; + x
            adda.w  d4,a0               ; A0 = first byte of the rectangle
            move.w  d3,d4               ; D4 = rows to go
.row:
            movea.l a0,a1
            move.w  d2,d5               ; D5 = bytes to go
.col:
            move.b  #$ff,(a1)+          ; 8 pixels on
            subq.w  #1,d5
            bne.s   .col
            lea     ROW_BYTES(a0),a0    ; down one row
            subq.w  #1,d4
            bne.s   .row
            rts
