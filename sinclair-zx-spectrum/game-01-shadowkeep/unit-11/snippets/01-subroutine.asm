; A subroutine: CALL pushes the return address onto the stack,
; then jumps to the routine. RET pops the address and returns.

            call    check_collect   ; Save under player, check treasure
            ; ... execution continues here after RET ...

; ----

check_collect:
            ld      a, (hl)             ; Read attribute at target
            ld      (player_under), a   ; Save it
            bit     6, a                ; BRIGHT = treasure?
            ret     z                   ; No — return immediately
            res     6, a                ; Clear BRIGHT (collected)
            ld      (player_under), a   ; Update saved value
            push    hl
            ld      hl, treasure_count
            inc     (hl)                ; Count it
            pop     hl
            ret                         ; Return to caller
