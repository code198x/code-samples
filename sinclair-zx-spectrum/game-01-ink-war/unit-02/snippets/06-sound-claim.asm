; ----------------------------------------------------------------------------
; Sound - Claim
; ----------------------------------------------------------------------------
; Short rising tone for successful claim

sound_claim:
            ld      hl, 400         ; Starting pitch
            ld      b, 20           ; Duration

.loop:
            push    bc
            push    hl

            ; Generate tone
            ld      b, h
            ld      c, l
.tone_loop:
            ld      a, $10          ; Speaker bit on
            out     (KEY_PORT), a
            call    .delay
            xor     a               ; Speaker bit off
            out     (KEY_PORT), a
            call    .delay
            dec     bc
            ld      a, b
            or      c
            jr      nz, .tone_loop

            pop     hl
            pop     bc

            ; Increase pitch (lower delay = higher frequency)
            ld      de, 20
            or      a
            sbc     hl, de

            djnz    .loop
            ret

.delay:
            push    bc
            ld      b, 5
.delay_loop:
            djnz    .delay_loop
            pop     bc
            ret
