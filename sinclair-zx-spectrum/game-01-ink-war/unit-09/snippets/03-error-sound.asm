; Harsh buzz for invalid move

play_error_sound:
        ld hl, 800          ; Low pitch = harsh sound
        ld de, 300          ; Longer duration
        call beep
        ret

; Low pitch = negative feedback
; Longer = emphasis on the error
; Instantly recognisable as "wrong"
