; Modifying health on hits and misses
;
; Hits INCREASE health (reward), misses DECREASE it (punishment).
; Both directions need clamping to valid range.

; In add_score (called on successful hit):
add_score:
                ; ... existing score code ...

                ; Increase health (clamped to max)
                lda health
                clc
                adc #HEALTH_HIT         ; Add 2 points
                cmp #HEALTH_MAX         ; Over maximum?
                bcc +                   ; No, keep value
                lda #HEALTH_MAX         ; Yes, clamp to 64
+               sta health
                rts

; In handle_miss (called on any miss):
handle_miss:
                ; ... existing miss code ...

                ; Decrease health (clamped to 0)
                lda health
                sec
                sbc #HEALTH_MISS        ; Subtract 4 points
                bcs +                   ; Didn't underflow?
                lda #0                  ; Underflowed, clamp to 0
+               sta health
                beq .set_game_over      ; Health depleted?
                jmp .continue

.set_game_over:
                lda #1
                sta game_over           ; Signal game end

.continue:
                ; ... rest of miss handling ...
