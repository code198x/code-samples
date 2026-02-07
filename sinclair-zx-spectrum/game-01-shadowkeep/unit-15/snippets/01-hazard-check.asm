; Hazard detection — BIT 7 tests the FLASH bit
;
; FLASH (bit 7) means danger. After drawing the player,
; check what's underneath. If it's flashing, the player
; stepped on a hazard.

            ld      a, (player_under)
            bit     7, a                ; FLASH = hazard?
            jr      z, .not_hazard

            ; Erase player from hazard cell
            ld      hl, (player_scr)
            ld      b, 8
            ld      a, 0
.derase:    ld      (hl), a
            inc     h
            djnz    .derase

            ld      hl, (player_att)
            ld      a, (player_under)
            ld      (hl), a             ; Restore hazard attribute

            ; Lose a life
            ld      hl, lives
            dec     (hl)                ; DEC (HL) sets flags!
            jp      z, .game_over       ; Z = lives reached zero

            ; ... reset player to start ...
