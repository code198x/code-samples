; Win condition — two tests in sequence
;
; The Z80 can only test one thing at a time. To check two
; conditions, test the first and skip ahead if it fails.
; Then test the second.

            ; Is the player standing on the exit?
            ld      a, (player_under)
            cp      EXIT                ; Cyan cell?
            jr      nz, .not_on_exit    ; No — skip

            ; Yes — are all treasures collected?
            ld      a, (treasure_count)
            cp      TOTAL_TREASURE
            jr      z, .room_complete   ; Both true — win!

.not_on_exit:
            ; Game continues...
