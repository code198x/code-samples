; Generate a tone on the Spectrum's beeper.
; Bit 4 of port $FE controls the speaker. Toggle it high and low
; in a loop — the delay between toggles sets the pitch.

; Entry: HL = duration (number of cycles), DE = pitch (delay per half-cycle)

beep:
            ld      a, $10              ; Bit 4 high — speaker on
.on:        out     ($fe), a            ; Push speaker cone out
            ld      b, e                ; Delay counter = pitch
.delay1:    djnz    .delay1             ; Wait

            xor     $10                 ; Toggle bit 4 — speaker off
            out     ($fe), a            ; Pull speaker cone back
            ld      b, e                ; Same delay
.delay2:    djnz    .delay2             ; Wait

            xor     $10                 ; Toggle bit 4 — speaker on again
            dec     hl                  ; One cycle done
            ld      a, h
            or      l                   ; HL = 0?
            ld      a, $10              ; Reload speaker-on value
            jr      nz, .on             ; More cycles — continue

            xor     a                   ; A = 0 — speaker off, border black
            out     ($fe), a
            ret
