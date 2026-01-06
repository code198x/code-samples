;───────────────────────────────────────
; Play a beep
; Input: DE = pitch (higher = lower tone)
;        BC = duration (number of cycles)
;───────────────────────────────────────
play_beep:
        ; Get current border colour
        ld a, (border_colour)
        ld h, a                 ; Save border in H

.beep_loop:
        ; Speaker ON + border
        ld a, h
        or %00010000            ; Set bit 4
        out ($FE), a

        ; Delay for pitch
        push de
.delay1:
        dec de
        ld a, d
        or e
        jr nz, .delay1
        pop de

        ; Speaker OFF + border
        ld a, h
        out ($FE), a            ; Bit 4 clear, border preserved

        ; Delay for pitch
        push de
.delay2:
        dec de
        ld a, d
        or e
        jr nz, .delay2
        pop de

        ; Loop for duration
        dec bc
        ld a, b
        or c
        jr nz, .beep_loop

        ret
