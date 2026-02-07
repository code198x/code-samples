; After saving the target attribute, check if it's treasure.
; BRIGHT (bit 6) means collectible. Clear it to "collect" the item —
; the cell dims from bright yellow to regular yellow.

            ld      a, (hl)             ; Read full attribute at target
            ld      (player_under), a   ; Save it

            bit     6, a                ; BRIGHT set?
            jr      z, .not_treasure    ; No — not treasure

            res     6, a                ; Clear BRIGHT — collected
            ld      (player_under), a   ; Update saved value (dimmed)
            ld      hl, treasure_count
            inc     (hl)                ; One more treasure collected

.not_treasure:
