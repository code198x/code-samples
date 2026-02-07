; Save the attribute at the destination before the player covers it.
; Restore it when the player moves away, so treasure reappears.

            ; When moving to a new cell:
            ld      a, (hl)             ; Read full attribute at target
            ld      (player_under), a   ; Remember it

            ; When erasing the player:
            ld      hl, (player_att)
            ld      a, (player_under)   ; What was here before?
            ld      (hl), a             ; Put it back
