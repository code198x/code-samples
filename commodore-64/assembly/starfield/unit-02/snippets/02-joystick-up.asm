        ; UP (bit 0)
        lda $dc00           ; Read joystick port 2
        and #%00000001      ; Isolate bit 0
        bne not_up          ; Bit is 1 = NOT pressed (active low)
        dec $d001           ; Move ship up (decrease Y)
        dec $d001           ; 2 pixels per frame
not_up:
