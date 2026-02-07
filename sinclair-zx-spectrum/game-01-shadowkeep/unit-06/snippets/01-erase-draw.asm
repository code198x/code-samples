            ; Erase player at current position
            ;
            ; Clear all 8 pixel rows in the bitmap, then
            ; restore the floor attribute.

            ld      hl, (player_scr)  ; Load bitmap address
            ld      b, 8
            ld      a, 0
.erase:     ld      (hl), a           ; Clear pixel row
            inc     h                 ; Next pixel row (+256)
            djnz    .erase

            ld      hl, (player_att)  ; Load attribute address
            ld      a, FLOOR
            ld      (hl), a           ; Restore floor colour

            ; ... (check keys, update position) ...

            ; Draw player at new position
            ;
            ; Write 8 bytes of character data to the bitmap,
            ; then set the player attribute.

            ld      hl, (player_scr)  ; Bitmap address (updated)
            ld      de, player_gfx    ; Character data
            ld      b, 8
.draw:      ld      a, (de)           ; Pattern byte
            ld      (hl), a           ; Write to screen
            inc     de
            inc     h
            djnz    .draw

            ld      hl, (player_att)  ; Attribute address (updated)
            ld      a, PLAYER
            ld      (hl), a           ; Set player colour
