; Generate a beep through the Spectrum speaker
; The speaker is controlled by bit 4 of port $FE
;
; Input: HL = pitch (lower = higher frequency)
;        DE = duration (number of cycles)

beep:
beep_loop:
        ld a, 16            ; Bit 4 = speaker
        out (BORDER_PORT), a ; Speaker on (also affects border!)

        ld b, l             ; Use L as pitch delay
pitch_high:
        djnz pitch_high     ; Wait

        xor a               ; Speaker off
        out (BORDER_PORT), a

        ld b, l
pitch_low:
        djnz pitch_low      ; Wait same amount

        dec de              ; Decrease duration
        ld a, d
        or e
        jr nz, beep_loop    ; Repeat until duration = 0
        ret

; The speaker shares port $FE with the border
; When making sound, the border may flicker
