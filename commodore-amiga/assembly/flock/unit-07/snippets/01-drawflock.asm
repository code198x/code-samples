drawflock:
            ; Clear the icon area (a row of byte-rectangles)
            moveq   #1,d0               ; From byte 1
            move.w  #ROW_HUD+4,d1
            moveq   #12,d2              ; Room for the whole flock
            moveq   #8,d3
            bsr     rectclear

            ; One glyph per sheep in hand
            move.w  lives,d7
            ble.s   .none               ; Empty hand, empty strip
            moveq   #1,d6               ; First icon at byte 1
.icons:
            move.w  d6,d0
            move.w  #ROW_HUD+4,d1
            lea     sheepicon,a2
            bsr     drawglyph
            addq.w  #2,d6               ; Two bytes along for the next
            subq.w  #1,d7
            bne.s   .icons
.none:
            rts
