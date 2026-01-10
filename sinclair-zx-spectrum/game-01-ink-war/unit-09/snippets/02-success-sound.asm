; Pleasant rising tone for successful claim

play_success_sound:
        ld hl, 200          ; Starting pitch
        ld b, 3             ; Three notes

success_loop:
        push bc
        push hl

        ld de, 150          ; Duration per note
        call beep

        pop hl
        ld bc, 30           ; Pitch increase
        or a
        sbc hl, bc          ; Higher pitch (lower value)

        pop bc
        djnz success_loop
        ret

; Rising pitch = positive feedback
; Short, cheerful, satisfying
